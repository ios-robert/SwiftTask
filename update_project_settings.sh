#!/bin/bash

# Script to permanently update SwiftTask project settings for universal build

set -e

PROJECT_DIR="/Users/hoangvanduc/Work/Projects/ios/SwiftTask"
PROJECT_FILE="$PROJECT_DIR/SwiftTask.xcodeproj/project.pbxproj"

echo "🔧 Updating SwiftTask project settings for universal build..."

cd "$PROJECT_DIR"

# Backup original project file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "📋 Backup created: $PROJECT_FILE.backup"

# Use PlistBuddy to update build settings
# Note: This is a simplified approach. For production, consider using xcconfig files

echo "⚙️  Updating build settings..."

# Method 1: Use sed to replace specific settings in project.pbxproj
# Replace ARCHS = x86_64 with ARCHS = "arm64 x86_64"
sed -i '' 's/ARCHS = x86_64;/ARCHS = ("arm64", "x86_64");/g' "$PROJECT_FILE"

# Replace VALID_ARCHS = "i386 x86_64" with VALID_ARCHS = "arm64 x86_64"
sed -i '' 's/VALID_ARCHS = "i386 x86_64";/VALID_ARCHS = ("arm64", "x86_64");/g' "$PROJECT_FILE"

# Replace ONLY_ACTIVE_ARCH = YES with ONLY_ACTIVE_ARCH = NO for Debug
sed -i '' 's/ONLY_ACTIVE_ARCH = YES;/ONLY_ACTIVE_ARCH = NO;/g' "$PROJECT_FILE"

echo "✅ Project settings updated successfully!"

# Build to verify
echo "🔨 Building to verify changes..."
xcodebuild -scheme SwiftTask -destination 'platform=macOS' -configuration Debug build

echo "🎉 Universal framework build completed!"
echo "📍 Framework supports both arm64 and x86_64 architectures"

# Verify the result
FRAMEWORK_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "SwiftTask.framework" -path "*/Build/Products/Debug/*" | head -1)
if [ -n "$FRAMEWORK_PATH" ]; then
    echo "🔍 Verifying framework architectures:"
    lipo -info "$FRAMEWORK_PATH/Versions/A/SwiftTask"
fi
