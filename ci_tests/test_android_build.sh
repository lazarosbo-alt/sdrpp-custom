#!/bin/bash
# Android Build Verification Tests
# Catches critical issues before artifact creation

set -e  # Exit on any error
echo "🧪 Starting Android Build Verification Tests..."

APK_PATH="$1"

if [ -z "$APK_PATH" ]; then
    echo "❌ Usage: $0 <apk_path>"
    exit 1
fi

FAILED_TESTS=0
TOTAL_TESTS=0

# Test result tracking
test_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

echo ""
echo "📱 Testing Android APK Structure..."

# Test 1: APK file exists and is valid
test -f "$APK_PATH"
test_result $? "APK file exists"

if [ -f "$APK_PATH" ]; then
    # Test 2: APK is a valid ZIP file (APKs are ZIP files)
    file "$APK_PATH" | grep -q "Zip\|Java\|archive"
    test_result $? "APK is valid archive format"
    
    # Test 3: Check APK contents using aapt if available
    if command -v aapt >/dev/null 2>&1; then
        aapt list "$APK_PATH" | grep -q "AndroidManifest.xml"
        test_result $? "APK contains AndroidManifest.xml"
        
        aapt list "$APK_PATH" | grep -q "classes.dex"
        test_result $? "APK contains classes.dex"
        
        # Test 4: Check for native libraries
        aapt list "$APK_PATH" | grep -q "lib/.*\.so"
        test_result $? "APK contains native libraries (.so files)"
        
        # Test 5: Check for specific architectures
        ARCHITECTURES=("arm64-v8a" "armeabi-v7a")
        for arch in "${ARCHITECTURES[@]}"; do
            aapt list "$APK_PATH" | grep -q "lib/$arch/"
            if [ $? -eq 0 ]; then
                test_result 0 "APK contains $arch libraries"
                
                # Check for core library in this architecture
                aapt list "$APK_PATH" | grep -q "lib/$arch/libsdrpp_core.so"
                test_result $? "APK contains libsdrpp_core.so for $arch"
            fi
        done
        
        # Test 6: Check APK metadata
        aapt dump badging "$APK_PATH" | grep -q "package: name='org.sdrpp.sdrpp'"
        test_result $? "APK has correct package name"
        
        aapt dump badging "$APK_PATH" | grep -q "versionName="
        test_result $? "APK has version name set"
        
    else
        echo "ℹ️  aapt not available, skipping detailed APK analysis"
    fi
    
    # Test 7: Basic APK integrity using unzip
    unzip -t "$APK_PATH" >/dev/null 2>&1
    test_result $? "APK passes integrity check"
    
    # Test 8: APK size check (should be reasonable size)
    APK_SIZE=$(stat -f%z "$APK_PATH" 2>/dev/null || stat -c%s "$APK_PATH" 2>/dev/null || echo "0")
    if [ "$APK_SIZE" -gt 10000000 ] && [ "$APK_SIZE" -lt 200000000 ]; then  # 10MB - 200MB
        test_result 0 "APK size is reasonable ($(($APK_SIZE / 1024 / 1024))MB)"
    else
        test_result 1 "APK size check ($(($APK_SIZE / 1024 / 1024))MB - expected 10-200MB)"
    fi
    
else
    echo "⚠️  APK file not found, skipping all tests"
    FAILED_TESTS=$((TOTAL_TESTS + 5))  # Mark several tests as failed
fi

echo ""
echo "📋 Test Summary:"
echo "   Total Tests: $TOTAL_TESTS"
echo "   Passed: $((TOTAL_TESTS - FAILED_TESTS))"
echo "   Failed: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "🎉 All tests passed! APK is ready for release."
    exit 0
else
    echo "💥 $FAILED_TESTS test(s) failed! APK should NOT be released."
    exit 1
fi

