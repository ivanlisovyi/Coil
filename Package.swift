// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "Coil",
  platforms: [
    .iOS(.v13),
    .tvOS(.v13),
    .macOS(.v10_15),
    .watchOS(.v6)
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
