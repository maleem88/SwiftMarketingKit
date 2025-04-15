//
//  OnboardingStepView.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 07/04/2025.
//

import SwiftUI

/// A view that displays a single step in the onboarding process
public struct OnboardingStepView: View {
    /// The onboarding step to display
    public let step: OnboardingStep
    /// Whether this is the first step in the sequence
    public let isFirstStep: Bool
    /// Action to perform when the next button is tapped
    public let onNext: () -> Void
    /// Action to perform when the previous button is tapped
    public let onPrevious: () -> Void
    /// Action to perform when the skip button is tapped
    public let onSkip: () -> Void
    
    /// Creates a new onboarding step view
    public init(step: OnboardingStep, isFirstStep: Bool, onNext: @escaping () -> Void, onPrevious: @escaping () -> Void, onSkip: @escaping () -> Void) {
        self.step = step
        self.isFirstStep = isFirstStep
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.onSkip = onSkip
    }
    
    public var body: some View {
        ZStack {
            // Background color
            Color("appBackgroundLight")
                .ignoresSafeArea()
            
            // Phone frame positioned to extend below text area
            step.mediaType.view(source: step.mediaSource)
                
//                .offset(y: -UIScreen.main.bounds.height * 0.05) // Move phone frame up slightly
            
            // Gradient overlay for text area at bottom
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.black.opacity(0), location: 0),
                        .init(color: Color.black.opacity(0.8), location: 0.3),
                        .init(color: Color.black, location: 0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: UIScreen.main.bounds.height * 0.4) // Text area height
            }
            .ignoresSafeArea()
            
            // Content overlay positioned absolutely
            VStack(spacing: 0) {
                
                HStack {
                    Spacer()
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Bottom content area with text and controls
                VStack(spacing: 16) {
                    Spacer()
                    
                    // Progress indicator dots above text
                    HStack(spacing: 8) {
                        ForEach(0..<step.totalSteps, id: \.self) { index in
                            Circle()
                                .fill(index == step.currentStepIndex ? Color.white : Color.white.opacity(0.4))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == step.currentStepIndex ? 1.2 : 1.0)
                                .animation(.spring(), value: step.currentStepIndex)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Text content
                    VStack(spacing: 16) {
                        Text(step.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        
                        Text(step.description)
                            .font(.body)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                    .padding(.horizontal, 24)
                    
                    // Navigation buttons in a single row
                    HStack {
                        // Left side: Skip and Previous buttons
//                        HStack(spacing: 12) {
                            // Skip button
                            
                            
                            // Previous button (hidden on first step)
                            if !isFirstStep {
                                Button(action: onPrevious) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
//                                        Text("Back")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Capsule().fill(Color.black.opacity(0.3)))
                                }
                            }
//                        }
                        
                        Spacer()
                        
                        // Right side: Next/Get Started button
                        Button(action: onNext) {
                            HStack(spacing: 8) {
                                Text(step.isLastStep ? "Get Started" : "Next")
                                Image(systemName: step.isLastStep ? "arrow.right.circle.fill" : "chevron.right")
                                    .font(.system(size: 18))
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                
            }
//            .padding(.vertical)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingStepView(
        step: OnboardingStep(
            id: "welcome",
            title: "Welcome to SuperTuber",
            description: "Your personal YouTube summary assistant that helps you get the most out of your videos.",
            mediaType: .image,
            mediaSource: "onboarding_welcome",
            isLastStep: false,
            currentStepIndex: 0,
            totalSteps: 4
        ),
        isFirstStep: true,
        onNext: {},
        onPrevious: {},
        onSkip: {}
    )
}
