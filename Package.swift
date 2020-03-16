// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwifyPy",
    products: [
        .library(
            name: "SwifyPy",
            targets: ["SwifyPy"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwifyPy",
            dependencies: []),
        .target(
          name: "SwifyPyRun",
          dependencies: ["SwifyPy"]),
        .testTarget(
            name: "SwifyPyTests",
            dependencies: ["SwifyPy"]),
    ]
)
