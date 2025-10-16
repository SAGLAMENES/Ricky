// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RickyNetwork",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RickyNetwork",
            targets: ["RickyNetwork"]
        ),
    ],
    dependencies: [
        .package(path: "../RickyModel"),
        .package(path: "../RickyNetworkInterface")
    ],
    targets: [
        .target(
            name: "RickyNetwork",
            dependencies: [
                "RickyModel",
                "RickyNetworkInterface"
            ],
            path: "Sources"
        )
    ]
)
