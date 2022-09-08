// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JapaneseAttributesKit",
    platforms: [
        .iOS(.v15), .macOS(.v12)
    ],
    products: [
        .library(
            name: "JapaneseAttributesKit",
            targets: ["JapaneseAttributesKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JapaneseAttributesKit",
            dependencies: []),
        .testTarget(
            name: "JapaneseAttributesKitTests",
            dependencies: ["JapaneseAttributesKit"]),
    ]
)
