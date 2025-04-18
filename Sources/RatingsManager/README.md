# RatingsManager

RatingsManager is a SwiftUI component that helps you prompt users for App Store ratings at appropriate times and collect feedback from users who may not be completely satisfied with your app.

## Features

- Smart timing for rating prompts based on app usage
- Customizable pre-prompt to gauge user satisfaction
- Integrated feedback collection via email for users who aren't satisfied
- Fully customizable text, timing, and appearance

## Basic Usage

Add the rating feature to any view in your app:

```swift
import SwiftMarketingKit

struct ContentView: View {
    var body: some View {
        Text("Your app content")
            .withRatingFeature()
    }
}
```

Record successful user actions to trigger rating prompts at appropriate times:

```swift
import SwiftMarketingKit

// After user completes an important action
RatingViewModel.shared.recordSuccessfulAction()
```

## Customization

RatingsManager provides extensive customization options through the `RatingsManagerConfig` class:

### Timing Configuration

```swift
// Configure when ratings prompts appear
RatingsManagerConfig.shared
    .setMinimumDaysBeforePrompting(5)         // Wait at least 5 days after first launch
    .setMinimumActionsBeforePrompting(3)      // Wait until user has performed 3 successful actions
```

### App Information

```swift
// Set app name and icon for prompts and emails
RatingsManagerConfig.shared
    .setAppName("My Awesome App")
    .setAppIcon(UIImage(named: "AppIcon")!)
```

### Email Feedback Configuration

```swift
// Configure feedback email options
RatingsManagerConfig.shared
    .setFeedbackEmailRecipients(["support@myapp.com"])
    .setFeedbackEmailSubject("My App Feedback")
    .setFeedbackEmailBodyTemplate("""
    Hello,
    
    I'd like to provide some feedback about My App:
    
    [User feedback will go here]
    
    ------------------------
    [DEVICE_INFO]
    ------------------------
    """)
    .setIncludeFeedbackOption(true)  // Whether to show feedback option for unhappy users
```

### Alert Text Customization

```swift
// Customize enjoyment prompt
RatingsManagerConfig.shared
    .setEnjoymentPromptTitle("Enjoying My App?")
    .setEnjoymentPromptPositiveButtonText("Love it!")
    .setEnjoymentPromptNegativeButtonText("Not really")
    .setEnjoymentPromptCancelButtonText("Ask me later")

// Customize feedback prompt
RatingsManagerConfig.shared
    .setFeedbackPromptTitle("We'd love your feedback")
    .setFeedbackPromptMessage("Would you like to tell us how we can improve?")
    .setFeedbackPromptPositiveButtonText("Send Feedback")
    .setFeedbackPromptCancelButtonText("No thanks")

// Customize mail sent confirmation
RatingsManagerConfig.shared
    .setMailSentConfirmationTitle("Thank you!")
    .setMailSentConfirmationMessage("We appreciate your feedback and will use it to improve the app.")
    .setMailSentConfirmationButtonText("OK")

// Customize mail unavailable alert
RatingsManagerConfig.shared
    .setMailUnavailableAlertTitle("Email Not Available")
    .setMailUnavailableAlertMessage("Please set up the Mail app on your device to send feedback.")
    .setMailUnavailableAlertButtonText("OK")
```

## Complete Configuration Example

Here's a complete example showing how to configure RatingsManager in your app's initialization code:

```swift
import SwiftUI
import SwiftMarketingKit

@main
struct MyApp: App {
    init() {
        // Configure RatingsManager
        RatingsManagerConfig.shared
            .setAppName("My Awesome App")
            .setMinimumDaysBeforePrompting(3)
            .setMinimumActionsBeforePrompting(5)
            .setFeedbackEmailRecipients(["feedback@myapp.com"])
            .setFeedbackEmailSubject("My App Feedback")
            .setEnjoymentPromptTitle("Enjoying My App?")
            .setEnjoymentPromptPositiveButtonText("Love it!")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Advanced Usage

### Custom View Model

You can create your own instance of `RatingViewModel` for more control:

```swift
struct ContentView: View {
    // Create a custom view model
    @StateObject private var ratingViewModel = RatingViewModel()
    
    var body: some View {
        Text("Your app content")
            .withRatingFeature(viewModel: ratingViewModel)
            .onAppear {
                // Force a rating prompt to appear
                if shouldShowRating {
                    ratingViewModel.showRatingPrompt()
                }
            }
    }
}
```
