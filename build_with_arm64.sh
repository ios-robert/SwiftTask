#!/bin/bash

set -e

PROJECT_NAME="SwiftTask"
FRAMEWORK_NAME="SwiftTask"
BUILD_DIR="./ARM64Build"

echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf ~/Library/Developer/Xcode/DerivedData/SwiftTask-*

echo "📱 Building SwiftTask framework with ARM64 support..."

# Set environment variables to satisfy CocoaPods script
export PODS_PODFILE_DIR_PATH="$(pwd)"
export PODS_ROOT="$(pwd)/Pods"
export SCRIPT_OUTPUT_FILE_0="/tmp/pods_check_success.txt"

# Ensure the script will pass
mkdir -p "$(dirname "$SCRIPT_OUTPUT_FILE_0")"

# Build with updated architecture settings
echo "Building for iOS Simulator with ARM64 + x86_64 support..."
xcodebuild -project ${PROJECT_NAME}.xcodeproj \
    -target ${PROJECT_NAME} \
    -configuration Release \
    -sdk iphonesimulator \
    BUILD_DIR="$BUILD_DIR" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    ARCHS="arm64 x86_64" \
    VALID_ARCHS="arm64 x86_64" \
    EXCLUDED_ARCHS="" \
    PODS_PODFILE_DIR_PATH="$(pwd)" \
    PODS_ROOT="$(pwd)/Pods" \
    SCRIPT_OUTPUT_FILE_0="$SCRIPT_OUTPUT_FILE_0" \
    OTHER_LDFLAGS=""

echo "✅ Framework built successfully!"

# Verify the binary
FRAMEWORK_PATH="$BUILD_DIR/Release-iphonesimulator/${FRAMEWORK_NAME}.framework"
if [ -f "$FRAMEWORK_PATH/${FRAMEWORK_NAME}" ]; then
    echo "🔍 Verifying framework architectures:"
    lipo -info "$FRAMEWORK_PATH/${FRAMEWORK_NAME}"
    
    echo "📋 Swift modules available:"
    ls -la "$FRAMEWORK_PATH/Modules/${FRAMEWORK_NAME}.swiftmodule/" 2>/dev/null || echo "No Swift modules directory found"
    
    echo "🎉 Build completed successfully!"
    echo "📁 Framework location: $(pwd)/$FRAMEWORK_PATH"
    
    # Copy to a standard location for easy access
    FINAL_DIR="./SwiftTaskFramework"
    rm -rf "$FINAL_DIR"
    cp -R "$FRAMEWORK_PATH" "$FINAL_DIR"
    echo "📦 Framework also copied to: $(pwd)/$FINAL_DIR"
    
    # Verify architectures in final framework
    echo "🔍 Final framework architectures:"
    lipo -info "$FINAL_DIR/${FRAMEWORK_NAME}" 2>/dev/null || echo "Binary not found in final framework"
    
else
    echo "❌ Framework binary not found!"
    exit 1
fi
