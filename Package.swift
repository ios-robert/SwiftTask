// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftTask",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4)
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
