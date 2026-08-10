// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QueKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "QueKit", targets: ["QueKit"]),
    ],
    targets: [
        .target(
            name: "QueKit",
            resources: [.process("Library/Resources")]
        ),
        .testTarget(name: "QueKitTests", dependencies: ["QueKit"]),
    ]
)
