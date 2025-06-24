//
//  MinimalVideoOnboardingExample.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 21/06/2025.
//

import SwiftUI

/// An example view demonstrating video onboarding with minimal text overlay
public struct MinimalVideoOnboardingExample: View {
    @State private var currentIndex = 0
    @State private var steps: [OnboardingStep] = []
    
    public init() {
        // Initialize with empty steps, we'll load them in onAppear
    }
    
    public var body: some View {
        ZStack {
            // Black background for the onboarding
            Color.black.ignoresSafeArea()
            
            if steps.isEmpty {
                // Loading placeholder
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                // Demonstration of both styles side by side
                VStack(spacing: 0) {
                    // Title
                    Text("Video Onboarding Styles")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                    
                    // Style selector
                    Picker("Style", selection: $currentIndex) {
                        Text("Standard Style").tag(0)
                        Text("Minimal Style").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    
                    // Onboarding view with selected style
                    if currentIndex == 0 {
                        // Standard style
                        standardStyleView
                            .transition(.opacity)
                    } else {
                        // Minimal style
                        minimalStyleView
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: currentIndex)
            }
        }
        .onAppear {
            // Load video sample steps
            steps = OnboardingManagerConfig.shared.getVideoSampleSteps()
        }
    }
    
    // Standard style onboarding view
    private var standardStyleView: some View {
        VStack {
            Text("Standard Style")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            OnboardingStepView(
                step: steps[0],
                isFirstStep: true,
                onNext: {},
                onPrevious: {},
                onSkip: {},
                onDidFinish: {},
                primaryColor: .blue,
                textOverlayStyle: .standard
            )
        }
    }
    
    // Minimal style onboarding view
    private var minimalStyleView: some View {
        VStack {
            Text("Minimal Style")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            OnboardingStepView(
                step: steps[0],
                isFirstStep: true,
                onNext: {},
                onPrevious: {},
                onSkip: {},
                onDidFinish: {},
                primaryColor: .blue,
                textOverlayStyle: .minimal
            )
        }
    }
}

#Preview {
    MinimalVideoOnboardingExample()
}
