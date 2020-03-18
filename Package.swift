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
    .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master")),
  ],
  targets: [
    .target(
      name: "SwifyPy",
      dependencies: ["PythonKit"]),
    .target(
      name: "SwifyPyRun",
      dependencies: ["SwifyPy", "PythonKit"]),
    .testTarget(
      name: "SwifyPyTests",
      dependencies: ["SwifyPy"]),
  ]
)
