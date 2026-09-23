#!/bin/bash

echo "=== Testing Module Loading ==="

# Test 1: Check if app loads without errors
echo "1. Testing app launch for module loading errors:"
timeout 10s SDR++CE.app/Contents/MacOS/sdrpp_ce --help >/dev/null 2>app_errors.log

if grep -q "Symbol not found" app_errors.log; then
    echo "❌ FAIL: Symbol not found errors detected:"
    grep "Symbol not found" app_errors.log
else
    echo "✅ PASS: No symbol errors detected"
fi

if grep -q "Module.*doesn't exist" app_errors.log; then
    echo "❌ FAIL: Module loading errors detected:"
    grep "Module.*doesn't exist" app_errors.log
else
    echo "✅ PASS: No module loading errors detected"
fi

echo ""

# Test 2: Check if audio_sink module file exists and is accessible
echo "2. Testing audio_sink module file:"
if [ -f "SDR++CE.app/Contents/Plugins/audio_sink.dylib" ]; then
    echo "✅ PASS: audio_sink.dylib file exists"
    ls -la SDR++CE.app/Contents/Plugins/audio_sink.dylib
else
    echo "❌ FAIL: audio_sink.dylib file missing"
fi

echo ""

# Test 3: Check if radio module file exists and is accessible  
echo "3. Testing radio module file:"
if [ -f "SDR++CE.app/Contents/Plugins/radio.dylib" ]; then
    echo "✅ PASS: radio.dylib file exists"
    ls -la SDR++CE.app/Contents/Plugins/radio.dylib
else
    echo "❌ FAIL: radio.dylib file missing"
fi

echo ""

# Test 4: Quick dlopen test (if available)
echo "4. Testing library loading:"
if command -v python3 >/dev/null; then
    python3 -c "
import ctypes
import sys
try:
    lib = ctypes.CDLL('./SDR++CE.app/Contents/MacOS/libsdrpp_core.dylib')
    print('✅ PASS: Core library loads successfully')
except Exception as e:
    print(f'❌ FAIL: Core library load error: {e}')

try:
    lib = ctypes.CDLL('./SDR++CE.app/Contents/Plugins/audio_sink.dylib')
    print('✅ PASS: Audio sink loads successfully') 
except Exception as e:
    print(f'❌ FAIL: Audio sink load error: {e}')
"
else
    echo "⚠️  SKIP: Python3 not available for dlopen test"
fi

echo ""
echo "=== Module Loading Test Complete ==="

# Cleanup
rm -f app_errors.log

