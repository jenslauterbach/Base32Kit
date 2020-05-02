// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Base32Kit",
    products: [
        .library(
            name: "Base32Kit",
            targets: ["Base32Kit"])
    ],
    targets: [
        .target(
            name: "Base32Kit",
            dependencies: []),
        .testTarget(
            name: "Base32KitTests",
            dependencies: ["Base32Kit"])
    ]
)
