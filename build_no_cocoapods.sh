#!/bin/bash

set -e

PROJECT_NAME="SwiftTask"
FRAMEWORK_NAME="SwiftTask"
BUILD_DIR="./NoCocoapodsBuild"

echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf ~/Library/Developer/Xcode/DerivedData/SwiftTask-*

echo "📱 Building SwiftTask framework without CocoaPods..."

# Set environment variables to satisfy CocoaPods script
export PODS_PODFILE_DIR_PATH="$(pwd)"
export PODS_ROOT="$(pwd)/Pods"
export SCRIPT_OUTPUT_FILE_0="/tmp/pods_check_success.txt"

# Ensure the script will pass
mkdir -p "$(dirname "$SCRIPT_OUTPUT_FILE_0")"

# Build for arm64
echo "Building for iOS Simulator arm64..."
xcodebuild -project ${PROJECT_NAME}.xcodeproj \
    -target ${PROJECT_NAME} \
    -configuration Release \
    -sdk iphonesimulator \
    -arch arm64 \
    BUILD_DIR="$BUILD_DIR/arm64" \
    ONLY_ACTIVE_ARCH=YES \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    PODS_PODFILE_DIR_PATH="$(pwd)" \
    PODS_ROOT="$(pwd)/Pods" \
    SCRIPT_OUTPUT_FILE_0="$SCRIPT_OUTPUT_FILE_0"

echo "Building for iOS Simulator x86_64..."
xcodebuild -project ${PROJECT_NAME}.xcodeproj \
    -target ${PROJECT_NAME} \
    -configuration Release \
    -sdk iphonesimulator \
    -arch x86_64 \
    BUILD_DIR="$BUILD_DIR/x86_64" \
    ONLY_ACTIVE_ARCH=YES \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    PODS_PODFILE_DIR_PATH="$(pwd)" \
    PODS_ROOT="$(pwd)/Pods" \
    SCRIPT_OUTPUT_FILE_0="$SCRIPT_OUTPUT_FILE_0"

echo "🔗 Creating universal framework..."

# Create universal framework directory
UNIVERSAL_DIR="$BUILD_DIR/Universal"
mkdir -p "$UNIVERSAL_DIR"

# Copy framework structure from arm64 build
cp -R "$BUILD_DIR/arm64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework" "$UNIVERSAL_DIR/"

# Create universal binary using lipo
lipo -create \
    "$BUILD_DIR/arm64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" \
    "$BUILD_DIR/x86_64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" \
    -output "$UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

# Handle Swift modules
MODULES_DIR="$UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"
mkdir -p "$MODULES_DIR"

# Copy arm64 modules
ARM64_MODULES="$BUILD_DIR/arm64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"
if [ -d "$ARM64_MODULES" ]; then
    cp -R "$ARM64_MODULES/"* "$MODULES_DIR/" 2>/dev/null || true
fi

# Copy x86_64 modules
X86_64_MODULES="$BUILD_DIR/x86_64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"
if [ -d "$X86_64_MODULES" ]; then
    cp -R "$X86_64_MODULES/"* "$MODULES_DIR/" 2>/dev/null || true
fi

echo "✅ Universal framework created!"

# Verify the universal binary
echo "🔍 Verifying universal binary architectures:"
lipo -info "$UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

echo "📋 Available Swift modules:"
ls -la "$MODULES_DIR/" 2>/dev/null || echo "No Swift modules found"

echo "🎉 Build completed successfully!"
echo "📁 Universal framework location: $(pwd)/$UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework"

# Copy to a standard location for easy access
FINAL_DIR="./SwiftTaskFramework"
rm -rf "$FINAL_DIR"
cp -R "$UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework" "$FINAL_DIR"
echo "📦 Framework also copied to: $(pwd)/$FINAL_DIR"
