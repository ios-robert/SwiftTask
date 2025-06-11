#!/bin/bash

set -e

PROJECT_NAME="SwiftTask"
FRAMEWORK_NAME="SwiftTask"
BUILD_DIR="./UniversalBuild"

echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf ~/Library/Developer/Xcode/DerivedData/SwiftTask-*

echo "📱 Building for iOS Simulator (arm64 + x86_64)..."

# Build for iOS Simulator arm64 (Apple Silicon)
echo "Building for iOS Simulator arm64..."
xcodebuild -workspace ${PROJECT_NAME}.xcworkspace \
    -scheme ${PROJECT_NAME} \
    -configuration Release \
    -sdk iphonesimulator \
    -arch arm64 \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    BUILD_DIR="$BUILD_DIR/arm64" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO

# Build for iOS Simulator x86_64 (Intel)
echo "Building for iOS Simulator x86_64..."
xcodebuild -workspace ${PROJECT_NAME}.xcworkspace \
    -scheme ${PROJECT_NAME} \
    -configuration Release \
    -sdk iphonesimulator \
    -arch x86_64 \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    BUILD_DIR="$BUILD_DIR/x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO

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

# Copy Swift modules for both architectures
MODULES_DIR="$UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"
mkdir -p "$MODULES_DIR"

# Copy arm64 modules
if [ -d "$BUILD_DIR/arm64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule" ]; then
    cp -R "$BUILD_DIR/arm64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/"* "$MODULES_DIR/"
fi

# Copy x86_64 modules
if [ -d "$BUILD_DIR/x86_64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule" ]; then
    cp -R "$BUILD_DIR/x86_64/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/"* "$MODULES_DIR/"
fi

echo "✅ Universal framework created at: $UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework"

# Verify the universal binary
echo "🔍 Verifying universal binary architectures:"
lipo -info "$UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

echo "📋 Available Swift modules:"
ls -la "$MODULES_DIR/" || echo "No Swift modules found"

echo "🎉 Build completed successfully!"
echo "📁 Universal framework location: $(pwd)/$UNIVERSAL_DIR/${FRAMEWORK_NAME}.framework"
