//
//  OnboardingManager.swift
//  SuperTuber
//
//  Created by Cascade on 07/04/2025.
//

import Foundation

/// Manages the onboarding state of the app by storing completion status in UserDefaults
public struct OnboardingManager {
    // Configuration instance
    private static var config: OnboardingManagerConfig = OnboardingManagerConfig.shared
    
    // Convenience accessors for UserDefaults keys
    private static var hasCompletedOnboardingKey: String { config.getHasCompletedOnboardingKey() }
    private static var alwaysShowOnboardingKey: String { config.getAlwaysShowOnboardingKey() }
    
    /// Set the configuration to use
    /// - Parameter newConfig: The configuration instance
    public static func setConfig(_ newConfig: OnboardingManagerConfig) {
        config = newConfig
    }
    
    /// Checks if the user has completed the onboarding process
    /// - Parameter userDefaults: The UserDefaults instance to use (default: .standard)
    /// - Returns: Whether onboarding has been completed
    public static func hasCompletedOnboarding(userDefaults: UserDefaults = .standard) -> Bool {
        // If always show is enabled, we return false regardless of completion status
        if isAlwaysShowEnabled(userDefaults: userDefaults) {
            return false
        }
        return userDefaults.bool(forKey: hasCompletedOnboardingKey)
    }
    
    /// Marks the onboarding as completed
    /// - Parameter userDefaults: The UserDefaults instance to use (default: .standard)
    public static func setOnboardingCompleted(userDefaults: UserDefaults = .standard) {
        userDefaults.set(true, forKey: hasCompletedOnboardingKey)
    }
    
    /// Resets the onboarding state (for testing purposes)
    /// - Parameter userDefaults: The UserDefaults instance to use (default: .standard)
    public static func resetOnboardingState(userDefaults: UserDefaults = .standard) {
        userDefaults.set(false, forKey: hasCompletedOnboardingKey)
    }
    
    /// Checks if the always show onboarding option is enabled
    /// - Parameter userDefaults: The UserDefaults instance to use (default: .standard)
    /// - Returns: Whether always show onboarding is enabled
    public static func isAlwaysShowEnabled(userDefaults: UserDefaults = .standard) -> Bool {
        return userDefaults.bool(forKey: alwaysShowOnboardingKey)
    }
    
    /// Sets whether to always show onboarding on app start
    /// - Parameters:
    ///   - enabled: Whether to always show onboarding
    ///   - userDefaults: The UserDefaults instance to use (default: .standard)
    public static func setAlwaysShowOnboarding(_ enabled: Bool, userDefaults: UserDefaults = .standard) {
        userDefaults.set(enabled, forKey: alwaysShowOnboardingKey)
    }
}
