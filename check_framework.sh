#!/bin/bash

# Quick check for SwiftTask Universal Framework

FRAMEWORK_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "SwiftTask.framework" -path "*/Build/Products/Debug/*" | head -1)

if [ -n "$FRAMEWORK_PATH" ]; then
    echo "✅ SwiftTask Framework Found"
    echo "📍 Location: $FRAMEWORK_PATH"
    echo ""
    echo "🏗️  Binary Architectures:"
    lipo -info "$FRAMEWORK_PATH/Versions/A/SwiftTask"
    echo ""
    echo "📦 Swift Modules:"
    MODULE_COUNT=$(ls "$FRAMEWORK_PATH/Versions/A/Modules/SwiftTask.swiftmodule/" | grep -E "(arm64|x86_64)" | wc -l)
    echo "   Found $MODULE_COUNT architecture-specific modules"
    echo ""
    echo "🎉 Status: Ready for Apple Silicon Playground!"
else
    echo "❌ SwiftTask Framework not found"
    echo "💡 Run ./build_universal.sh to build it"
fi
