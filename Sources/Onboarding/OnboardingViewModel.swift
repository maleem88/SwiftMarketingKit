//
//  OnboardingViewModel.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 15/04/2025.
//

import Foundation
import SwiftUI

/// The view model that manages the onboarding flow state
@MainActor
public class OnboardingViewModel: ObservableObject {
    // MARK: - Configuration
    private let config: OnboardingManagerConfig
    
    // MARK: - Published Properties
    /// The steps to display in the onboarding flow
    @Published public var steps: [OnboardingStep] = OnboardingStep.sampleSteps
    
    /// The index of the currently displayed step
    @Published public var currentStepIndex: Int = 0
    
    /// Whether the onboarding flow is currently being shown
    @Published public var showOnboarding: Bool = true
    
    /// Closure that will be called when onboarding is completed
    public var onOnboardingCompleted: (() -> Void)?
    
    /// Closure that will be called when onboarding is skipped
    public var onOnboardingSkipped: (() -> Void)?
    
    // MARK: - Computed Properties
    /// The current step being displayed, with updated index information
    public var currentStep: OnboardingStep {
        // Create a new step with the updated currentStepIndex
        var step = steps[currentStepIndex]
        // This ensures the step always has the correct currentStepIndex
        return OnboardingStep(
            id: step.id,
            title: step.title,
            description: step.description,
            mediaType: step.mediaType,
            mediaSource: step.mediaSource,
            isLastStep: step.isLastStep,
            currentStepIndex: currentStepIndex,
            totalSteps: steps.count
        )
    }
    
    /// Whether the current step is the last one
    public var isLastStep: Bool { currentStep.isLastStep }
    
    /// Whether the current step is the first one
    public var isFirstStep: Bool { currentStepIndex == 0 }
    
    // MARK: - Dependencies
    private let onboardingManager: OnboardingManager.Type
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    /// Initialize with default settings
    public init(persistCompletion: Bool = true, config: OnboardingManagerConfig = OnboardingManagerConfig.shared, userDefaults: UserDefaults = .standard) {
        self.onboardingManager = OnboardingManager.self
        self.persistCompletion = persistCompletion
        self.config = config
        self.userDefaults = userDefaults
    }
    
    /// Initialize with custom steps
    public init(steps: [OnboardingStep], persistCompletion: Bool = true, config: OnboardingManagerConfig = OnboardingManagerConfig.shared, userDefaults: UserDefaults = .standard) {
        self.steps = steps
        self.onboardingManager = OnboardingManager.self
        self.persistCompletion = persistCompletion
        self.config = config
        self.userDefaults = userDefaults
    }
    
    // MARK: - Configuration
    private let persistCompletion: Bool
    
    // MARK: - Actions
    
    /// Advance to the next step or complete onboarding if on the last step
    public func nextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        } else {
            completeOnboarding()
        }
    }
    
    /// Go back to the previous step if not on the first step
    public func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    /// Skip the entire onboarding flow
    public func skipOnboarding() {
        showOnboarding = false
        if persistCompletion {
            onboardingManager.setOnboardingCompleted(userDefaults: userDefaults)
        }
        onOnboardingSkipped?()
    }
    
    /// Complete the onboarding flow
    public func completeOnboarding() {
        showOnboarding = false
        if persistCompletion {
            onboardingManager.setOnboardingCompleted(userDefaults: userDefaults)
        }
        onOnboardingCompleted?()
    }
    
    // MARK: - Configuration Access Methods
    
    /// Get the background color for onboarding screens
    public var backgroundColor: Color {
        return config.getBackgroundColor()
    }
    
    /// Get the primary color for buttons and highlights
    public var primaryColor: Color {
        return config.getPrimaryColor()
    }
    
    /// Get the secondary color for inactive elements
    public var secondaryColor: Color {
        return config.getSecondaryColor()
    }
    
    /// Get the font for titles
    public var titleFont: Font {
        return config.getTitleFont()
    }
    
    /// Get the font for descriptions
    public var descriptionFont: Font {
        return config.getDescriptionFont()
    }
    
    /// Get the font for buttons
    public var buttonFont: Font {
        return config.getButtonFont()
    }
    
    /// Get the progress indicator style
    public var progressIndicatorStyle: OnboardingManagerConfig.ProgressIndicatorStyle {
        return config.getProgressIndicatorStyle()
    }
    
    /// Check if phone frame is enabled
    public var isPhoneFrameEnabled: Bool {
        return config.isPhoneFrameEnabled()
    }
    
    /// Get the text for the next button
    public var nextButtonText: String {
        return config.getNextButtonText()
    }
    
    /// Get the text for the previous button
    public var previousButtonText: String {
        return config.getPreviousButtonText()
    }
    
    /// Get the text for the skip button
    public var skipButtonText: String {
        return config.getSkipButtonText()
    }
    
    /// Get the text for the get started button
    public var getStartedButtonText: String {
        return config.getGetStartedButtonText()
    }
    
    /// Check if skip button should be shown
    public var shouldShowSkipButton: Bool {
        return config.shouldShowSkipButton()
    }
    
    /// Check if progress indicator should be shown
    public var shouldShowProgressIndicator: Bool {
        return config.shouldShowProgressIndicator()
    }
    
    /// Check if swipe navigation is enabled
    public var isSwipeNavigationEnabled: Bool {
        return config.isSwipeNavigationEnabled()
    }
    
    /// Check if videos should auto-play
    public var shouldAutoPlayVideos: Bool {
        return config.shouldAutoPlayVideos()
    }
}
