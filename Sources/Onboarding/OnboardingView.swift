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
    
    /// Background color for the onboarding view
    private let backgroundColor: Color
    
    /// Creates an onboarding view with the default view model
    public init(backgroundColor: Color = Color(UIColor.systemBackground)) {
        self._viewModel = ObservedObject(wrappedValue: OnboardingViewModel())
        self.backgroundColor = backgroundColor
    }
    
    /// Creates an onboarding view with a custom view model
    public init(viewModel: OnboardingViewModel, backgroundColor: Color = Color(UIColor.systemBackground)) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        ZStack {
            // Background color
            backgroundColor.ignoresSafeArea()
            
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
                }
            )
            .animation(.easeInOut, value: viewModel.currentStepIndex)
        }
    }
}

#Preview {
    OnboardingView()
}
