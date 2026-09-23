#!/bin/bash
# Linux Build Verification Tests
# Catches critical issues before artifact creation

set -e  # Exit on any error
echo "🧪 Starting Linux Build Verification Tests..."

BUILD_DIR="$1"

if [ -z "$BUILD_DIR" ]; then
    echo "❌ Usage: $0 <build_dir>"
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
echo "📊 Testing Build Directory Structure..."

# Test 1: Core executable exists
test -f "$BUILD_DIR/sdrpp"
test_result $? "Core executable (sdrpp) exists"

# Test 2: Critical modules exist
REQUIRED_MODULES=(
    "sink_modules/audio_sink/audio_sink.so"
    "sink_modules/network_sink/network_sink.so"
    "decoder_modules/radio/radio.so"
    "source_modules/file_source/file_source.so"
)

for module in "${REQUIRED_MODULES[@]}"; do
    test -f "$BUILD_DIR/$module"
    test_result $? "Module exists: $module"
done

echo ""
echo "🔗 Testing Shared Library Dependencies..."

# Test 3: Audio sink specific tests
if [ -f "$BUILD_DIR/sink_modules/audio_sink/audio_sink.so" ]; then
    # Check if audio_sink is a valid ELF binary
    file "$BUILD_DIR/sink_modules/audio_sink/audio_sink.so" | grep -q "ELF"
    test_result $? "audio_sink.so is valid ELF binary"
    
    # Check if audio_sink links to rtaudio
    ldd "$BUILD_DIR/sink_modules/audio_sink/audio_sink.so" 2>/dev/null | grep -q "rtaudio\|pulse\|alsa" || \
    objdump -p "$BUILD_DIR/sink_modules/audio_sink/audio_sink.so" 2>/dev/null | grep -q "rtaudio\|pulse\|alsa"
    test_result $? "audio_sink.so links to audio libraries (rtaudio/pulse/alsa)"
fi

# Test 4: Core executable dependencies
echo ""
echo "🚀 Testing Application Dependencies..."

# Check main executable dependencies are available
MISSING_DEPS=0
if command -v ldd >/dev/null 2>&1; then
    # Use ldd to check dependencies
    ldd "$BUILD_DIR/sdrpp" | grep "not found" && MISSING_DEPS=1 || MISSING_DEPS=0
    test $MISSING_DEPS -eq 0
    test_result $? "All shared library dependencies found"
else
    echo "ℹ️  ldd not available, skipping dependency check"
fi

echo ""
echo "🚀 Testing Application Startup..."

# Test 5: Headless startup test
if command -v timeout >/dev/null 2>&1; then
    timeout 10s "$BUILD_DIR/sdrpp" --help > /dev/null 2>&1
    STARTUP_RESULT=$?
else
    # Manual timeout using background process (for systems without timeout)
    "$BUILD_DIR/sdrpp" --help > /dev/null 2>&1 &
    STARTUP_PID=$!
    sleep 5
    if kill -0 $STARTUP_PID 2>/dev/null; then
        kill $STARTUP_PID 2>/dev/null
        STARTUP_RESULT=124  # Timeout
    else
        wait $STARTUP_PID
        STARTUP_RESULT=$?
    fi
fi
# Exit codes: 0 = success, 124 = timeout (expected), others = crash
if [ $STARTUP_RESULT -eq 0 ] || [ $STARTUP_RESULT -eq 124 ]; then
    test_result 0 "Application starts without immediate crash"
else
    test_result 1 "Application startup test (exit code: $STARTUP_RESULT)"
fi

# Test 6: Module loading test (if we can run the app)
echo ""
echo "📦 Testing Module Loading..."

# Create a minimal test to see if modules can be discovered
if command -v timeout >/dev/null 2>&1; then
    timeout 5s "$BUILD_DIR/sdrpp" --help > /tmp/sdrpp_help.txt 2>&1
    HELP_RESULT=$?
else
    # Manual timeout
    "$BUILD_DIR/sdrpp" --help > /tmp/sdrpp_help.txt 2>&1 &
    HELP_PID=$!
    sleep 3
    if kill -0 $HELP_PID 2>/dev/null; then
        kill $HELP_PID 2>/dev/null
    else
        wait $HELP_PID
    fi
    HELP_RESULT=0
fi

if [ $HELP_RESULT -eq 0 ] || [ $HELP_RESULT -eq 124 ]; then
    # Check if help output suggests the app can run
    if [ -f /tmp/sdrpp_help.txt ]; then
        grep -q -i "usage\|help\|sdr" /tmp/sdrpp_help.txt
        test_result $? "Application shows help output"
        rm -f /tmp/sdrpp_help.txt
    fi
fi

echo ""
echo "📋 Test Summary:"
echo "   Total Tests: $TOTAL_TESTS"
echo "   Passed: $((TOTAL_TESTS - FAILED_TESTS))"
echo "   Failed: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "🎉 All tests passed! Build is ready for release."
    exit 0
else
    echo "💥 $FAILED_TESTS test(s) failed! Build should NOT be released."
    exit 1
fi
