#!/bin/bash
# Master Test Runner for SDR++ Community Edition CI/CD
# Runs appropriate tests based on detected platform and available artifacts

set -e
echo "🧪 SDR++ Community Edition - CI/CD Test Suite"
echo "=============================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Detect platform
case "$(uname -s)" in
    Darwin*)
        PLATFORM="macOS"
        ;;
    Linux*)
        PLATFORM="Linux"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        PLATFORM="Windows"
        ;;
    *)
        PLATFORM="Unknown"
        ;;
esac

echo "🖥️  Detected Platform: $PLATFORM"
echo ""

TOTAL_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "🔍 Running: $test_name"
    echo "   Command: $test_command"
    
    if eval "$test_command"; then
        echo "✅ $test_name: PASSED"
    else
        echo "❌ $test_name: FAILED"
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
    echo ""
}

# Run platform-specific tests
case "$PLATFORM" in
    "macOS")
        echo "🍎 Running macOS Tests..."
        
        # Look for build directory
        BUILD_DIR=""
        for dir in "build" "build_macos" "../build"; do
            if [ -d "$PROJECT_ROOT/$dir" ] && [ -f "$PROJECT_ROOT/$dir/sdrpp_ce" ]; then
                BUILD_DIR="$PROJECT_ROOT/$dir"
                break
            fi
        done
        
        if [ -n "$BUILD_DIR" ]; then
            echo "📁 Found build directory: $BUILD_DIR"
            
            # Look for app bundle
            BUNDLE_PATH=""
            for bundle in "$PROJECT_ROOT/SDR++CE.app" "$PROJECT_ROOT/../SDR++CE.app" "$PROJECT_ROOT/SDR++.app" "$PROJECT_ROOT/../SDR++.app"; do
                if [ -d "$bundle" ]; then
                    BUNDLE_PATH="$bundle"
                    break
                fi
            done
            
            if [ -n "$BUNDLE_PATH" ]; then
                echo "📦 Found app bundle: $BUNDLE_PATH"
                run_test "macOS Build + Bundle Tests" "$SCRIPT_DIR/test_macos_build.sh '$BUILD_DIR' '$BUNDLE_PATH'"
            else
                echo "⚠️  No app bundle found, testing build directory only"
                run_test "macOS Build Tests" "$SCRIPT_DIR/test_macos_build.sh '$BUILD_DIR' ''"
            fi
        else
            echo "❌ No macOS build directory found"
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi
        ;;
        
    "Linux")
        echo "🐧 Running Linux Tests..."
        
        # Look for build directory
        BUILD_DIR=""
        for dir in "build" "build_linux" "../build"; do
            if [ -d "$PROJECT_ROOT/$dir" ] && [ -f "$PROJECT_ROOT/$dir/sdrpp" ]; then
                BUILD_DIR="$PROJECT_ROOT/$dir"
                break
            fi
        done
        
        if [ -n "$BUILD_DIR" ]; then
            echo "📁 Found build directory: $BUILD_DIR"
            run_test "Linux Build Tests" "$SCRIPT_DIR/test_linux_build.sh '$BUILD_DIR'"
        else
            echo "❌ No Linux build directory found"
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi
        ;;
        
    "Windows")
        echo "🪟 Running Windows Tests..."
        
        # Look for build directory (Windows)
        BUILD_DIR=""
        for dir in "build" "build_windows" "../build"; do
            if [ -d "$PROJECT_ROOT/$dir" ] && [ -f "$PROJECT_ROOT/$dir/sdrpp_ce.exe" ]; then
                BUILD_DIR="$PROJECT_ROOT/$dir"
                break
            fi
        done
        
        if [ -n "$BUILD_DIR" ]; then
            echo "📁 Found build directory: $BUILD_DIR"
            
            # Look for package directory
            PACKAGE_DIR=""
            for pkg in "$PROJECT_ROOT/windows_package" "$PROJECT_ROOT/../windows_package" "$PROJECT_ROOT/package"; do
                if [ -d "$pkg" ] && [ -f "$pkg/sdrpp_ce.exe" ]; then
                    PACKAGE_DIR="$pkg"
                    break
                fi
            done
            
            if [ -n "$PACKAGE_DIR" ]; then
                echo "📦 Found package directory: $PACKAGE_DIR"
                run_test "Windows Build + Package Tests" "powershell -ExecutionPolicy Bypass -File '$SCRIPT_DIR/test_windows_build.ps1' -BuildDir '$BUILD_DIR' -PackageDir '$PACKAGE_DIR'"
            else
                echo "⚠️  No Windows package found, testing build directory only"
                run_test "Windows Build Tests" "powershell -ExecutionPolicy Bypass -File '$SCRIPT_DIR/test_windows_build.ps1' -BuildDir '$BUILD_DIR'"
            fi
        else
            echo "❌ No Windows build directory found"
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi
        ;;
        
    *)
        echo "❓ Unknown platform, attempting generic tests..."
        
        # Try to find any build
        for dir in "build" "../build"; do
            if [ -d "$PROJECT_ROOT/$dir" ]; then
                echo "📁 Found build directory: $PROJECT_ROOT/$dir"
                ls -la "$PROJECT_ROOT/$dir/"
                break
            fi
        done
        ;;
esac

# Look for Android APK
echo "📱 Checking for Android APK..."
APK_PATH=""
for apk in "$PROJECT_ROOT"/*.apk "$PROJECT_ROOT/../"*.apk "$PROJECT_ROOT/android/app/build/outputs/apk"/**/*.apk; do
    if [ -f "$apk" ]; then
        APK_PATH="$apk"
        echo "📦 Found APK: $APK_PATH"
        run_test "Android APK Tests" "$SCRIPT_DIR/test_android_build.sh '$APK_PATH'"
        break
    fi
done

if [ -z "$APK_PATH" ]; then
    echo "ℹ️  No Android APK found, skipping Android tests"
fi

# Final summary
echo ""
echo "🏁 Test Suite Complete"
echo "======================"

if [ $TOTAL_FAILED -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED! Build artifacts are ready for release."
    echo ""
    echo "✅ Quality Gates:"
    echo "   • Core executables present and functional"
    echo "   • Critical modules included (audio_sink, radio, etc.)"
    echo "   • Application startup successful"
    echo "   • Dependencies properly linked"
    echo "   • Configuration files valid"
    exit 0
else
    echo "💥 $TOTAL_FAILED TEST SUITE(S) FAILED!"
    echo ""
    echo "❌ Issues Detected:"
    echo "   • Build artifacts may be incomplete"
    echo "   • Critical functionality may be broken" 
    echo "   • Release should be BLOCKED until issues are resolved"
    echo ""
    echo "🔧 Recommended Actions:"
    echo "   1. Review test output above for specific failures"
    echo "   2. Fix identified issues in build configuration"
    echo "   3. Rebuild and re-test before release"
    exit 1
fi

