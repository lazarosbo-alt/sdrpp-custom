#!/bin/bash

echo "=== Testing Sink Registration ==="

# Test 1: Check if sink module manager can find audio_sink
echo "1. Testing sink module registration:"
timeout 20s SDR++CE.app/Contents/MacOS/sdrpp_ce 2>registration_test.log &
APP_PID=$!
sleep 15
kill $APP_PID 2>/dev/null
wait $APP_PID 2>/dev/null

if grep -q "Loading.*audio_sink" registration_test.log; then
    echo "✅ PASS: audio_sink module loading started"
else
    echo "❌ FAIL: audio_sink module not being loaded"
fi

# Check for sink manager messages
if grep -i "sink.*manager\|module.*manager" registration_test.log; then
    echo "Sink manager activity:"
    grep -i "sink.*manager\|module.*manager" registration_test.log
else
    echo "⚠️  No sink manager activity detected"
fi

echo ""

# Test 2: Check for audio device enumeration 
echo "2. Testing audio device enumeration:"
if grep -i "audio.*device\|rtaudio.*device\|sink.*device" registration_test.log; then
    echo "Audio device enumeration:"
    grep -i "audio.*device\|rtaudio.*device\|sink.*device" registration_test.log
else
    echo "❌ FAIL: No audio device enumeration detected"
fi

echo ""

# Test 3: Look for specific RtAudio initialization
echo "3. Testing RtAudio initialization:"
if grep -i "rtaudio" registration_test.log; then
    echo "RtAudio activity:"
    grep -i "rtaudio" registration_test.log
else
    echo "❌ FAIL: No RtAudio initialization detected"
fi

echo ""

# Test 4: Check for missing dependencies
echo "4. Testing for missing dependencies:"
if grep -i "not found\|missing\|undefined" registration_test.log; then
    echo "❌ FAIL: Missing dependencies detected:"
    grep -i "not found\|missing\|undefined" registration_test.log
else
    echo "✅ PASS: No missing dependencies"
fi

echo ""

# Test 5: Check if audio_sink module exports the right symbols
echo "5. Testing audio_sink module symbols:"
if nm SDR++CE.app/Contents/Plugins/audio_sink.dylib | grep -i "init\|_info" | head -5; then
    echo "✅ PASS: audio_sink exports module symbols"
else
    echo "❌ FAIL: audio_sink missing module symbols"
fi

echo ""

# Test 6: Compare with working modules
echo "6. Comparing with working source modules:"
working_module=$(ls SDR++CE.app/Contents/Plugins/*_source.dylib | head -1)
if [ -n "$working_module" ]; then
    echo "Checking symbols in working module: $(basename $working_module)"
    echo "Working module symbols:"
    nm "$working_module" | grep -i "_info\|init" | head -3
    echo ""
    echo "Audio sink symbols:"
    nm SDR++CE.app/Contents/Plugins/audio_sink.dylib | grep -i "_info\|init" | head -3
else
    echo "⚠️  No working modules found for comparison"
fi

echo ""
echo "=== Full registration log ==="
cat registration_test.log

# Cleanup
rm -f registration_test.log

echo ""
echo "=== Sink Registration Test Complete ==="

