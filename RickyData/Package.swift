// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RickyData",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RickyData",
            targets: ["RickyData"]),
    ],
    dependencies: [
        .package(path: "../RickyDomain"),
        .package(path: "../RickyNetwork"),
        .package(path: "../RickyNetworkInterface"),
        .package(path: "../RickyPersistance"),
        .package(path: "../RickyModel"),
        .package(path: "../RickyConfiguration")
    ],
    targets: [
        .target(
            name: "RickyData",
            dependencies: [
                .product(name: "RickyDomain", package: "RickyDomain"),
                .product(name: "RickyNetwork", package: "RickyNetwork"),
                .product(name: "RickyNetworkInterface", package: "RickyNetworkInterface"),
                .product(name: "RickyPersistance", package: "RickyPersistance"),
                .product(name: "RickyModel", package: "RickyModel"),
                .product(name: "RickyConfiguration", package: "RickyConfiguration")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "RickyDataTests",
            dependencies: ["RickyData"]
        ),
    ]
)
