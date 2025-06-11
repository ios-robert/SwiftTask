#!/bin/bash

# Build SwiftTask framework for iOS Simulator
echo "Building SwiftTask framework for iOS Simulator..."

# Build for iOS Simulator
xcodebuild -project SwiftTask.xcodeproj \
    -target SwiftTask \
    -configuration Debug \
    -sdk iphonesimulator \
    -arch x86_64 \
    -arch arm64 \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    BUILD_DIR="./build"

echo "Build completed. Framework should be in ./build/Debug-iphonesimulator/"
