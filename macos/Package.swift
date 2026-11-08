// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "ZeusKit",
    platforms: [.macOS(.v27)],
    products: [.library(name: "ZeusKit", targets: ["ZeusKit"])],
    targets: [
        .executableTarget(name: "ZeusApp", dependencies: ["ZeusKit"], path: "ZeusApp"),
        .target(name: "ZeusKit"),
        .testTarget(name: "ZeusKitTests", dependencies: ["ZeusKit"]),
        // Renders key screens to PNG from fixtures for design review; see Tests/ZeusAppSnapshotTests.
        .testTarget(name: "ZeusAppSnapshotTests", dependencies: ["ZeusApp", "ZeusKit"]),
    ]
)
