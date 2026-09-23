#!/bin/bash

echo "=== Testing End-to-End Functionality ==="

# 1. Test MPX Refresh Rate setting availability in display.cpp
echo "1. Testing MPX Refresh Rate setting availability:"
if grep -q "MPX Refresh Rate" core/src/gui/menus/display.cpp; then
    echo "✅ PASS: MPX Refresh Rate setting found in Display menu code"
else
    echo "❌ FAIL: MPX Refresh Rate setting NOT found in Display menu code"
fi

# 2. Test mpxRefreshRate variable declaration in display.h
echo ""
echo "2. Testing mpxRefreshRate variable declaration:"
if grep -q "extern int mpxRefreshRate;" core/src/gui/menus/display.h; then
    echo "✅ PASS: mpxRefreshRate extern declaration found"
else
    echo "❌ FAIL: mpxRefreshRate extern declaration NOT found"
fi

# 3. Test mpxRefreshRate variable definition in display.cpp
echo ""
echo "3. Testing mpxRefreshRate variable definition:"
if grep -q "int mpxRefreshRate = 10;" core/src/gui/menus/display.cpp; then
    echo "✅ PASS: mpxRefreshRate variable definition found"
else
    echo "❌ FAIL: mpxRefreshRate variable definition NOT found"
fi

# 4. Test WFM demodulator includes display.h
echo ""
echo "4. Testing WFM demodulator includes:"
if grep -q "#include <gui/menus/display.h>" decoder_modules/radio/src/demodulators/wfm.h; then
    echo "✅ PASS: WFM demodulator includes display.h"
else
    echo "❌ FAIL: WFM demodulator does NOT include display.h"
fi

# 5. Test WFM demodulator uses displaymenu::mpxRefreshRate
echo ""
echo "5. Testing WFM demodulator usage:"
if grep -q "displaymenu::mpxRefreshRate" decoder_modules/radio/src/demodulators/wfm.h; then
    echo "✅ PASS: WFM demodulator uses displaymenu::mpxRefreshRate"
else
    echo "❌ FAIL: WFM demodulator does NOT use displaymenu::mpxRefreshRate"
fi

# 6. Test build artifact existence and timestamps
echo ""
echo "6. Testing build artifacts:"
APP_CORE_LIB="SDR++CE.app/Contents/MacOS/libsdrpp_core.dylib"
FRAMEWORKS_CORE_LIB="SDR++CE.app/Contents/Frameworks/libsdrpp_core.dylib" 
BUILD_CORE_LIB="build/core/libsdrpp_core.dylib"
RADIO_MODULE="SDR++CE.app/Contents/Plugins/radio.dylib"
AUDIO_SINK="SDR++CE.app/Contents/Plugins/audio_sink.dylib"

echo "Build directory core library:"
if [ -f "$BUILD_CORE_LIB" ]; then
    echo "✅ EXISTS: $BUILD_CORE_LIB"
    ls -la "$BUILD_CORE_LIB"
else
    echo "❌ MISSING: $BUILD_CORE_LIB"
fi

echo ""
echo "App bundle MacOS core library:"
if [ -f "$APP_CORE_LIB" ]; then
    echo "✅ EXISTS: $APP_CORE_LIB"
    ls -la "$APP_CORE_LIB"
else
    echo "❌ MISSING: $APP_CORE_LIB"
fi

echo ""
echo "App bundle Frameworks core library:"
if [ -f "$FRAMEWORKS_CORE_LIB" ]; then
    echo "✅ EXISTS: $FRAMEWORKS_CORE_LIB"
    ls -la "$FRAMEWORKS_CORE_LIB"
else
    echo "❌ MISSING: $FRAMEWORKS_CORE_LIB"
fi

echo ""
echo "Radio module:"
if [ -f "$RADIO_MODULE" ]; then
    echo "✅ EXISTS: $RADIO_MODULE"
    ls -la "$RADIO_MODULE"
else
    echo "❌ MISSING: $RADIO_MODULE"
fi

echo ""
echo "Audio sink:"
if [ -f "$AUDIO_SINK" ]; then
    echo "✅ EXISTS: $AUDIO_SINK"
    ls -la "$AUDIO_SINK"
else
    echo "❌ MISSING: $AUDIO_SINK"
fi

echo "=== Functionality Test Complete ==="