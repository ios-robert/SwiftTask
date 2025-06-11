#!/bin/bash

# Quick build script for SwiftTask universal framework

cd /Users/hoangvanduc/Work/Projects/ios/SwiftTask

echo "🔨 Building SwiftTask Universal Framework..."

xcodebuild -scheme SwiftTask \
    -destination 'platform=macOS' \
    -configuration Debug \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    VALID_ARCHS="arm64 x86_64" \
    build

echo "✅ Build completed!"

# Show framework location
FRAMEWORK_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "SwiftTask.framework" -path "*/Build/Products/Debug/*" | head -1)
if [ -n "$FRAMEWORK_PATH" ]; then
    echo "📍 Framework: $FRAMEWORK_PATH"
    echo "🏗️  Architectures:"
    lipo -info "$FRAMEWORK_PATH/Versions/A/SwiftTask"
fi
