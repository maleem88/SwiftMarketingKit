# SwiftMarketingKit

SwiftMarketingKit is a collection of UI components for iOS apps, designed to help developers quickly implement common marketing and onboarding flows.

## Features

- **Onboarding**: A customizable onboarding experience with step-by-step guides
- Beautiful, modern UI components
- Pure SwiftUI implementation
- iOS 16.0+ support

## Examples

Check out the [Examples](Examples/) directory for sample projects that demonstrate how to use SwiftMarketingKit in your apps:

- [OnboardingExample](Examples/OnboardingExample/): Shows how to implement and customize the onboarding flow

## Installation

### Swift Package Manager

Add SwiftMarketingKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftMarketingKit.git", from: "1.0.0")
]
```

Then, add the specific library you want to use to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "Onboarding", package: "SwiftMarketingKit")
    ]
)
```

## Usage

### Onboarding

The Onboarding module provides a simple way to create beautiful onboarding experiences:

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
            }
        }
    }
}
```

You can customize the onboarding steps by creating your own `OnboardingViewModel`:

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
    // Add more steps...
]

OnboardingView(viewModel: customViewModel)
```

## Requirements

- iOS 16.0+
- Swift 6.0+

## License

SwiftMarketingKit is available under the MIT license. See the LICENSE file for more info.
