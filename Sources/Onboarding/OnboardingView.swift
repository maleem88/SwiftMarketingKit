//
//  OnboardingView.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 07/04/2025.
//

import SwiftUI

/// A view that presents an onboarding flow with customizable steps
public struct OnboardingView: View {
    /// The view model that manages the onboarding state
    @ObservedObject private var viewModel: OnboardingViewModel
    
    /// Creates an onboarding view with the default view model and configuration
    public init(config: OnboardingManagerConfig = OnboardingManagerConfig.shared) {
        self._viewModel = ObservedObject(wrappedValue: OnboardingViewModel(config: config))
    }
    
    /// Creates an onboarding view with custom steps
    public init(steps: [OnboardingStep], config: OnboardingManagerConfig = OnboardingManagerConfig.shared) {
        self._viewModel = ObservedObject(wrappedValue: OnboardingViewModel(steps: steps, config: config))
    }
    
    /// Creates an onboarding view with a custom view model
    public init(viewModel: OnboardingViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            // Background color from config
            viewModel.backgroundColor.ignoresSafeArea()
            
            // Current step view with updated step information
            OnboardingStepView(
                step: viewModel.currentStep,
                isFirstStep: viewModel.isFirstStep,
                onNext: {
                    viewModel.nextStep()
                },
                onPrevious: {
                    viewModel.previousStep()
                },
                onSkip: {
                    viewModel.skipOnboarding()
                },
                // Pass configuration values from view model
                primaryColor: viewModel.primaryColor,
                secondaryColor: viewModel.secondaryColor,
                titleFont: viewModel.titleFont,
                descriptionFont: viewModel.descriptionFont,
                buttonFont: viewModel.buttonFont,
                nextButtonText: viewModel.nextButtonText,
                previousButtonText: viewModel.previousButtonText,
                skipButtonText: viewModel.skipButtonText,
                getStartedButtonText: viewModel.getStartedButtonText,
                showSkipButton: viewModel.shouldShowSkipButton,
                showProgressIndicator: viewModel.shouldShowProgressIndicator,
                progressIndicatorStyle: viewModel.progressIndicatorStyle,
                enableSwipeNavigation: viewModel.isSwipeNavigationEnabled
            )
            .animation(.easeInOut, value: viewModel.currentStepIndex)
        }
    }
}

#Preview {
    // Create a custom configuration for the preview
    let config = OnboardingManagerConfig.shared
        .setPrimaryColor(.blue)
        .setBackgroundColor(Color(.systemBackground))
    
    return OnboardingView(config: config)
}
