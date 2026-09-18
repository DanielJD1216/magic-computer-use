// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JevCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "JevCore",
            targets: ["JevCore"]
        )
    ],
    targets: [
        .target(
            name: "JevCore"
        ),
        .testTarget(
            name: "JevCoreTests",
            dependencies: ["JevCore"]
        )
    ]
)
