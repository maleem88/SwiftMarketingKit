//
//  OnboardingManager.swift
//  SuperTuber
//
//  Created by Cascade on 07/04/2025.
//

import Foundation

/// Manages the onboarding state of the app by storing completion status in UserDefaults
public struct OnboardingManager {
    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private static let alwaysShowOnboardingKey = "alwaysShowOnboarding"
    
    /// Checks if the user has completed the onboarding process
    public static func hasCompletedOnboarding() -> Bool {
        // If always show is enabled, we return false regardless of completion status
        if isAlwaysShowEnabled() {
            return false
        }
        return UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
    }
    
    /// Marks the onboarding as completed
    public static func setOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
    }
    
    /// Resets the onboarding state (for testing purposes)
    public static func resetOnboardingState() {
        UserDefaults.standard.set(false, forKey: hasCompletedOnboardingKey)
    }
    
    /// Checks if the always show onboarding option is enabled
    public static func isAlwaysShowEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: alwaysShowOnboardingKey)
    }
    
    /// Sets whether to always show onboarding on app start
    public static func setAlwaysShowOnboarding(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: alwaysShowOnboardingKey)
    }
}
