// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ricky",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Ricky",
            targets: ["Ricky"])
    ],
    dependencies: [
        .package(path: "./RickyAppCore"),
        .package(path: "./RickyConfiguration"),
        .package(path: "./RickyDI"),
        .package(path: "./RickyData"),
        .package(path: "./RickyDesignSystem"),
        .package(path: "./RickyDomain"),
        .package(path: "./RickyModel"),
        .package(path: "./RickyNetwork"),
        .package(path: "./RickyNetworkInterface"),
        .package(path: "./RickyPersistance"),
        .package(path: "./RickyRouter")
    ],
    targets: [
        .target(
            name: "Ricky",
            dependencies: [
                .product(name: "RickyAppCore", package: "RickyAppCore"),
                .product(name: "RickyConfiguration", package: "RickyConfiguration"),
                .product(name: "RickyDI", package: "RickyDI"),
                .product(name: "RickyData", package: "RickyData"),
                .product(name: "RickyDesignSystem", package: "RickyDesignSystem"),
                .product(name: "RickyDomain", package: "RickyDomain"),
                .product(name: "RickyModel", package: "RickyModel"),
                .product(name: "RickyNetwork", package: "RickyNetwork"),
                .product(name: "RickyNetworkInterface", package: "RickyNetworkInterface"),
                .product(name: "RickyPersistance", package: "RickyPersistance"),
                .product(name: "RickyRouter", package: "RickyRouter")
            ]
        )
    ]
)
