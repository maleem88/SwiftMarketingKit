//
//  CustomViewOnboardingExample.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 09/07/2025.
//

import SwiftUI

/// Example of using custom SwiftUI views in the onboarding flow
public struct CustomViewOnboardingExample: View {
    @State private var showOnboarding = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Custom View Onboarding Example")
                .font(.title)
                .padding()
            
            Button("Show Onboarding with Custom View") {
                showOnboarding = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .sheet(isPresented: $showOnboarding) {
            // Example 1: Adding a custom view to existing steps
            let standardSteps = OnboardingStep.sampleSteps.prefix(2).map { $0 }
            
            let allSteps =  [
                OnboardingStep(
                    title: "Sign Up Form", 
                    description: "Please fill out this form to continue", 
                    customView: CustomFormView()
                )
            ] + standardSteps
            OnboardingView(
                steps: allSteps,
                config: OnboardingManagerConfig.shared
                    .setPrimaryColor(.blue)
                    .setBackgroundColor(Color(.systemBackground))
            )
        }
    }
}

/// Example custom view that could be used in an onboarding flow
struct CustomFormView: CustomOnboardingView {
    @State private var name = ""
    @State private var email = ""
    @State private var agreedToTerms = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Create Your Account")
                .font(.headline)
                .padding(.bottom, 10)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Toggle("I agree to the terms and conditions", isOn: $agreedToTerms)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            Spacer()
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

/// Example of a more complex custom view
struct CustomChartView: CustomOnboardingView {
    var body: some View {
        VStack {
            Text("Usage Statistics")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 20) {
                BarView(value: 0.3, label: "Mon")
                BarView(value: 0.5, label: "Tue")
                BarView(value: 0.8, label: "Wed")
                BarView(value: 0.4, label: "Thu")
                BarView(value: 0.7, label: "Fri")
            }
            .padding(.top, 20)
            .animation(.spring(), value: true)
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

/// Helper view for the chart
struct BarView: View {
    let value: CGFloat
    let label: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 30, height: 200)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 30, height: value * 200)
            }
            .cornerRadius(5)
            
            Text(label)
                .font(.caption)
                .padding(.top, 5)
        }
    }
}

/// Example showing how to create a complete onboarding flow with mixed content
public struct MixedOnboardingExample: View {
    @State private var showOnboarding = false
    
    public init() {}
    
    public var body: some View {
        Button("Show Mixed Onboarding") {
            showOnboarding = true
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .sheet(isPresented: $showOnboarding) {
            // Create standard steps
            let standardSteps = OnboardingStep.sampleSteps.prefix(2).map { $0 }
            
            // Create custom steps
            let customStep1 = OnboardingStep(
                title: "Custom Form",
                description: "Please fill out this form",
                customView: CustomViewWrapper(content: CustomFormView())
            )
            
            let customStep2 = OnboardingStep(
                title: "Usage Statistics",
                description: "See how you're doing",
                customView: CustomChartView(),
                isLastStep: true
            )
            
            // Combine all steps in one array
            let allSteps = standardSteps + [customStep1, customStep2]
            
            // Use the simplified API
            OnboardingView(
                steps: allSteps,
                config: OnboardingManagerConfig.shared
                    .setPrimaryColor(.blue)
                    .setBackgroundColor(Color(.systemBackground))
                    .setTextOverlayStyle(.minimal)
            )
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        CustomViewOnboardingExample()
        MixedOnboardingExample()
    }
}
