# SwiftMarketingKit

SwiftMarketingKit is a collection of UI components for iOS apps, designed to help developers quickly implement common marketing and onboarding flows. Each module provides extensive configuration options for customizing the appearance and behavior to match your app's design and requirements.

## Features

- **Onboarding**: A customizable onboarding experience with step-by-step guides
- **Ratings**: In-app rating prompts with customizable timing and appearance
- **Credits**: Flexible credit system for managing user credits with renewal options
- **Subscribe**: Subscription management with RevenueCat integration and customizable UI
- **EmailSupport**: In-app email support with device information and customizable UI
- Beautiful, modern UI components
- Pure SwiftUI implementation
- iOS 16.0+ support
- Comprehensive configuration options for all modules

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

### EmailSupport Module

The EmailSupport module provides a simple way to add in-app email support functionality to your app.

#### Basic Implementation

```swift
import SwiftUI
import EmailSupport

struct ContentView: View {
    var body: some View {
        VStack {
            // Other content
            
            // Add the support button
            SupportButtonVM()
        }
    }
}
```

#### Customizing EmailSupport

```swift
// Create and customize configuration
let config = EmailSupportConfig.shared
    .setEmailSubject("Help with MyApp")
    .setEmailBodyTemplate("Hi Support Team,\n\nI need help with...\n\n--- Device Info ---\n%@\n---")
    .setToRecipients(["support@myapp.com"])
    .setIncludeDeviceInfo(true)
    .setSupportButtonText("Get Help")
    .setSupportButtonIcon("questionmark.circle")
    .setPrimaryColor(.purple)
    .setTextColor(.white)
    .setButtonFont(.system(.headline, design: .rounded))
    .setMailUnavailableAlertTitle("Email Not Available")
    .setMailSentConfirmationMessage("We've received your message and will get back to you soon!")

// Use the configuration
SupportButtonVM(config: config)
```

### Onboarding Module

The Onboarding module provides a simple way to create beautiful onboarding experiences with extensive customization options.

#### Basic Implementation

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

#### Customizing Onboarding

##### Using Configuration

```swift
// Create and customize configuration
let config = OnboardingManagerConfig.shared
    .setBackgroundColor(.black)
    .setPrimaryColor(.blue)
    .setSecondaryColor(.gray)
    .setTitleFont(.system(.title, design: .rounded))
    .setDescriptionFont(.system(.body, design: .rounded))
    .setButtonFont(.system(.headline, design: .rounded))
    .setProgressIndicatorStyle(.bar)
    .setShowSkipButton(true)
    .setNextButtonText("Continue")
    .setGetStartedButtonText("Let's Go!")
    .setSwipeNavigationEnabled(true)
    .setAutoPlayVideos(true)
    .setUserDefaultsKey("com.myapp.onboarding")

// Use the configuration
OnboardingView(config: config)
```

##### Custom Steps

```swift
let steps = [
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

OnboardingView(steps: steps, config: config)
```

### RatingsManager Module

The RatingsManager module helps you implement in-app rating prompts with customizable timing and appearance.

#### Basic Implementation

```swift
import SwiftUI
import RatingsManager

// Configure the ratings manager
RatingsManagerConfig.shared
    .setMinimumLaunchCount(5)
    .setMinimumDaysSinceFirstLaunch(3)
    .setMinimumDaysBetweenPrompts(60)
    .setEmailFeedbackEnabled(true)
    .setFeedbackEmail("feedback@yourdomain.com")
    .setAlertTitle("Enjoying Our App?")
    .setAlertMessage("We'd love to hear your feedback!")
    .setPositiveButtonText("Rate Us")
    .setNeutralButtonText("Later")
    .setNegativeButtonText("Send Feedback")

// Check if it's appropriate to show the rating prompt
if RatingsManager.shouldShowRatingPrompt() {
    RatingsManager.showRatingPrompt()
}
```

### CreditsManager Module

The CreditsManager module provides a flexible credit system for managing user credits with renewal options.

#### Basic Implementation

```swift
import SwiftUI
import CreditsManager

// Configure the credits manager
CreditsManagerConfig.shared
    .setInitialCredits(5)
    .setMaximumCredits(10)
    .setRenewalPeriod(.daily)
    .setRenewalAmount(3)
    .setPrimaryColor(.blue)
    .setSecondaryColor(.gray)
    .setCreditTextColor(.white)
    .setCreditFont(.system(.headline, design: .rounded))
    .setUserDefaultsKeyPrefix("com.myapp.credits")

// Create a credit client
let creditClient = CreditClient.standard()

// Use credits in your app
if creditClient.hasCredits() {
    creditClient.useCredit()
    // Perform premium action
}

// Display credits UI
CreditView(client: creditClient)
```

### SubscribeManager Module

The SubscribeManager module provides subscription management with RevenueCat integration and customizable UI.

#### Basic Implementation

```swift
import SwiftUI
import SubscribeManager

// Configure the subscribe manager
SubscribeManagerConfig.shared
    .configureRevenueCat(apiKey: "your_revenuecat_api_key")
    .setEntitlementIdentifier("premium")
    .setSubscribeViewTitle("Unlock Premium Features")
    .setShowFeatureDescriptions(true)
    .setShowIconBesideTitle(true)
    .setShowFeaturesTitle(true)
    .setFeaturesTitle("Premium Benefits")
    .setTintColor(.purple)
    .setFeatures([
        Feature(name: "Unlimited Access", description: "No limits on usage", iconName: "infinity"),
        Feature(name: "No Ads", description: "Ad-free experience", iconName: "xmark.circle"),
        Feature(name: "Premium Support", description: "Priority customer service", iconName: "person.fill.checkmark")  
    ])

// Show subscription view
SubscribeView()
```

## Configuration Reference

### OnboardingManagerConfig

| Method | Description | Default Value |
|--------|-------------|---------------|
| `setBackgroundColor(_:)` | Sets the background color for onboarding screens | `.black` |
| `setPrimaryColor(_:)` | Sets the primary color for buttons and highlights | `.blue` |
| `setSecondaryColor(_:)` | Sets the secondary color for inactive elements | `.gray` |
| `setTitleFont(_:)` | Sets the font for titles | `.title2` |
| `setDescriptionFont(_:)` | Sets the font for descriptions | `.body` |
| `setButtonFont(_:)` | Sets the font for buttons | `.headline` |
| `setProgressIndicatorStyle(_:)` | Sets the progress indicator style (`.dots`, `.bar`, `.numbers`, `.none`) | `.dots` |
| `setPhoneFrameEnabled(_:)` | Sets whether to show a phone frame around media | `false` |
| `setNextButtonText(_:)` | Sets the text for the next button | `"Next"` |
| `setPreviousButtonText(_:)` | Sets the text for the previous button | `"Back"` |
| `setSkipButtonText(_:)` | Sets the text for the skip button | `"Skip"` |
| `setGetStartedButtonText(_:)` | Sets the text for the get started button | `"Get Started"` |
| `setShowSkipButton(_:)` | Sets whether to show the skip button | `true` |
| `setShowProgressIndicator(_:)` | Sets whether to show the progress indicator | `true` |
| `setSwipeNavigationEnabled(_:)` | Sets whether to enable swipe navigation | `true` |
| `setAutoPlayVideos(_:)` | Sets whether videos should auto-play | `true` |
| `setUserDefaultsKey(_:)` | Sets the UserDefaults key for storing onboarding state | `"hasCompletedOnboarding"` |

### RatingsManagerConfig

| Method | Description | Default Value |
|--------|-------------|---------------|
| `setMinimumLaunchCount(_:)` | Sets the minimum number of app launches before showing the rating prompt | `5` |
| `setMinimumDaysSinceFirstLaunch(_:)` | Sets the minimum days since first launch before showing the rating prompt | `3` |
| `setMinimumDaysBetweenPrompts(_:)` | Sets the minimum days between rating prompts | `60` |
| `setEmailFeedbackEnabled(_:)` | Sets whether to enable email feedback for negative ratings | `true` |
| `setFeedbackEmail(_:)` | Sets the email address for feedback | `""` |
| `setAlertTitle(_:)` | Sets the title for the rating alert | `"Enjoying Our App?"` |
| `setAlertMessage(_:)` | Sets the message for the rating alert | `"We'd love to hear your feedback!"` |
| `setPositiveButtonText(_:)` | Sets the text for the positive button | `"Rate Us"` |
| `setNeutralButtonText(_:)` | Sets the text for the neutral button | `"Later"` |
| `setNegativeButtonText(_:)` | Sets the text for the negative button | `"Send Feedback"` |
| `setUserDefaultsKeyPrefix(_:)` | Sets the UserDefaults key prefix for storing rating state | `"appRating"` |

### CreditsManagerConfig

| Method | Description | Default Value |
|--------|-------------|---------------|
| `setInitialCredits(_:)` | Sets the initial number of credits | `5` |
| `setMaximumCredits(_:)` | Sets the maximum number of credits | `10` |
| `setRenewalPeriod(_:)` | Sets the renewal period (`.daily`, `.weekly`, `.monthly`) | `.daily` |
| `setRenewalAmount(_:)` | Sets the number of credits to renew | `3` |
| `setPrimaryColor(_:)` | Sets the primary color for the credit UI | `.blue` |
| `setSecondaryColor(_:)` | Sets the secondary color for the credit UI | `.gray` |
| `setCreditTextColor(_:)` | Sets the text color for credit display | `.white` |
| `setCreditFont(_:)` | Sets the font for credit display | `.headline` |
| `setUserDefaultsKeyPrefix(_:)` | Sets the UserDefaults key prefix for storing credit state | `"credits"` |

### SubscribeManagerConfig

| Method | Description | Default Value |
|--------|-------------|---------------|
| `configureRevenueCat(apiKey:)` | Configures RevenueCat with the API key | N/A |
| `setEntitlementIdentifier(_:)` | Sets the entitlement identifier for RevenueCat | `"premium"` |
| `setSubscribeViewTitle(_:)` | Sets the title for the subscribe view | `"Unlock Premium Features"` |
| `setShowFeatureDescriptions(_:)` | Sets whether to show feature descriptions | `false` |
| `setShowIconBesideTitle(_:)` | Sets whether to show an icon beside the title | `true` |
| `setShowFeaturesTitle(_:)` | Sets whether to show the features section title | `true` |
| `setFeaturesTitle(_:)` | Sets the title for the features section | `"Premium Features"` |
| `setTintColor(_:)` | Sets the tint color for the subscribe view | `.black` |
| `setFeatures(_:)` | Sets the features to display | `[]` |

### EmailSupportConfig

| Method | Description | Default Value |
|--------|-------------|---------------|
| `setEmailSubject(_:)` | Sets the subject line for support emails | `"App Support Request"` |
| `setEmailBodyTemplate(_:)` | Sets the email body template (use %@ for device info) | Template with placeholder |
| `setToRecipients(_:)` | Sets the recipient email addresses | `["support@example.com"]` |
| `setIncludeDeviceInfo(_:)` | Sets whether to include device information | `true` |
| `setSupportButtonText(_:)` | Sets the text for the support button | `"Contact Support"` |
| `setSupportButtonIcon(_:)` | Sets the system image name for the button | `"mail"` |
| `setPrimaryColor(_:)` | Sets the primary color for the button | `.blue` |
| `setTextColor(_:)` | Sets the text color for the button | `.white` |
| `setButtonFont(_:)` | Sets the font for the button | `.headline` |
| `setMailUnavailableAlertTitle(_:)` | Sets the title for the mail unavailable alert | `"Mail Not Configured"` |
| `setMailUnavailableAlertMessage(_:)` | Sets the message for the mail unavailable alert | Message about configuring Mail app |
| `setMailSentConfirmationTitle(_:)` | Sets the title for the confirmation alert | `"Thanks!"` |
| `setMailSentConfirmationMessage(_:)` | Sets the message for the confirmation alert | `"Your support email was sent successfully."` |
| `setAlertOkButtonText(_:)` | Sets the text for the OK button in alerts | `"OK"` |

## Requirements

- iOS 16.0+
- Swift 5.5+
- Xcode 14.0+

## License

SwiftMarketingKit is available under the MIT license. See the LICENSE file for more info.
