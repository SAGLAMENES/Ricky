// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RickyConfiguration",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RickyConfiguration",
            targets: ["RickyConfiguration"]),
    ],
    targets: [
        .target(
            name: "RickyConfiguration"
        )
    ]
)