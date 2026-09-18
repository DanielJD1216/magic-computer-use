// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JevMacPrototype",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "JevCore",
            targets: ["JevCore"]
        ),
        .executable(
            name: "JevMacShell",
            targets: ["JevMacShell"]
        )
    ],
    targets: [
        .target(
            name: "JevCore"
        ),
        .executableTarget(
            name: "JevMacShell",
            dependencies: ["JevCore"]
        ),
        .testTarget(
            name: "JevCoreTests",
            dependencies: ["JevCore"]
        )
    ]
)
