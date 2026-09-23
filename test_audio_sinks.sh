#!/bin/bash

echo "=== Testing Audio Sink Detection ==="

# Test 1: Check if audio_sink module is properly loaded and registered
echo "1. Testing if audio_sink module registers itself:"
timeout 15s SDR++CE.app/Contents/MacOS/sdrpp_ce --help >/dev/null 2>sink_test.log &
APP_PID=$!
sleep 10
kill $APP_PID 2>/dev/null
wait $APP_PID 2>/dev/null

if grep -q "Loading.*audio_sink" sink_test.log; then
    echo "✅ PASS: audio_sink module loading detected"
else
    echo "❌ FAIL: audio_sink module not loading"
fi

if grep -q "audio_sink.*registered" sink_test.log; then
    echo "✅ PASS: audio_sink module registered"
else
    echo "❌ FAIL: audio_sink module not registered"
fi

echo ""

# Test 2: Check for audio sink loading errors
echo "2. Testing for audio sink errors:"
if grep -i "audio.*error\|sink.*error\|rtaudio.*error" sink_test.log; then
    echo "❌ FAIL: Audio sink errors detected"
else
    echo "✅ PASS: No audio sink errors detected"
fi

echo ""

# Test 3: Check if rtaudio is properly available
echo "3. Testing rtaudio library availability:"
if otool -L SDR++CE.app/Contents/Plugins/audio_sink.dylib | grep -q "rtaudio"; then
    echo "✅ PASS: audio_sink links to rtaudio"
    rtaudio_path=$(otool -L SDR++CE.app/Contents/Plugins/audio_sink.dylib | grep rtaudio | awk '{print $1}')
    echo "RtAudio path: $rtaudio_path"
    
    if [ -f "SDR++CE.app/Contents/Frameworks/librtaudio.7.dylib" ]; then
        echo "✅ PASS: librtaudio.7.dylib exists in app bundle"
    else
        echo "❌ FAIL: librtaudio.7.dylib missing from app bundle"
    fi
else
    echo "❌ FAIL: audio_sink does not link to rtaudio"
fi

echo ""

# Test 4: Check system audio devices
echo "4. Testing system audio devices:"
if command -v system_profiler >/dev/null; then
    audio_devices=$(system_profiler SPAudioDataType | grep -c ":")
    echo "System audio devices found: $audio_devices"
    if [ $audio_devices -gt 0 ]; then
        echo "✅ PASS: System has audio devices"
    else
        echo "❌ FAIL: No system audio devices found"
    fi
else
    echo "⚠️  SKIP: system_profiler not available"
fi

echo ""

# Test 5: Check audio framework dependencies  
echo "5. Testing audio framework dependencies:"
if otool -L SDR++CE.app/Contents/Plugins/audio_sink.dylib | grep -q "AudioToolbox\|CoreAudio"; then
    echo "✅ PASS: audio_sink uses audio frameworks"
else
    echo "❌ FAIL: audio_sink missing audio framework dependencies"
fi

echo ""
echo "=== Full sink loading log ==="
cat sink_test.log

# Cleanup
rm -f sink_test.log

echo ""
echo "=== Audio Sink Test Complete ==="

