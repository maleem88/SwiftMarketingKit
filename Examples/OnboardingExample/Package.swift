// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OnboardingExample",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(name: "OnboardingExample", targets: ["OnboardingExample"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "OnboardingExample",
            dependencies: [
                .product(name: "Onboarding", package: "SwiftMarketingKit")
            ],
            path: ".",
            exclude: ["README.md", "Resources/README.md"],
            resources: [.process("Resources")]
        )
    ]
)
