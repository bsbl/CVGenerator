// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CVGenerator",
    platforms: [
        .macOS(.v10_11),
    ],
    dependencies: [
        .package(url: "https://github.com/MaxDesiatov/CoreXLSX.git",
           .upToNextMajor(from: "0.9.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CVGenerator",
            dependencies: ["CoreXLSX"]),
        .testTarget(
            name: "CVGeneratorTests",
            dependencies: ["CVGenerator", "CoreXLSX"]),
    ]
)

