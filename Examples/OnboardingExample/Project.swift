//
//  Project.swift
//  SwiftMarketingKit
//
//  Created on 15/04/2025.
//

import ProjectDescription

let project = Project(
    name: "OnboardingExample",
    organizationName: "SwiftMarketingKit",
    options: .options(
        automaticSchemesOptions: .disabled,
        disableBundleAccessors: false,
        disableSynthesizedResourceAccessors: false
    ),
    packages: [
        .local(path: "../../")
    ],
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "YOUR_TEAM_ID",
            "MARKETING_VERSION": "1.0.0",
            "CURRENT_PROJECT_VERSION": "1",
            "IPHONEOS_DEPLOYMENT_TARGET": "16.0"
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        Target(
            name: "OnboardingExample",
            platform: .iOS,
            product: .app,
            bundleId: "com.swiftmarketingkit.onboardingexample",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: [.iphone, .ipad]),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [
                        "UIWindowSceneSessionRoleApplication": [
                            [
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                            ]
                        ]
                    ]
                ],
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)"
            ]),
            sources: ["**/*.swift"],
            resources: ["Resources/**"],
            dependencies: [
                .package(product: "Onboarding")
            ]
        )
    ]
)
