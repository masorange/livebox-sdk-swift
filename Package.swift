// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Livebox",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Livebox", targets: ["Livebox"]),
        .library(name: "LiveboxAsync", targets: ["LiveboxAsync"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "Livebox", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(
            name: "LiveboxAsync",
            dependencies: ["Livebox"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "LiveboxTests",
            dependencies: [
                "Livebox",
                "LiveboxAsync",
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
