#!/bin/bash

echo "=== FINAL STATUS TEST ==="

# Test 1: Verify symbol issues are resolved
echo "1. Testing symbol resolution:"
if SDR++CE.app/Contents/MacOS/sdrpp_ce --help 2>&1 | grep -q "Symbol not found.*mpxRefreshRate"; then
    echo "❌ FAIL: Still has mpxRefreshRate symbol error"
else
    echo "✅ PASS: No mpxRefreshRate symbol errors"
fi

echo ""

# Test 2: Verify radio module loads
echo "2. Testing radio module loading:"
if SDR++CE.app/Contents/MacOS/sdrpp_ce --help 2>&1 | grep -q "Initializing Radio"; then
    echo "✅ PASS: Radio module loads and initializes"
else
    echo "❌ FAIL: Radio module not loading"
fi

echo ""

# Test 3: Verify audio sink loads and initializes
echo "3. Testing audio sink status:"
if SDR++CE.app/Contents/MacOS/sdrpp_ce --help 2>&1 | grep -q "Initializing Audio Sink"; then
    echo "✅ PASS: Audio sink loads and initializes"
else
    echo "❌ FAIL: Audio sink not initializing"
fi

echo ""

# Test 4: Verify RtAudio stream opens
echo "4. Testing RtAudio functionality:"
if SDR++CE.app/Contents/MacOS/sdrpp_ce --help 2>&1 | grep -q "RtAudio stream open"; then
    echo "✅ PASS: RtAudio stream opens successfully"
else
    echo "❌ FAIL: RtAudio stream not opening"
fi

echo ""

# Test 5: Verify MPX Refresh Rate setting exists
echo "5. Testing MPX Refresh Rate setting:"
if grep -q "MPX Refresh Rate" core/src/gui/menus/display.cpp; then
    echo "✅ PASS: MPX Refresh Rate setting in Display menu"
else
    echo "❌ FAIL: MPX Refresh Rate setting missing"
fi

echo ""

# Test 6: Verify all libraries have required symbols
echo "6. Testing library symbol exports:"
echo "Core library mpxRefreshRate symbol:"
if nm SDR++CE.app/Contents/Frameworks/libsdrpp_core.dylib | grep -q "mpxRefreshRate"; then
    echo "✅ PASS: Core library exports mpxRefreshRate"
else
    echo "❌ FAIL: Core library missing mpxRefreshRate"
fi

echo "Audio sink module symbols:"
if nm SDR++CE.app/Contents/Plugins/audio_sink.dylib | grep -q "__INFO_\|__INIT_"; then
    echo "✅ PASS: Audio sink has module symbols"
else
    echo "❌ FAIL: Audio sink missing module symbols"
fi

echo ""
echo "=== SUMMARY ==="
echo "Expected results:"
echo "- Radio module should load (enables MPX analysis)"
echo "- Audio sink should initialize with RtAudio stream"
echo "- Sinks section in UI should show audio devices"
echo "- MPX Refresh Rate control should be in Display settings"
echo ""
echo "If Sinks section is still empty, it may be a UI issue"
echo "or audio permissions issue, not a module loading problem."
echo ""
echo "=== FINAL STATUS TEST COMPLETE ==="

