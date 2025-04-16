//
//  Examples.swift
//  SwiftMarketingKit
//
//  Created by Mohamed Abd Elaleem on 15/04/2025.
//

import SwiftUI
import EmailSupport

// MARK: - Navigation View for Examples

/// Main navigation view to browse through different examples
public struct RatingsExamplesView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Rating Examples")) {
                    NavigationLink("Basic Usage") {
                        BasicRatingExample()
                    }
                    
                    NavigationLink("Custom Configuration") {
                        CustomRatingExample()
                    }
                    
                    NavigationLink("MVVM Integration") {
                        MVVMExample()
                    }
                }
                
                Section(header: Text("About"), footer: Text("SwiftMarketingKit provides easy-to-use components for app ratings, onboarding, and more.")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ratings Examples")
        }
    }
}

// MARK: - Example 1: Basic Usage with Shared Instance

/// This example shows the simplest way to use the RatingsManager in your app
public struct BasicRatingExample: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Basic Rating Example")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Testing Instructions:")
                    .font(.headline)
                Text("1. Press 'Complete Action' multiple times")
                Text("2. Once you've done enough actions, the rating prompt will appear")
                Text("3. You can also use 'Show Rating Prompt' to test the UI directly")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Example button that records a successful action
            Button("Complete Action") {
                // Use the shared instance to record a successful action
                RatingClient.shared.recordSuccessfulAction()
                // The rating prompt will appear automatically if conditions are met
            }
            .buttonStyle(.borderedProminent)
            
            // Button to manually trigger rating prompt
            Button("Show Rating Prompt") {
                // if RatingClient.shared.shouldPromptForRating() {
                    RatingViewModel.shared.showRatingPrompt()
                // } else {
                //     print("Conditions for showing rating prompt not met")
                // }
            }
            .buttonStyle(.bordered)
            
            Divider()
            
            Text("Testing Controls")
                .font(.headline)
                .padding(.top)
            
            // Button to reset rating state (for testing)
            Button("Reset Rating State", role: .destructive) {
                RatingClient.shared.resetState()
                print("Rating state has been reset")
            }
            .buttonStyle(.bordered)
            
            Text("The rating prompt will automatically appear when conditions are met")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        // Apply the rating feature modifier to the entire view
        .withRatingFeature(viewModel: RatingViewModel.shared)
    }
}

// MARK: - Example 2: Custom Configuration

/// This example shows how to use a custom-configured RatingManager
public struct CustomRatingExample: View {
    public init() {}
    
    // Create a custom-configured instance for immediate testing
    @StateObject private var ratingViewModel = RatingViewModel(
        minimumDaysBeforePrompting: 0,  // No waiting days for testing
        minimumActionsBeforePrompting: 3 // Show after just 3 successful actions
    )
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Custom Rating Example")
                .font(.title)
                .padding()
            
            Text("Configuration: No waiting days, show after 3 actions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                
            VStack(alignment: .leading, spacing: 4) {
                Text("Testing Instructions:")
                    .font(.headline)
                Text("1. Press 'Complete Action' exactly 3 times")
                Text("2. The rating prompt will appear automatically")
                Text("3. Current action count is shown below")
                Text("4. Use 'Reset Rating State' if you want to start over")
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Example button that records a successful action
            Button("Complete Action") {
                ratingViewModel.recordSuccessfulAction()
            }
            .buttonStyle(.borderedProminent)
            
            // Display current action count
            HStack {
                Text("Actions completed:")
                Text("\(UserDefaults.standard.integer(forKey: "com.supertuber.successfulActionCount")) / 3 needed")
                    .bold()
                    .foregroundColor(UserDefaults.standard.integer(forKey: "com.supertuber.successfulActionCount") >= 3 ? .green : .primary)
            }
            .font(.headline)
            .padding(.vertical, 8)
            
            // Button to manually trigger rating
            Button("Trigger Rating Check") {
                
                if ratingViewModel.shouldPromptForRating() {
                    ratingViewModel.showRatingPrompt()
                }
            }
            .buttonStyle(.bordered)
            
            Divider()
            
            Text("This example uses a custom configuration that shows the rating prompt after just 1 day and 3 successful actions.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        // Apply the custom rating feature
        .withRatingFeature(viewModel: ratingViewModel)
    }
}

// MARK: - Example 3: Integration with MVVM Architecture

/// This example shows how to integrate RatingsManager with an MVVM architecture
public class AppViewModel: ObservableObject {
    public init() {}
    
    // Properties
    @Published var featureEnabled = false
    @Published var completedTasks = 0
    
    // Rating manager integration with testing-friendly configuration
    private let ratingClient = RatingClient(
        minimumDaysBeforePrompting: 0,  // No waiting days for testing
        minimumActionsBeforePrompting: 3 // Show after just 3 successful actions
    )
    let ratingViewModel = RatingViewModel(
        minimumDaysBeforePrompting: 0,
        minimumActionsBeforePrompting: 3
    )
    
    // Methods
    func completeTask() {
        completedTasks += 1
        
        // Record successful action when user completes a task
        ratingClient.recordSuccessfulAction()
        
        // You could also use the ViewModel directly
        // ratingViewModel.recordSuccessfulAction()
    }
    
    func checkRatingEligibility() -> Bool {
        return ratingClient.shouldPromptForRating()
    }
    
    func manuallyTriggerRating() {
        if checkRatingEligibility() {
            ratingViewModel.showRatingPrompt()
        }
    }
}

public struct MVVMExample: View {
    public init() {}
    
    // Use a custom view model that's configured for immediate testing
    @StateObject private var viewModel = AppViewModel()
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("MVVM Integration Example")
                .font(.title)
                .padding()
                
            VStack(alignment: .leading, spacing: 4) {
                Text("Testing Instructions:")
                    .font(.headline)
                Text("1. Press 'Complete Task' exactly 3 times")
                Text("2. The rating prompt will appear automatically")
                Text("3. Use 'Check Rating Eligibility' to see current status")
                Text("4. Use 'Manually Trigger Rating' to show the UI directly")
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            Text("Completed Tasks: \(viewModel.completedTasks) / 3 needed")
                .font(.headline)
            
            Button("Complete Task (\(viewModel.completedTasks)/3)") {
                viewModel.completeTask()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Check Rating Eligibility") {
                let eligible = viewModel.checkRatingEligibility()
                print("Rating eligibility: \(eligible ? "Yes" : "No")")
            }
            .buttonStyle(.bordered)
            .overlay(
                Text(viewModel.checkRatingEligibility() ? "✓ Ready" : "✗ Not ready")
                    .font(.caption2)
                    .padding(4)
                    .background(viewModel.checkRatingEligibility() ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .offset(y: -20)
                    .opacity(0.8),
                alignment: .top
            )
            
            Button("Manually Trigger Rating") {
                viewModel.manuallyTriggerRating()
            }
            .buttonStyle(.bordered)
            
            Divider()
            
            Text("This example demonstrates how to integrate the RatingsManager into an MVVM architecture.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        // Apply the rating feature from the ViewModel
        .withRatingFeature(viewModel: viewModel.ratingViewModel)
    }
}

// MARK: - Example 4: SwiftUI Preview

#Preview("Ratings Navigation") {
    RatingsExamplesView()
}

#Preview("Basic Rating Example") {
    BasicRatingExample()
}

#Preview("Custom Rating Example") {
    CustomRatingExample()
}

#Preview("MVVM Integration") {
    MVVMExample()
}
