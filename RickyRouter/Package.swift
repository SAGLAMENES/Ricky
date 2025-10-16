// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "RickyRouter",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RickyRouter",
            targets: ["RickyRouter"]),
    ],
    dependencies: [
        .package(path: "../RickyDomain")
    ],
    targets: [
        .target(
            name: "RickyRouter",
            dependencies: [
                .product(name: "RickyDomain", package: "RickyDomain")
            ]
        )
    ]
)
