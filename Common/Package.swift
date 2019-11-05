// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]),
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: []),
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"]),
    ]
)
