# SDR++ Test Suite

This directory contains a comprehensive test suite to verify SDR++ functionality and catch regressions.

## Available Tests

### 🏃 Quick Tests
- `./test_final_verification.sh` - **Complete verification** (recommended)
- `./run_all_tests.sh` - **Full test suite** (detailed diagnostics)

### 🔧 Individual Tests  
- `./test_app_startup.sh` - App launch and module loading
- `./test_symbol_export.sh` - Library symbol verification
- `./test_functionality.sh` - Code and build artifact checks

## What the Tests Check

### ✅ App Functionality
- App bundle structure and executables
- Module loading (radio, audio_sink, etc.)
- RtAudio stream initialization
- No crashes or JSON errors

### ✅ Symbol Resolution
- mpxRefreshRate symbol export
- Library dependency resolution
- Cross-module symbol linking

### ✅ Code Integrity
- MPX refresh rate integration
- Safe JSON config loading
- WFM demodulator MPX support

## When to Run Tests

### 🚨 Always Run Before Claiming Success
- After making core library changes
- After rebuilding modules
- Before saying "it's fixed"

### 🔍 For Debugging Issues
- When modules fail to load
- When app crashes on startup
- When audio sinks disappear

## Test Results Interpretation

### ✅ All Tests Pass
- App should launch properly
- Audio devices should appear in Sinks
- MPX analysis should work
- Audio output should function

### ❌ Tests Fail
- **Symbol errors**: Run `./test_symbol_export.sh` for details
- **Startup crashes**: Run `./test_app_startup.sh` for logs
- **Module issues**: Check build artifacts with `./test_functionality.sh`

## Fixed Issues (History)

1. **JSON Config Crash** - Fixed missing mpxRefreshRate config handling
2. **Symbol Resolution** - Fixed dual core library locations issue  
3. **Module Loading** - Fixed radio and audio_sink initialization
4. **RtAudio Streams** - Verified audio subsystem works
5. **MPX Integration** - Moved refresh rate to Display settings

---

**Remember**: The test suite prevents jumping to conclusions and ensures fixes actually work! 🎯


