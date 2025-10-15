// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RickyDI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RickyDI",
            targets: ["RickyDI"]),
    ],
    dependencies: [
        .package(path: "../RickyNetwork"),
        .package(path: "../RickyPersistance"),
        .package(path: "../RickyConfiguration"),
        .package(path: "../RickyDomain"),
        .package(path: "../RickyData")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RickyDI",
            dependencies: [
                .product(name: "RickyNetwork", package: "RickyNetwork"),
                .product(name: "RickyPersistance", package: "RickyPersistance"),
                .product(name: "RickyConfiguration", package: "RickyConfiguration"),
                .product(name: "RickyDomain", package: "RickyDomain"),
                .product(name: "RickyData", package: "RickyData")
            ],
            path: "Sources"),
        .testTarget(
            name: "RickyDITests",
            dependencies: [
                "RickyDI"
            ]
        ),
    ]
)
