//
//  SubscribeManagerConfig.swift
//  SwiftMarketingKit
//
//  Created on 2025-04-17.
//

import Foundation
import RevenueCat
import SwiftUI

/// Central configuration class for the SubscribeManager module
public class SubscribeManagerConfig {
    /// Shared instance of the configuration
    public static let shared = SubscribeManagerConfig()
    
    /// RevenueCat API key
    private var apiKey: String?
    
    /// Entitlement identifier for premium features (default: "premium")
    private var entitlementIdentifier: String = "premium"
    
    /// Features to display in the subscription view
    private var features: [SubscribeFeature]?
    
    // UI Customization options
    
    /// Title for the subscribe view (default: "Unlock Premium Features" or "Premium Features" when premium)
    private var subscribeViewTitle: String? = nil
    
    /// Whether to show feature descriptions (default: false)
    private var showFeatureDescriptions: Bool = false
    
    /// Whether to show the app icon beside the title (default: true)
    private var showIconBesideTitle: Bool = true
    
    /// Whether to show the features section title (default: true)
    private var showFeaturesTitle: Bool = true
    
    /// Features section title (default: "Premium Features")
    private var featuresTitle: String = "Premium Features"
    
    /// Tint color for the subscribe view (default: .black)
    private var tintColor: Color = .black
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Configure RevenueCat with the provided API key
    /// - Parameter apiKey: Your RevenueCat API key
    /// - Parameter observerMode: Whether to enable observer mode (default: false)
    public static func configureRevenueCat(apiKey: String, observerMode: Bool = false) {
        shared.apiKey = apiKey
        
        // Configure RevenueCat SDK
        
        Purchases.configure(withAPIKey: apiKey)
        
//        Purchases.configure(
//            with: Configuration.builder(withAPIKey: apiKey)
//                .with(observerMode: observerMode)
//                .build()
//        )
        
    }
    
    /// Set the entitlement identifier for premium features
    /// - Parameter identifier: The entitlement identifier (default: "premium")
    public static func setEntitlementIdentifier(_ identifier: String) {
        shared.entitlementIdentifier = identifier
    }
    
    /// Get the current entitlement identifier
    /// - Returns: The current entitlement identifier
    public static func getEntitlementIdentifier() -> String {
        return shared.entitlementIdentifier
    }
    
    /// Set the features to display in the subscription view
    /// - Parameter features: Array of SubscribeFeature objects
    public static func setFeatures(_ features: [SubscribeFeature]) {
        shared.features = features
    }
    
    /// Get the features to display in the subscription view
    /// - Returns: Array of SubscribeFeature objects, or default features if not set
    public static func getFeatures() -> [SubscribeFeature] {
        return shared.features ?? SubscribeFeature.defaultFeatures
    }
    
    // MARK: - UI Customization Methods
    
    /// Set the title for the subscribe view
    /// - Parameter title: The title to display (nil for default)
    public static func setSubscribeViewTitle(_ title: String?) {
        shared.subscribeViewTitle = title
    }
    
    /// Get the title for the subscribe view
    /// - Parameter isPremium: Whether the user has premium status
    /// - Returns: The title to display
    public static func getSubscribeViewTitle(isPremium: Bool) -> String {
        if let customTitle = shared.subscribeViewTitle {
            return customTitle
        }
        return isPremium ? "Premium Features" : "Unlock Premium Features"
    }
    
    /// Set whether to show feature descriptions
    /// - Parameter show: Whether to show descriptions
    public static func setShowFeatureDescriptions(_ show: Bool) {
        shared.showFeatureDescriptions = show
    }
    
    /// Get whether to show feature descriptions
    /// - Returns: Whether to show descriptions
    public static func shouldShowFeatureDescriptions() -> Bool {
        return shared.showFeatureDescriptions
    }
    
    /// Set whether to show the app icon beside the title
    /// - Parameter show: Whether to show the icon
    public static func setShowIconBesideTitle(_ show: Bool) {
        shared.showIconBesideTitle = show
    }
    
    /// Get whether to show the app icon beside the title
    /// - Returns: Whether to show the icon
    public static func shouldShowIconBesideTitle() -> Bool {
        return shared.showIconBesideTitle
    }
    
    /// Set whether to show the features section title
    /// - Parameter show: Whether to show the title
    public static func setShowFeaturesTitle(_ show: Bool) {
        shared.showFeaturesTitle = show
    }
    
    /// Get whether to show the features section title
    /// - Returns: Whether to show the title
    public static func shouldShowFeaturesTitle() -> Bool {
        return shared.showFeaturesTitle
    }
    
    /// Set the features section title
    /// - Parameter title: The title to display
    public static func setFeaturesTitle(_ title: String) {
        shared.featuresTitle = title
    }
    
    /// Get the features section title
    /// - Returns: The title to display
    public static func getFeaturesTitle() -> String {
        return shared.featuresTitle
    }
    
    /// Set the tint color for the subscribe view
    /// - Parameter color: The color to use for tinting UI elements
    public static func setTintColor(_ color: Color) {
        shared.tintColor = color
    }
    
    /// Get the tint color for the subscribe view
    /// - Returns: The tint color
    public static func getTintColor() -> Color {
        return shared.tintColor
    }
}
