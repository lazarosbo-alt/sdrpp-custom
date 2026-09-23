#!/bin/bash

echo "=== Testing Symbol Export ==="

APP_PATH="SDR++CE.app"
CORE_LIB_MACOS="$APP_PATH/Contents/MacOS/libsdrpp_core.dylib"
CORE_LIB_FRAMEWORKS="$APP_PATH/Contents/Frameworks/libsdrpp_core.dylib"
RADIO_LIB="$APP_PATH/Contents/Plugins/radio.dylib"
AUDIO_SINK_LIB="$APP_PATH/Contents/Plugins/audio_sink.dylib"

echo "1. Checking if mpxRefreshRate symbol exists in MacOS core library:"
if [ -f "$CORE_LIB_MACOS" ]; then
    if nm -g "$CORE_LIB_MACOS" 2>/dev/null | grep -q "__ZN11displaymenu14mpxRefreshRateE"; then
        echo "✅ PASS: mpxRefreshRate symbol found in MacOS core library"
    else
        echo "❌ FAIL: mpxRefreshRate symbol NOT found in MacOS core library"
    fi
else
    echo "❌ FAIL: MacOS core library does not exist"
fi

echo ""
echo "2. Checking if mpxRefreshRate symbol exists in Frameworks core library:"
if [ -f "$CORE_LIB_FRAMEWORKS" ]; then
    if nm -g "$CORE_LIB_FRAMEWORKS" 2>/dev/null | grep -q "__ZN11displaymenu14mpxRefreshRateE"; then
        echo "✅ PASS: mpxRefreshRate symbol found in Frameworks core library"
    else
        echo "❌ FAIL: mpxRefreshRate symbol NOT found in Frameworks core library"
    fi
else
    echo "❌ FAIL: Frameworks core library does not exist"
fi

echo ""
echo "3. Checking radio module dependencies:"
if [ -f "$RADIO_LIB" ]; then
    echo "Radio module dependencies:"
    otool -L "$RADIO_LIB" | grep "@rpath/libsdrpp_core.dylib"
    echo "✅ PASS: radio.dylib exists"
else
    echo "❌ FAIL: radio.dylib does NOT exist"
fi

echo ""
echo "4. Checking audio_sink dependencies:"
if [ -f "$AUDIO_SINK_LIB" ]; then
    echo "Audio sink dependencies:"
    otool -L "$AUDIO_SINK_LIB" | grep "@rpath/libsdrpp_core.dylib"
    otool -L "$AUDIO_SINK_LIB" | grep "@rpath/librtaudio.7.dylib"
    echo "✅ PASS: audio_sink.dylib exists"
else
    echo "❌ FAIL: audio_sink.dylib does NOT exist"
fi

echo "=== Symbol Export Test Complete ==="