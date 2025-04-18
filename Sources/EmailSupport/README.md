# EmailSupport Module

The EmailSupport module provides a simple way to add in-app email support functionality to your iOS app. It includes a customizable support button that opens a pre-configured email composer with device information and customizable content.

## Features

- Pre-configured email composer with customizable subject, body, and recipients
- Optional device information inclusion (iOS version, app version, free storage)
- Customizable UI with support for different colors, fonts, and icons
- Fallback handling when Mail app is not configured
- Success confirmation alerts
- Comprehensive configuration options

## Installation

Add the EmailSupport module to your target dependencies in your `Package.swift` file:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "EmailSupport", package: "SwiftMarketingKit")
    ]
)
```

## Basic Usage

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

## Configuration

The EmailSupport module can be extensively customized using the `EmailSupportConfig` class:

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

## Configuration Options

### Email Content Configuration

| Method | Description | Default Value |
|--------|-------------|---------------|
| `setEmailSubject(_:)` | Sets the subject line for support emails | `"App Support Request"` |
| `setEmailBodyTemplate(_:)` | Sets the email body template. Use %@ as a placeholder for device info | `"Hello Support Team,\n\n[Please describe your issue here.]\n\n------------------------\n%@\n------------------------"` |
| `setToRecipients(_:)` | Sets the recipient email addresses | `["support@example.com"]` |
| `setIncludeDeviceInfo(_:)` | Sets whether to include device information in the email | `true` |

### UI Configuration

| Method | Description | Default Value |
|--------|-------------|---------------|
| `setSupportButtonText(_:)` | Sets the text for the support button | `"Contact Support"` |
| `setSupportButtonIcon(_:)` | Sets the system image name for the support button | `"mail"` |
| `setPrimaryColor(_:)` | Sets the primary color for the support button | `.blue` |
| `setTextColor(_:)` | Sets the text color for the support button | `.white` |
| `setButtonFont(_:)` | Sets the font for the support button | `.headline` |

### Alert Configuration

| Method | Description | Default Value |
|--------|-------------|---------------|
| `setMailUnavailableAlertTitle(_:)` | Sets the title for the mail unavailable alert | `"Mail Not Configured"` |
| `setMailUnavailableAlertMessage(_:)` | Sets the message for the mail unavailable alert | `"Please configure the Mail app on your device to send support emails."` |
| `setMailSentConfirmationTitle(_:)` | Sets the title for the mail sent confirmation alert | `"Thanks!"` |
| `setMailSentConfirmationMessage(_:)` | Sets the message for the mail sent confirmation alert | `"Your support email was sent successfully."` |
| `setAlertOkButtonText(_:)` | Sets the text for the OK button in alerts | `"OK"` |

## Example

Here's a complete example showing how to integrate the EmailSupport module with custom configuration:

```swift
import SwiftUI
import EmailSupport

struct SettingsView: View {
    // Create custom configuration
    let emailConfig = EmailSupportConfig.shared
        .setEmailSubject("Help with MyAwesomeApp")
        .setToRecipients(["help@myawesomeapp.com"])
        .setPrimaryColor(.indigo)
        .setSupportButtonText("Contact Our Team")
        .setSupportButtonIcon("envelope.badge")
    
    var body: some View {
        List {
            Section("Help") {
                SupportButtonVM(config: emailConfig)
            }
            
            // Other settings sections
        }
        .navigationTitle("Settings")
    }
}
```

## Requirements

- iOS 16.0+
- Swift 5.5+
- Xcode 14.0+
