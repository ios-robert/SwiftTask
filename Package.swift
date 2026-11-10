// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftTask",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
        .tvOS(.v13),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "SwiftTask", targets: ["SwiftTask"])
    ],
    targets: [
        .target(
            name: "SwiftTask",
            path: "SwiftTask",
            exclude: ["SwiftTask.h", "Info.plist"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
