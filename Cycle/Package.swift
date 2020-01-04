// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Cycle",
    platforms: [
        .iOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Cycle",
            targets: ["Cycle"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Cycle",
            dependencies: []),
        .testTarget(
            name: "CycleTests",
            dependencies: ["Cycle"]),
    ]
)
