// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Coil",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Coil",
            targets: ["Coil"]),
    ],
    targets: [
        .target(
            name: "Coil",
            dependencies: []),
        .testTarget(
            name: "CoilTests",
            dependencies: ["Coil"]),
    ]
)
