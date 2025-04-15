# Getting Started with Onboarding

Create beautiful onboarding experiences for your iOS app.

## Adding the Package

First, add SwiftMarketingKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftMarketingKit.git", from: "1.0.0")
]
```

Then, add the Onboarding module to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "Onboarding", package: "SwiftMarketingKit")
    ]
)
```

## Basic Implementation

Here's a simple example of how to use the `OnboardingView`:

```swift
import SwiftUI
import Onboarding

struct ContentView: View {
    @State private var showOnboarding = true
    
    var body: some View {
        ZStack {
            // Your main app content here
            Text("Main App Content")
            
            // Show onboarding when needed
            if showOnboarding {
                OnboardingView()
                    .transition(.opacity)
                    .zIndex(100)
                    .onDisappear {
                        showOnboarding = false
                    }
            }
        }
    }
}
```

## Customizing Onboarding Steps

You can create custom onboarding steps:

```swift
let customViewModel = OnboardingViewModel()
customViewModel.steps = [
    OnboardingStep(
        id: "welcome",
        title: "Welcome to Your App",
        description: "Your amazing app description here.",
        mediaType: .image,
        mediaSource: "onboarding_welcome",
        isLastStep: false,
        currentStepIndex: 0,
        totalSteps: 3
    ),
    OnboardingStep(
        id: "feature1",
        title: "Amazing Feature",
        description: "Describe your amazing feature here.",
        mediaType: .image,
        mediaSource: "feature1_image",
        isLastStep: false,
        currentStepIndex: 1,
        totalSteps: 3
    ),
    OnboardingStep(
        id: "getStarted",
        title: "Let's Get Started",
        description: "You're all set to begin using the app!",
        mediaType: .image,
        mediaSource: "get_started_image",
        isLastStep: true,
        currentStepIndex: 2,
        totalSteps: 3
    )
]

// Use the custom view model
OnboardingView(viewModel: customViewModel)
```

## Adding Media Resources

Make sure to add your media resources to your app's asset catalog:

1. Add images to your app's asset catalog
2. Reference them in your OnboardingStep using the `mediaSource` parameter

## Handling Onboarding Completion

You can listen for onboarding completion by observing the view model:

```swift
struct ContentView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            // Main app content
            Text("Main App Content")
            
            // Show onboarding when needed
            if onboardingViewModel.showOnboarding {
                OnboardingView(viewModel: onboardingViewModel)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .onAppear {
            // Check if we should show onboarding
            // This is just an example - you might want to use UserDefaults or another method
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                onboardingViewModel.showOnboarding = true
            }
        }
    }
}
```
