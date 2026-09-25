// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PortKill",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "PortKillCore", path: "Sources/PortKillCore"),
        .executableTarget(
            name: "PortKill",
            dependencies: ["PortKillCore"],
            path: "Sources/PortKill"
        ),
        .testTarget(
            name: "PortKillCoreTests",
            dependencies: ["PortKillCore"],
            path: "Tests/PortKillCoreTests",
            resources: [.copy("Fixtures")]
        ),
    ]
)
