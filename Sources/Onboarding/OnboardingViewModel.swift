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
    
    // MARK: - Initialization
    
    /// Initialize with default settings
    public init(persistCompletion: Bool = true) {
        self.onboardingManager = OnboardingManager.self
        self.persistCompletion = persistCompletion
    }
    
    /// Initialize with custom steps
    public init(steps: [OnboardingStep], persistCompletion: Bool = true) {
        self.steps = steps
        self.onboardingManager = OnboardingManager.self
        self.persistCompletion = persistCompletion
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
            onboardingManager.setOnboardingCompleted()
        }
        onOnboardingSkipped?()
    }
    
    /// Complete the onboarding flow
    public func completeOnboarding() {
        showOnboarding = false
        if persistCompletion {
            onboardingManager.setOnboardingCompleted()
        }
        onOnboardingCompleted?()
    }
}
