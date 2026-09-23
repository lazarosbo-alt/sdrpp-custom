#!/bin/bash
# macOS Build Verification Tests
# Catches critical issues before artifact creation

set -e  # Exit on any error
echo "🧪 Starting macOS Build Verification Tests..."

BUILD_DIR="$1"
BUNDLE_PATH="$2"

if [ -z "$BUILD_DIR" ] || [ -z "$BUNDLE_PATH" ]; then
    echo "❌ Usage: $0 <build_dir> <bundle_path>"
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
test -f "$BUILD_DIR/sdrpp_ce"
test_result $? "Core executable (sdrpp_ce) exists"

# Test 2: Critical modules exist
REQUIRED_MODULES=(
    "sink_modules/audio_sink/audio_sink.dylib"
    "sink_modules/network_sink/network_sink.dylib"
    "decoder_modules/radio/radio.dylib"
    "source_modules/file_source/file_source.dylib"
)

for module in "${REQUIRED_MODULES[@]}"; do
    test -f "$BUILD_DIR/$module"
    test_result $? "Module exists: $module"
done

echo ""
echo "📦 Testing macOS App Bundle Structure..."

if [ -d "$BUNDLE_PATH" ]; then
    # Test 3: App bundle structure
    test -f "$BUNDLE_PATH/Contents/Info.plist"
    test_result $? "Info.plist exists"
    
    test -f "$BUNDLE_PATH/Contents/MacOS/sdrpp_ce"
    test_result $? "Bundle executable exists"
    
    test -d "$BUNDLE_PATH/Contents/Resources"
    test_result $? "Resources directory exists"
    
    test -d "$BUNDLE_PATH/Contents/Plugins"
    test_result $? "Plugins directory exists"
    
    # Test 4: Critical plugins in bundle
    BUNDLE_REQUIRED_MODULES=(
        "audio_sink.dylib"
        "network_sink.dylib"
        "radio.dylib"
        "file_source.dylib"
    )
    
    for module in "${BUNDLE_REQUIRED_MODULES[@]}"; do
        test -f "$BUNDLE_PATH/Contents/Plugins/$module"
        test_result $? "Bundle contains: $module"
    done
    
    # Test 5: Audio sink specific tests
    if [ -f "$BUNDLE_PATH/Contents/Plugins/audio_sink.dylib" ]; then
        # Check if audio_sink has proper architecture
        file "$BUNDLE_PATH/Contents/Plugins/audio_sink.dylib" | grep -q "Mach-O"
        test_result $? "audio_sink.dylib is valid Mach-O binary"
        
        # Check if audio_sink links to rtaudio
        otool -L "$BUNDLE_PATH/Contents/Plugins/audio_sink.dylib" | grep -q "rtaudio"
        test_result $? "audio_sink.dylib links to rtaudio"
    fi
    
    # Test 6: Bundle dependencies
    echo ""
    echo "🔗 Testing Bundle Dependencies..."
    
    # Check main executable dependencies
    MISSING_DEPS=$(otool -L "$BUNDLE_PATH/Contents/MacOS/sdrpp_ce" | grep -v "@rpath" | grep -v "/usr/lib" | grep -v "/System/Library" | grep -v "sdrpp_ce:" | grep "/" | wc -l)
    test $MISSING_DEPS -eq 0
    test_result $? "Main executable has no external dependencies"
    
    # Test 7: Configuration and resources
    test -f "$BUNDLE_PATH/Contents/Resources/sdrppce.icns"
    test_result $? "App icon exists"
    
else
    echo "⚠️  App bundle not found, skipping bundle tests"
fi

echo ""
echo "🚀 Testing Application Startup..."

# Test 8: Headless startup test (if bundle exists)
if [ -d "$BUNDLE_PATH" ]; then
    # Use gtimeout if available, otherwise manual timeout
    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout 10s "$BUNDLE_PATH/Contents/MacOS/sdrpp_ce" --help > /dev/null 2>&1
        STARTUP_RESULT=$?
    else
        # Manual timeout using background process
        "$BUNDLE_PATH/Contents/MacOS/sdrpp_ce" --help > /dev/null 2>&1 &
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
else
    # Test build directory executable if bundle doesn't exist
    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout 10s "$BUILD_DIR/sdrpp_ce" --help > /dev/null 2>&1
        STARTUP_RESULT=$?
    else
        # Manual timeout using background process
        "$BUILD_DIR/sdrpp_ce" --help > /dev/null 2>&1 &
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
    if [ $STARTUP_RESULT -eq 0 ] || [ $STARTUP_RESULT -eq 124 ]; then
        test_result 0 "Build directory executable starts without immediate crash"
    else
        test_result 1 "Build directory executable startup test (exit code: $STARTUP_RESULT)"
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
