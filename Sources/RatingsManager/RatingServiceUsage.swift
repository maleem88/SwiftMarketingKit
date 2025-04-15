//
//  RatingServiceUsage.swift
//  SuperTuber
//
//  Created by mohamed abd elaleem on 06/04/2025.
//

import SwiftUI
import StoreKit

// MARK: - Example Usage in a SwiftUI View

struct ExampleView: View {
    // Option 1: Use the shared instance
    // private let ratingViewModel = RatingViewModel.shared
    
    // Option 2: Create a view-specific instance
    @StateObject private var ratingViewModel = RatingViewModel()
    
    var body: some View {
        VStack {
            Text("SuperTuber")
                .font(.largeTitle)
                .padding()
            
            // Example button that records a successful action
            Button("Complete Action") {
                // Record successful action when user completes something meaningful
                ratingViewModel.recordSuccessfulAction()
                // No need to manually show the rating prompt - it will appear automatically
                // if conditions are met (thanks to the withRatingFeature modifier)
            }
            .padding()
            
            Text("The rating prompt will automatically appear when conditions are met")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
        // Apply the rating feature modifier to the entire view
        // This will automatically show rating prompts when triggered
        .withRatingFeature(viewModel: ratingViewModel)
    }
}

// MARK: - Example Usage with ObservableObject

class ExampleViewModel: ObservableObject {
    // Option 1: Use the shared instance
    private let ratingClient = RatingClient.shared
    
    // Option 2: Create a feature-specific instance with custom configuration
    private let ratingFeature = RatingFeature(ratingClient: RatingClient(
        minimumDaysBeforePrompting: 2,
        minimumActionsBeforePrompting: 3
    ))
    
    func completeAction() {
        // Record successful action
        ratingClient.recordSuccessfulAction()
        // The rating prompt will appear automatically if conditions are met
    }
    
    func checkRating() {
        // Check if we should show rating prompt
        if ratingClient.shouldPromptForRating() {
            ratingFeature.showRatingPrompt()
        }
    }
    
    // Expose the rating feature for the view
    var rating: RatingFeature {
        return ratingFeature
    }
}

// MARK: - How to Use in Your App

/*
 STEP 1: Add the rating feature modifier to your main view or content view
 
 ```swift
 struct ContentView: View {
     var body: some View {
         MainTabView()
             .withRatingFeature()
     }
 }
 ```
 
 STEP 2: Record successful actions in appropriate places
 
 Good places to record successful actions:
 
 1. When a video summary is successfully generated
 2. When a user saves a summary
 3. When a user shares content
 4. When a user completes a subscription purchase
 5. When a user successfully authenticates with YouTube
 6. When a user adds a video to favorites
 7. When a user creates a playlist
 
 Example:
 
 ```swift
 func videoSummaryGenerated() {
     RatingClient.shared.recordSuccessfulAction()
     // The rating prompt will automatically appear if conditions are met
 }
 
 func userCompletedPurchase() {
     RatingClient.shared.recordSuccessfulAction()
 }
 ```
 
 STEP 3: Configure thresholds in your app initialization
 
 ```swift
 // In your App.swift or early initialization code
 // Option 1: Configure the shared instance
 RatingClient.shared.minimumDaysBeforePrompting = 3
 RatingClient.shared.minimumActionsBeforePrompting = 5
 
 // Option 2: Create a custom configured instance
 let customRatingClient = RatingClient(
     minimumDaysBeforePrompting: 2,
     minimumActionsBeforePrompting: 3
 )
 ```
 */
