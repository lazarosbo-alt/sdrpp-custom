# SDR++ Community Edition - CI/CD Testing Framework

This directory contains comprehensive build quality tests that prevent broken releases from reaching users. These tests run automatically in GitHub Actions after builds complete but before artifacts are created.

## 🎯 **What This Framework Prevents**

The testing framework catches critical issues like:
- **Missing audio_sink modules** (like the recent macOS issue)
- **Broken executables** that crash on startup
- **Missing dependencies** and linking errors
- **Invalid configuration files** 
- **Malformed app bundles** and packages
- **Symbol export issues** on Windows
- **Architecture mismatches** and binary corruption

## 📋 **Test Suite Overview**

### Platform-Specific Tests

| Platform | Script | Tests Covered |
|----------|--------|---------------|
| **macOS** | `test_macos_build.sh` | Build artifacts, app bundle structure, audio_sink presence, dependency linking, startup tests |
| **Windows** | `test_windows_build.ps1` | Build artifacts, package structure, config.json validation, DLL tests, startup tests |
| **Linux** | `test_linux_build.sh` | Build artifacts, shared libraries, dependency checks, startup tests |
| **Android** | `test_android_build.sh` | APK validation, architecture support, manifest checks, size validation |

### Master Test Runner
- `run_all_tests.sh` - Automatically detects platform and runs appropriate tests

## 🔧 **Integration with GitHub Actions**

Tests are integrated into the CI/CD pipeline at these points:

```yaml
# After build completion, before artifact creation
- name: Build
  run: make -j3

- name: Create [Platform] Bundle/Package  
  run: [platform-specific bundling]

- name: Run Build Quality Tests        # ← NEW QUALITY GATE
  run: ./ci_tests/test_[platform]_build.sh

- name: Create Archive                 # ← Only runs if tests pass
  run: [create release artifact]
```

## 🧪 **Test Categories**

### 1. **Module Presence Tests**
Verifies all expected modules are built and present:
- ✅ `audio_sink.dylib/.dll/.so` - **Critical for audio output**
- ✅ `network_sink.dylib/.dll/.so` - Network streaming
- ✅ `radio.dylib/.dll/.so` - Core demodulation
- ✅ `file_source.dylib/.dll/.so` - File playback

### 2. **Audio Sink Specific Tests** 
**Prevents the audio_sink issue that caused this framework to be created:**
- ✅ Audio sink module exists in final package
- ✅ Audio sink links to required libraries (rtaudio, pulse, etc.)
- ✅ Audio sink is valid binary format (Mach-O, PE, ELF)
- ✅ Audio sink has proper architecture (x64, arm64, etc.)

### 3. **Bundle/Package Structure Tests**
- ✅ **macOS**: App bundle Info.plist, executable, Resources, Plugins
- ✅ **Windows**: Package directory structure, modules, resources
- ✅ **Linux**: Executable and module libraries present
- ✅ **Android**: APK structure, manifest, native libraries

### 4. **Configuration Validation**
- ✅ **config.json exists and is valid JSON**
- ✅ **modulesDirectory and resourcesDirectory point to correct paths**
- ✅ **No broken references or missing configuration keys**

### 5. **Startup Tests**
- ✅ **Application launches without immediate crash**
- ✅ **Help output generation (verifies basic functionality)**
- ✅ **Timeout-based testing (prevents infinite hangs)**

### 6. **Dependency Tests**
- ✅ **All required shared libraries are linked**
- ✅ **No missing dependencies in final package**
- ✅ **Architecture consistency across modules**

## 🚀 **Running Tests Locally**

### Quick Test (Auto-detect platform)
```bash
./ci_tests/run_all_tests.sh
```

### Platform-Specific Tests
```bash
# macOS
./ci_tests/test_macos_build.sh build/ SDR++CE.app

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File ./ci_tests/test_windows_build.ps1 -BuildDir "build" -PackageDir "package"

# Linux  
./ci_tests/test_linux_build.sh build/

# Android
./ci_tests/test_android_build.sh app.apk
```

## 📊 **Test Output Example**

```
🧪 Starting macOS Build Verification Tests...

📊 Testing Build Directory Structure...
✅ Core executable (sdrpp_ce) exists
✅ Module exists: sink_modules/audio_sink/audio_sink.dylib
✅ Module exists: decoder_modules/radio/radio.dylib

📦 Testing macOS App Bundle Structure...
✅ Info.plist exists
✅ Bundle executable exists  
✅ Bundle contains: audio_sink.dylib
✅ audio_sink.dylib is valid Mach-O binary
✅ audio_sink.dylib links to rtaudio

🚀 Testing Application Startup...
✅ Application starts without immediate crash

📋 Test Summary:
   Total Tests: 15
   Passed: 15
   Failed: 0
🎉 All tests passed! Build is ready for release.
```

## ❌ **Failure Scenarios**

When tests fail, **the GitHub Actions build stops** and **no artifacts are uploaded**:

```
💥 3 test(s) failed! Build should NOT be released.

❌ Issues Detected:
   • Build artifacts may be incomplete
   • Critical functionality may be broken  
   • Release should be BLOCKED until issues are resolved

🔧 Recommended Actions:
   1. Review test output above for specific failures
   2. Fix identified issues in build configuration
   3. Rebuild and re-test before release
```

## 🔍 **Adding New Tests**

To add platform-specific tests:

1. **Edit the appropriate test script** (`test_[platform]_build.sh/.ps1`)
2. **Add test cases using the `test_result` function**:
   ```bash
   # Bash example
   test -f "$BUILD_DIR/new_module.dylib"
   test_result $? "New module exists"
   
   # PowerShell example  
   Test-Result (Test-Path "$BuildDir\new_module.dll") "New module exists"
   ```
3. **Test locally** before committing
4. **Tests auto-run** in GitHub Actions

## 🎯 **Quality Gates Philosophy**

This framework implements **fail-fast quality gates**:

- ⚡ **Early Detection**: Catch issues immediately after build
- 🛑 **Fail Fast**: Stop pipeline if critical issues found  
- 🔒 **No Broken Releases**: Only working builds reach users
- 📊 **Comprehensive Coverage**: Test all critical functionality
- 🤖 **Automated**: No human intervention required
- 📝 **Clear Feedback**: Detailed failure reports for debugging

## 📈 **Benefits**

- **Prevents user frustration** from downloading broken builds
- **Catches regressions** before they reach production
- **Provides immediate feedback** to developers
- **Documents expected behavior** through tests
- **Reduces support burden** from broken releases
- **Maintains project reputation** for quality

---

### 🎉 **Success Story**

This framework was created in response to the **missing audio_sink issue** where macOS users downloaded SDR++CE builds that had no audio output capability. The GitHub Actions workflow was incorrectly disabling `audio_sink` and relying on `portaudio_sink` which wasn't working.

**With this framework, that issue would have been caught immediately:**
```
❌ Bundle contains: audio_sink.dylib
💥 1 test(s) failed! Build should NOT be released.
```

**No more broken releases reaching users!** 🎯

