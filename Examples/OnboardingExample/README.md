# Onboarding Example

This example demonstrates how to use the Onboarding module from the SwiftMarketingKit package in a SwiftUI iOS app.

## Getting Started

To run this example:

1. Open the project in Xcode
2. Add the following images to the Assets.xcassets catalog:
   - `onboarding_welcome`
   - `onboarding_summaries`
   - `onboarding_bookmarks`
   - `onboarding_getstarted`

Or you can modify the `OnboardingStep.sampleSteps` array in the `ContentView.swift` file to use your own images.

## Features Demonstrated

- Displaying an onboarding flow when the app launches
- Customizing the onboarding steps
- Handling onboarding completion and skipping
- Re-displaying the onboarding flow when needed

## Code Structure

- `OnboardingExampleApp.swift`: The main app entry point
- `ContentView.swift`: Demonstrates how to integrate the onboarding flow
- `Resources/`: Contains assets for the example app

## Implementation Details

The example uses the `OnboardingViewModel` and `OnboardingView` from the SwiftMarketingKit package. It demonstrates:

1. How to initialize the onboarding view model
2. How to display the onboarding view
3. How to handle onboarding completion and skipping
4. How to re-display the onboarding flow
