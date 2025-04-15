//
//  ContentView.swift
//  SwiftMarketingKit
//
//  Created on 15/04/2025.
//

import SwiftUI
import Onboarding

struct ContentView: View {
    @State private var showOnboarding = true
    @StateObject private var onboardingViewModel = OnboardingViewModel(persistCompletion: false)
    
    var body: some View {
        ZStack {
            // Main app content
            mainContent
                .opacity(showOnboarding ? 0.3 : 1.0)
                .animation(.easeInOut, value: showOnboarding)
            
            // Show onboarding overlay when needed
            if showOnboarding {
                OnboardingView(viewModel: onboardingViewModel)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .onAppear {
            // Initialize the onboarding view model with custom completion handler
            onboardingViewModel.onOnboardingCompleted = {
                withAnimation {
                    showOnboarding = false
                }
            }
            
            onboardingViewModel.onOnboardingSkipped = {
                withAnimation {
                    showOnboarding = false
                }
            }
        }
    }
    
    // Main app content that will be shown after onboarding
    private var mainContent: some View {
        VStack(spacing: 24) {
            Text("Welcome to the App!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You've completed the onboarding process.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    showOnboarding = true
                }
            }) {
                Text("Show Onboarding Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom, 50)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
