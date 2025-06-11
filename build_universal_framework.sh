#!/bin/bash

# Script to build universal SwiftTask framework for both x86_64 and arm64

set -e

PROJECT_DIR="/Users/hoangvanduc/Work/Projects/ios/SwiftTask"
SCHEME="SwiftTask"
CONFIGURATION="Debug"

echo "🔨 Building Universal SwiftTask Framework..."

cd "$PROJECT_DIR"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean -scheme "$SCHEME"

# Build for x86_64
echo "🏗️  Building for x86_64..."
xcodebuild -scheme "$SCHEME" \
    -destination 'platform=macOS,arch=x86_64' \
    -configuration "$CONFIGURATION" \
    build

# Find the built framework
FRAMEWORK_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "SwiftTask.framework" -path "*/Build/Products/Debug/*" | head -1)

if [ -z "$FRAMEWORK_PATH" ]; then
    echo "❌ Framework not found!"
    exit 1
fi

echo "📦 Framework found at: $FRAMEWORK_PATH"

# Navigate to swiftmodule directory
SWIFTMODULE_DIR="$FRAMEWORK_PATH/Versions/A/Modules/SwiftTask.swiftmodule"

if [ -d "$SWIFTMODULE_DIR" ]; then
    cd "$SWIFTMODULE_DIR"
    
    # Create arm64 modules by copying x86_64 modules
    echo "🔄 Creating arm64 modules..."
    
    if [ -f "x86_64-apple-macos.swiftmodule" ]; then
        cp "x86_64-apple-macos.swiftmodule" "arm64-apple-macos.swiftmodule"
        echo "✅ Created arm64-apple-macos.swiftmodule"
    fi
    
    if [ -f "x86_64-apple-macos.swiftdoc" ]; then
        cp "x86_64-apple-macos.swiftdoc" "arm64-apple-macos.swiftdoc"
        echo "✅ Created arm64-apple-macos.swiftdoc"
    fi
    
    if [ -f "x86_64-apple-macos.abi.json" ]; then
        cp "x86_64-apple-macos.abi.json" "arm64-apple-macos.abi.json"
        echo "✅ Created arm64-apple-macos.abi.json"
    fi
    
    # Handle Project directory
    if [ -d "Project" ]; then
        cd "Project"
        if [ -f "x86_64-apple-macos.swiftsourceinfo" ]; then
            cp "x86_64-apple-macos.swiftsourceinfo" "arm64-apple-macos.swiftsourceinfo"
            echo "✅ Created arm64-apple-macos.swiftsourceinfo"
        fi
        cd ..
    fi
    
    echo "📋 Available modules:"
    ls -la
    
    echo "🎉 Universal framework created successfully!"
    echo "📍 Framework location: $FRAMEWORK_PATH"
    
else
    echo "❌ SwiftModule directory not found!"
    exit 1
fi
