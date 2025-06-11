#!/bin/bash

# Universal SwiftTask Framework Builder
# This script builds SwiftTask framework with both arm64 and x86_64 architectures

set -e

PROJECT_DIR="/Users/hoangvanduc/Work/Projects/ios/SwiftTask"
cd "$PROJECT_DIR"

echo "🔨 Building Universal SwiftTask Framework..."
echo "📍 Project: $PROJECT_DIR"

# Clean previous build
echo "🧹 Cleaning previous build..."
xcodebuild clean -scheme SwiftTask > /dev/null 2>&1

# Build universal framework
echo "🏗️  Building for both architectures..."
xcodebuild -scheme SwiftTask \
    -destination 'platform=macOS' \
    -configuration Debug \
    build

# Find and verify framework
FRAMEWORK_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "SwiftTask.framework" -path "*/Build/Products/Debug/*" | head -1)

if [ -n "$FRAMEWORK_PATH" ]; then
    echo "✅ Build completed successfully!"
    echo "📍 Framework: $FRAMEWORK_PATH"
    echo "🏗️  Architectures:"
    lipo -info "$FRAMEWORK_PATH/Versions/A/SwiftTask"
    
    echo ""
    echo "📦 Swift Modules:"
    ls "$FRAMEWORK_PATH/Versions/A/Modules/SwiftTask.swiftmodule/" | grep -E "(arm64|x86_64)" | sort
    
    echo ""
    echo "🎉 Universal framework is ready for Playground!"
    echo "💡 You can now use this framework in Swift Playgrounds on Apple Silicon Mac"
else
    echo "❌ Framework not found!"
    exit 1
fi
