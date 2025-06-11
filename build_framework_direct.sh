#!/bin/bash

set -e

PROJECT_NAME="SwiftTask"
FRAMEWORK_NAME="SwiftTask"
BUILD_DIR="./DirectBuild"

echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf ~/Library/Developer/Xcode/DerivedData/SwiftTask-*

echo "📱 Building SwiftTask framework directly (bypassing CocoaPods)..."

# Build for iOS Simulator with both architectures
echo "Building for iOS Simulator (arm64 + x86_64)..."
xcodebuild -project ${PROJECT_NAME}.xcodeproj \
    -target ${PROJECT_NAME} \
    -configuration Release \
    -sdk iphonesimulator \
    -arch "arm64 x86_64" \
    BUILD_DIR="$BUILD_DIR" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    VALID_ARCHS="arm64 x86_64" \
    EXCLUDED_ARCHS=""

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
else
    echo "❌ Framework binary not found!"
    exit 1
fi
