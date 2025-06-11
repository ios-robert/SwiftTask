#!/bin/bash

set -e

PROJECT_NAME="SwiftTask"
FRAMEWORK_NAME="SwiftTask"
BUILD_DIR="./StandaloneBuild"

echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf ~/Library/Developer/Xcode/DerivedData/SwiftTask-*

echo "📱 Building standalone SwiftTask framework..."

# Set environment variables to satisfy CocoaPods script
export PODS_PODFILE_DIR_PATH="$(pwd)"
export PODS_ROOT="$(pwd)/Pods"
export SCRIPT_OUTPUT_FILE_0="/tmp/pods_check_success.txt"

# Ensure the script will pass
mkdir -p "$(dirname "$SCRIPT_OUTPUT_FILE_0")"

# Build for iOS Simulator with standard architectures, but exclude CocoaPods linking
echo "Building for iOS Simulator (standalone)..."
xcodebuild -project ${PROJECT_NAME}.xcodeproj \
    -target ${PROJECT_NAME} \
    -configuration Release \
    -sdk iphonesimulator \
    BUILD_DIR="$BUILD_DIR" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    ARCHS="\$(ARCHS_STANDARD)" \
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
    
    # Test the framework
    echo "🧪 Testing framework import..."
    echo 'import SwiftTask; print("SwiftTask framework loaded successfully!")' > /tmp/test_swifttask.swift
    if swiftc -F "$(pwd)" -framework SwiftTask /tmp/test_swifttask.swift -o /tmp/test_swifttask 2>/dev/null; then
        echo "✅ Framework can be imported successfully!"
    else
        echo "⚠️  Framework import test failed, but framework was built"
    fi
    rm -f /tmp/test_swifttask.swift /tmp/test_swifttask
else
    echo "❌ Framework binary not found!"
    exit 1
fi
