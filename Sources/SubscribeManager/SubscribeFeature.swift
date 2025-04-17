//
//  SubscribeFeature.swift
//  SwiftMarketingKit
//
//  Created on 2025-04-17.
//

import SwiftUI

public struct SubscribeFeature: Identifiable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let description: String
    
    public init(icon: String, title: String, description: String) {
        self.icon = icon
        self.title = title
        self.description = description
    }
}

public extension SubscribeFeature {
    /// Default premium features that can be easily customized
    static var defaultFeatures: [SubscribeFeature] = [
        SubscribeFeature(
            icon: "lock.open.fill",
            title: "Ad-Free Experience",
            description: "No ads, no interruptions, just pure focus"
        ),
        SubscribeFeature(
            icon: "sparkles",
            title: "Premium Tools",
            description: "Unlock advanced features that make your workflow easier"
        ),
        SubscribeFeature(
            icon: "envelope.open.fill",
            title: "Priority Support",
            description: "Get help when you need it with our fast and friendly support team"
        ),
        SubscribeFeature(
            icon: "person.badge.key.fill",
            title: "Exclusive Content",
            description: "Get access to exclusive content, tips and resources only available to subscribers"
        )
    ]
    
    /// Add a custom feature to the default features list
    static func addFeature(icon: String, title: String, description: String) {
        defaultFeatures.append(SubscribeFeature(icon: icon, title: title, description: description))
    }
    
    /// Replace all default features with a custom set
    static func setCustomFeatures(_ features: [SubscribeFeature]) {
        defaultFeatures = features
    }
}
