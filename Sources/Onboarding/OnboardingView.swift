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
    
    @Environment(\.dismiss) var dismiss
    
    /// Creates an onboarding view with the default view model and configuration
    public init(config: OnboardingManagerConfig = OnboardingManagerConfig.shared) {
        self._viewModel = ObservedObject(wrappedValue: OnboardingViewModel(config: config))
    }
    
    /// Creates an onboarding view with custom steps
    public init(
        steps: [OnboardingStep],
        config: OnboardingManagerConfig = OnboardingManagerConfig.shared
    ) {
        self._viewModel = ObservedObject(wrappedValue: OnboardingViewModel(steps: steps, config: config))
        
    }
    
    /// Creates an onboarding view with a mix of standard steps and a custom SwiftUI view
    public init<V: CustomOnboardingView>(
        steps: [OnboardingStep],
        customView: V,
        customViewPosition: Int,
        customViewTitle: String,
        customViewDescription: String,
        isLastStep: Bool = false,
        config: OnboardingManagerConfig = OnboardingManagerConfig.shared
    ) {
        // Create a copy of the steps array
        var modifiedSteps = steps
        
        // Create a custom step with the provided SwiftUI view
        let customStep = OnboardingStep(
            title: customViewTitle,
            description: customViewDescription,
            customView: customView,
            isLastStep: isLastStep
        )
        
        // Insert the custom step at the specified position, or append if position is out of bounds
        if customViewPosition >= 0 && customViewPosition <= steps.count {
            modifiedSteps.insert(customStep, at: customViewPosition)
        } else {
            modifiedSteps.append(customStep)
        }
        
        // Update the step indices and isLastStep property
        for i in 0..<modifiedSteps.count {
            var step = modifiedSteps[i]
            step.currentStepIndex = i
            step.totalSteps = modifiedSteps.count
            step.isLastStep = (i == modifiedSteps.count - 1) ? true : step.isLastStep
            modifiedSteps[i] = step
        }
        
        self._viewModel = ObservedObject(wrappedValue: OnboardingViewModel(steps: modifiedSteps, config: config))
    }
    
    // Removed the separate customSteps parameter initializer to simplify the API
    
    /// Creates an onboarding view with a custom SwiftUI view as a step
    public init<V: View>(
        customView: V,
        title: String = "",
        description: String = "",
        isLastStep: Bool = true,
        config: OnboardingManagerConfig = OnboardingManagerConfig.shared
    ) {
        // Create a wrapper for the custom view to conform to CustomOnboardingView
        let wrappedView = CustomViewWrapper(content: customView)
        
        // Create a single step with the custom view
        let step = OnboardingStep(
            title: title,
            description: description,
            customView: wrappedView,
            isLastStep: isLastStep,
            currentStepIndex: 0,
            totalSteps: 1
        )
        
        self._viewModel = ObservedObject(wrappedValue: OnboardingViewModel(steps: [step], config: config))
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
                    dismiss()
                    viewModel.skipOnboarding()
                },
                onDidFinish: {
                    dismiss()
                    viewModel.nextStep()
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
                textOverlayStyle: viewModel.textOverlayStyle,
                enableSwipeNavigation: viewModel.isSwipeNavigationEnabled
                
            )
            .animation(.easeInOut, value: viewModel.currentStepIndex)
        }
        .onDisappear {
            // Clean up video resources when the view disappears
            NotificationCenter.default.post(name: NSNotification.Name("OnboardingViewDismissed"), object: nil)
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
