// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RickyDomain",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RickyDomain",
            targets: ["RickyDomain"]),
    ],
    dependencies: [
        .package(path: "../RickyModel")
    ],
    targets: [
        .target(
            name: "RickyDomain",
            dependencies: [
                .product(name: "RickyModel", package: "RickyModel")
            ]
        )
    ]
)