// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RudderFirebase",
    platforms: [
        .iOS("13.0"), .tvOS("12.0"), .macOS("10.13")
    ],
    products: [
        .library(
            name: "RudderFirebase",
            targets: ["RudderFirebase"]
        )
    ],
    dependencies: [
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk", "10.28.0"..<"10.28.1"),
        .package(name: "Rudder", url: "https://github.com/rudderlabs/rudder-sdk-ios", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "RudderFirebase",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "Firebase"),
                .product(name: "Rudder", package: "Rudder"),
            ],
            path: "Sources",
            sources: ["Classes/"]
        )
    ]
)
