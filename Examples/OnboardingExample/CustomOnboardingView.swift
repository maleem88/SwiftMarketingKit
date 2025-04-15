//
//  CustomOnboardingView.swift
//  SwiftMarketingKit
//
//  Created on 15/04/2025.
//

import SwiftUI
import Onboarding

/// Example of a custom onboarding implementation using the SwiftMarketingKit
struct CustomOnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel(steps: [
        // Custom onboarding steps
        OnboardingStep(
            id: "welcome",
            title: "Welcome to MyApp",
            description: "The best app for managing your daily tasks and staying productive.",
            mediaType: .image,
            mediaSource: "custom_onboarding_1",
            isLastStep: false,
            currentStepIndex: 0,
            totalSteps: 3
        ),
        OnboardingStep(
            id: "features",
            title: "Powerful Features",
            description: "Track your progress, set reminders, and collaborate with your team.",
            mediaType: .image,
            mediaSource: "custom_onboarding_2",
            isLastStep: false,
            currentStepIndex: 1,
            totalSteps: 3
        ),
        OnboardingStep(
            id: "getStarted",
            title: "Let's Get Started",
            description: "Sign up now and start organizing your life!",
            mediaType: .image,
            mediaSource: "custom_onboarding_3",
            isLastStep: true,
            currentStepIndex: 2,
            totalSteps: 3
        )
    ])
    
    @State private var showOnboarding = true
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 20) {
                Text("Custom Onboarding Example")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("This example shows how to create custom onboarding steps")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Show Onboarding Again") {
                    withAnimation {
                        showOnboarding = true
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .opacity(showOnboarding ? 0.3 : 1.0)
            
            // Custom onboarding overlay
            if showOnboarding {
                OnboardingView(
                    viewModel: viewModel,
                    backgroundColor: Color.black.opacity(0.9)
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            // Set up completion handlers
            viewModel.onOnboardingCompleted = {
                withAnimation {
                    showOnboarding = false
                }
            }
            
            viewModel.onOnboardingSkipped = {
                withAnimation {
                    showOnboarding = false
                }
            }
        }
    }
}

#Preview {
    CustomOnboardingView()
}
