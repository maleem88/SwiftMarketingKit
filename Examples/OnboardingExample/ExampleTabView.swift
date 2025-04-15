//
//  ExampleTabView.swift
//  OnboardingExample
//
//  Created on 15/04/2025.
//

import SwiftUI
import Onboarding

struct ExampleTabView: View {
    var body: some View {
        TabView {
            // Basic example
            ContentView()
                .tabItem {
                    Label("Basic", systemImage: "1.circle")
                }
            
            // Custom example
            CustomOnboardingView()
                .tabItem {
                    Label("Custom", systemImage: "2.circle")
                }
            
            // Settings example
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

/// Example settings view that allows toggling onboarding state
struct SettingsView: View {
    @State private var alwaysShowOnboarding = OnboardingManager.isAlwaysShowEnabled()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Onboarding Settings")) {
                    Toggle("Always Show Onboarding", isOn: $alwaysShowOnboarding)
                        .onChange(of: alwaysShowOnboarding) { newValue in
                            OnboardingManager.setAlwaysShowOnboarding(newValue)
                        }
                    
                    Button("Reset Onboarding State") {
                        OnboardingManager.resetOnboardingState()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SwiftMarketingKit Example")
                            .font(.headline)
                        
                        Text("This example app demonstrates how to use the Onboarding module from the SwiftMarketingKit package.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ExampleTabView()
}
