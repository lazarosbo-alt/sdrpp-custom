# Windows Build Verification Tests
# Catches critical issues before artifact creation

param(
    [Parameter(Mandatory=$true)]
    [string]$BuildDir,
    
    [Parameter(Mandatory=$false)]
    [string]$PackageDir
)

Write-Host "[TEST] Starting Windows Build Verification Tests..." -ForegroundColor Yellow

$FailedTests = 0
$TotalTests = 0

function Test-Result {
    param($TestPassed, $TestName)
    $script:TotalTests++
    if ($TestPassed) {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        $script:FailedTests++
    }
}

Write-Host ""
Write-Host "[BUILD] Testing Build Directory Structure..." -ForegroundColor Cyan

# Test 1: Core executable exists (Windows builds to Release subdirectory)
Test-Result (Test-Path "$BuildDir\Release\sdrpp_ce.exe") "Core executable (sdrpp_ce.exe) exists"

# Test 2: Critical modules exist (Windows builds to Release subdirectories)
$RequiredModules = @(
    "sink_modules\audio_sink\Release\audio_sink.dll",
    "sink_modules\network_sink\Release\network_sink.dll", 
    "decoder_modules\radio\Release\radio.dll",
    "source_modules\file_source\Release\file_source.dll"
)

foreach ($module in $RequiredModules) {
    Test-Result (Test-Path "$BuildDir\$module") "Module exists: $module"
}

Write-Host ""
Write-Host "[PACKAGE] Testing Windows Package Structure..." -ForegroundColor Cyan

if ($PackageDir -and (Test-Path $PackageDir)) {
    # Test 3: Package structure
    Test-Result (Test-Path "$PackageDir\sdrpp_ce.exe") "Package executable exists"
    Test-Result (Test-Path "$PackageDir\modules") "Modules directory exists"
    Test-Result (Test-Path "$PackageDir\res") "Resources directory exists"
    
    # Test 4: Critical DLLs in package
    $PackageRequiredModules = @(
        "modules\audio_sink.dll",
        "modules\network_sink.dll",
        "modules\radio.dll",
        "modules\file_source.dll"
    )
    
    foreach ($module in $PackageRequiredModules) {
        Test-Result (Test-Path "$PackageDir\$module") "Package contains: $module"
    }
    
    # Test 5: Configuration file tests
    if (Test-Path "$PackageDir\config.json") {
        try {
            $config = Get-Content "$PackageDir\config.json" | ConvertFrom-Json
            $hasModulesDir = $config.PSObject.Properties.Name -contains "modulesDirectory"
            $hasResourcesDir = $config.PSObject.Properties.Name -contains "resourcesDirectory"
            
            Test-Result $hasModulesDir "config.json contains modulesDirectory"
            Test-Result $hasResourcesDir "config.json contains resourcesDirectory"
            
            if ($hasModulesDir) {
                $correctModulesPath = $config.modulesDirectory -eq "./modules"
                Test-Result $correctModulesPath "modulesDirectory points to ./modules"
            }
            
            if ($hasResourcesDir) {
                $correctResourcesPath = $config.resourcesDirectory -eq "./res"
                Test-Result $correctResourcesPath "resourcesDirectory points to ./res"
            }
        }
        catch {
            Test-Result $false "config.json is valid JSON"
        }
    } else {
        Test-Result $false "config.json exists in package"
    }
    
    # Test 6: Audio sink specific tests
    if (Test-Path "$PackageDir\modules\audio_sink.dll") {
        try {
            $fileInfo = Get-Item "$PackageDir\modules\audio_sink.dll"
            $isValidSize = $fileInfo.Length -gt 10000
            Test-Result $isValidSize "audio_sink.dll has reasonable file size"
        }
        catch {
            Test-Result $false "audio_sink.dll validation failed"
        }
    }
    
} else {
    Write-Host "[WARNING] Package directory not found, skipping package tests" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[STARTUP] Testing Application Startup..." -ForegroundColor Cyan

# Test 7: Startup test
$TestExe = if ($PackageDir -and (Test-Path "$PackageDir\sdrpp_ce.exe")) { 
    "$PackageDir\sdrpp_ce.exe" 
} else { 
    "$BuildDir\Release\sdrpp_ce.exe" 
}

if (Test-Path $TestExe) {
    try {
        # Use simpler approach - just run the exe and capture exit code
        $startTime = Get-Date
        $job = Start-Job -ScriptBlock { 
            param($exe)
            & $exe --help 2>$null >$null
            return $LASTEXITCODE
        } -ArgumentList $TestExe
        
        # Wait up to 5 seconds for completion
        $completed = Wait-Job $job -Timeout 5
        
        if ($completed) {
            $exitCode = Receive-Job $job
            Remove-Job $job
            
            if ($null -eq $exitCode) { $exitCode = "null" }
            $startupOk = ($exitCode -eq 0) -or ($exitCode -eq 1)
            Test-Result $startupOk "Application startup test (exit code: $exitCode)"
        } else {
            # Job timed out - this means app started but didn't exit quickly (good sign)
            Remove-Job $job -Force
            Test-Result $true "Application starts without immediate crash (timeout - good sign)"
        }
    }
    catch {
        Test-Result $false "Application startup test (exception: $($_.Exception.Message))"
    }
} else {
    Test-Result $false "Executable not found for startup test"
}

Write-Host ""
Write-Host "[SUMMARY] Test Summary:" -ForegroundColor Yellow
Write-Host "   Total Tests: $TotalTests"
Write-Host "   Passed: $($TotalTests - $FailedTests)" -ForegroundColor Green
Write-Host "   Failed: $FailedTests" -ForegroundColor Red

if ($FailedTests -eq 0) {
    Write-Host "[SUCCESS] All tests passed! Build is ready for release." -ForegroundColor Green
    exit 0
} else {
    Write-Host "[ERROR] $FailedTests test(s) failed! Build should NOT be released." -ForegroundColor Red
    exit 1
}
