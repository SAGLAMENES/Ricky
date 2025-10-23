// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "RickyAnalytics",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RickyAnalytics",
            targets: ["RickyAnalytics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.20.0")
    ],
    targets: [
        .target(
            name: "RickyAnalytics",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "RickyAnalyticsTests",
            dependencies: ["RickyAnalytics"]
        ),
    ]
)
