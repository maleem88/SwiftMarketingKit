// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMarketingKit",
    platforms: [
        .iOS(.v16),
        .watchOS(.v10),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftMarketingKit",
            targets: ["SwiftMarketingKit"]),
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]),
        .library(
            name: "EmailSupport",
            targets: ["EmailSupport"]),
        .library(
            name: "RatingsManager",
            targets: ["RatingsManager"]),
        .library(
            name: "CreditsManager",
            targets: ["CreditsManager"]),
        .library(
            name: "SubscribeManager",
            targets: ["SubscribeManager"]),
        
    ],
    dependencies: [
            .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "5.22.2")
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftMarketingKit",
            dependencies: []),
        .target(
            name: "Onboarding",
            dependencies: [],
            resources: [.process("Resources")]),
        .target(
            name: "EmailSupport",
            dependencies: []),
        .target(
            name: "RatingsManager",
            dependencies: ["EmailSupport"]),
        .target(
            name: "CreditsManager",
            dependencies: ["EmailSupport"]),
        .target(
            name: "SubscribeManager",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "RevenueCatUI", package: "purchases-ios")
            ]),
        .testTarget(
            name: "OnboardingTests",
            dependencies: ["Onboarding"])
    ]
)
