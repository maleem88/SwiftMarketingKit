# CreditsManager

CreditsManager is a SwiftUI component that helps you implement a credit system in your app with configurable renewal periods (daily, weekly, or monthly). It's perfect for apps that need to limit certain features or actions based on usage.

## Features

- Configurable credit renewal periods (daily, weekly, or monthly)
- Automatic credit renewal on specified intervals
- Credit history tracking
- Beautiful UI with customizable appearance
- Fully customizable text and colors

## Basic Usage

Add the credit feature to any view in your app:

```swift
import SwiftMarketingKit

struct ContentView: View {
    // Create a view model for the credits
    @StateObject private var creditViewModel = CreditViewModel()
    
    var body: some View {
        NavigationStack {
            CreditView(viewModel: creditViewModel)
        }
    }
}
```

Consume credits when a user performs an action:

```swift
// When user performs an action that should consume credits
creditViewModel.consumeCredits(1, description: "Generated summary")
```

## Customization

CreditsManager provides extensive customization options through the `CreditsManagerConfig` class:

### Renewal Period Configuration

```swift
// Configure daily credits
CreditsManagerConfig.shared
    .setRenewalPeriod(.daily)
    .setCreditAmount(10)

// Configure weekly credits (renews every Monday)
CreditsManagerConfig.shared
    .setRenewalPeriod(.weekly(dayOfWeek: 2)) // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    .setCreditAmount(50)

// Configure monthly credits (renews on the 1st of each month)
CreditsManagerConfig.shared
    .setRenewalPeriod(.monthly(dayOfMonth: 1))
    .setCreditAmount(100)
```

### UI Customization

```swift
// Customize UI text
CreditsManagerConfig.shared
    .setCreditsTitleText("Daily AI Credits")
    .setHistoryTitleText("Usage History")

// Customize colors for credit display
CreditsManagerConfig.shared
    .setCreditThresholds(highThreshold: 0.7, mediumThreshold: 0.3)
    .setCreditColors(highColor: .green, mediumColor: .yellow, lowColor: .red)

// Configure history display
CreditsManagerConfig.shared
    .configureHistoryDisplay(show: true, maxItems: 10)
```

### Alert Text Customization

```swift
// Customize insufficient credits alert
CreditsManagerConfig.shared
    .setInsufficientCreditsAlertText(
        title: "Not Enough Credits",
        message: "You need %@ credits for this action but only have %@ remaining. Your credits will renew in %@ days."
    )
```

### Multiple Credit Systems

If your app needs multiple credit systems, you can customize the UserDefaults keys:

```swift
// Configure separate keys for different credit types
CreditsManagerConfig.shared
    .setUserDefaultsKeys(
        totalKey: "com.myapp.summaryCredits.total",
        consumedKey: "com.myapp.summaryCredits.consumed",
        renewalDateKey: "com.myapp.summaryCredits.nextRenewal",
        historyKey: "com.myapp.summaryCredits.history"
    )
```

## Complete Configuration Example

Here's a complete example showing how to configure CreditsManager in your app's initialization code:

```swift
import SwiftUI
import SwiftMarketingKit

@main
struct MyApp: App {
    init() {
        // Configure CreditsManager
        CreditsManagerConfig.shared
            .setRenewalPeriod(.weekly(dayOfWeek: 1)) // Renew every Sunday
            .setCreditAmount(20)
            .setCreditsTitleText("Weekly AI Credits")
            .setHistoryTitleText("Recent Usage")
            .setCreditColors(highColor: .blue, mediumColor: .orange, lowColor: .red)
            .configureHistoryDisplay(show: true, maxItems: 7)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Advanced Usage

### Creating Custom Credit Systems

You can create multiple credit systems with different configurations:

```swift
// Create a custom configuration
let summaryCreditsConfig = CreditsManagerConfig.shared
    .setRenewalPeriod(.daily)
    .setCreditAmount(5)
    .setCreditsTitleText("Daily Summary Credits")
    .setUserDefaultsKeys(
        totalKey: "com.myapp.summaryCredits.total",
        consumedKey: "com.myapp.summaryCredits.consumed",
        renewalDateKey: "com.myapp.summaryCredits.nextRenewal",
        historyKey: "com.myapp.summaryCredits.history"
    )

// Create a client and view model with this configuration
let summaryClient = CreditClient.live(config: summaryCreditsConfig)
let summaryViewModel = CreditViewModel(creditClient: summaryClient, config: summaryCreditsConfig)

// Use in a view
CreditView(viewModel: summaryViewModel)
```

### Manually Triggering Credit Refresh

```swift
// Manually refresh credit status (e.g., after app comes to foreground)
creditViewModel.refreshCreditStatus()
```
