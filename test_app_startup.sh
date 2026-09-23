#!/bin/bash

echo "=== Testing App Startup ==="

APP_PATH="SDR++CE.app"
LOG_FILE="startup_test.log"

echo "1. Testing app file structure:"
if [ -d "$APP_PATH" ]; then
    echo "✅ PASS: App bundle exists"
else
    echo "❌ FAIL: App bundle missing"
    exit 1
fi

if [ -f "$APP_PATH/Contents/MacOS/sdrpp" ]; then
    echo "✅ PASS: Main executable exists"
else
    echo "❌ FAIL: Main executable missing"
fi

if [ -d "$APP_PATH/Contents/Plugins" ]; then
    echo "✅ PASS: Plugins directory exists"
    echo "Available plugins:"
    ls -1 "$APP_PATH/Contents/Plugins" | head -5
else
    echo "❌ FAIL: Plugins directory missing"
fi

echo ""
echo "2. Testing app launch (10 second timeout):"
"$APP_PATH/Contents/MacOS/sdrpp" > "$LOG_FILE" 2>&1 &
APP_PID=$!
sleep 10
kill $APP_PID 2>/dev/null
wait $APP_PID 2>/dev/null

if [ -f "$LOG_FILE" ]; then
    echo "App output captured"
else
    echo "❌ FAIL: No output captured"
    exit 1
fi

echo ""
echo "3. Checking for critical startup errors:"
if grep -q "dylib.*not found\|Symbol not found\|Library not loaded" "$LOG_FILE"; then
    echo "❌ FAIL: Critical library errors detected:"
    grep "dylib.*not found\|Symbol not found\|Library not loaded" "$LOG_FILE"
else
    echo "✅ PASS: No critical library errors"
fi

echo ""
echo "4. Checking module loading:"
if grep -q "Loading.*dylib" "$LOG_FILE"; then
    echo "✅ PASS: Module loading detected"
    echo "Modules being loaded:"
    grep "Loading.*dylib" "$LOG_FILE" | wc -l | awk '{print $1 " modules"}'
else
    echo "❌ FAIL: No module loading detected"
fi

echo ""
echo "5. Checking if core modules initialize:"
echo "Radio module:"
if grep -q "Initializing Radio" "$LOG_FILE"; then
    echo "✅ PASS: Radio module initializes"
else
    echo "❌ FAIL: Radio module does not initialize"
fi

echo "Audio sink:"
if grep -q "Initializing Audio Sink" "$LOG_FILE"; then
    echo "✅ PASS: Audio sink initializes"
else
    echo "❌ FAIL: Audio sink does not initialize"
fi

echo "RtAudio:"
if grep -q "RtAudio stream open" "$LOG_FILE"; then
    echo "✅ PASS: RtAudio stream opens"
else
    echo "❌ FAIL: RtAudio stream does not open"
fi

echo ""
echo "6. Full startup log:"
echo "--- START LOG ---"
cat "$LOG_FILE"
echo "--- END LOG ---"

# Keep log file for debugging
echo ""
echo "Startup log saved as: $LOG_FILE"
echo "=== App Startup Test Complete ==="
