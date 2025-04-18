# SubscribeManager

A SwiftUI module for handling in-app subscriptions with RevenueCat integration.

## Overview

SubscribeManager provides a complete solution for implementing in-app subscriptions in your iOS app. It includes:

- Subscription view with different plan options
- Lifetime offer with countdown timer
- RevenueCat integration for handling purchases
- Support for iOS 16+

## Testing Subscriptions

### Setting Up StoreKit Configuration

1. Add the `StoreKitConfig.storekit` file to your project
2. In your Xcode scheme settings:
   - Select your app scheme
   - Click "Edit Scheme"
   - Select the "Run" phase
   - Go to the "Options" tab
   - Check "StoreKit Configuration"
   - Select the `StoreKitConfig.storekit` file from the dropdown

### Testing the Subscription Flow

Use the provided `SubscriptionTestExample.swift` file as a reference for implementing and testing the subscription flow:

1. Run your app with the StoreKit Configuration enabled
2. Open the subscription view
3. Select a subscription plan
4. Complete the purchase in the StoreKit test environment
5. Verify the premium status updates correctly

### Configuration

Before using SubscribeManager, configure it with your RevenueCat API key and customize the features:

```swift
// In your AppDelegate or early in your app's lifecycle
import SwiftUI
import SubscribeManager
import RevenueCat

// Configure RevenueCat with your API key
SubscribeManagerConfig.configureRevenueCat(apiKey: "your_api_key_here")

// Optional: Set a custom entitlement identifier (default is "premium")
SubscribeManagerConfig.setEntitlementIdentifier("your_entitlement_id")

// Optional: Customize the features shown in the subscription view
SubscribeManagerConfig.setFeatures([
    SubscribeFeature(icon: "lock.open.fill", title: "Ad-Free Experience", description: "No ads, no interruptions"),
    SubscribeFeature(icon: "sparkles", title: "Premium Tools", description: "Access to all premium tools"),
    SubscribeFeature(icon: "envelope.open.fill", title: "Priority Support", description: "Get help when you need it")
])

// Optional: Customize the UI appearance
SubscribeManagerConfig.setSubscribeViewTitle("Go Premium") // Custom title for the view
SubscribeManagerConfig.setShowFeatureDescriptions(true) // Show feature descriptions
SubscribeManagerConfig.setShowIconBesideTitle(false) // Hide icon and center the title
SubscribeManagerConfig.setShowFeaturesTitle(true) // Show the features section title
SubscribeManagerConfig.setFeaturesTitle("What You'll Get") // Custom features section title
SubscribeManagerConfig.setTintColor(.blue) // Custom tint color (default is .black)
```

### Example Usage

```swift
import SwiftUI
import SubscribeManager

struct ContentView: View {
    @State private var showSubscribeView = false
    
    var body: some View {
        Button("Subscribe") {
            showSubscribeView = true
        }
        .sheet(isPresented: $showSubscribeView) {
            SubscribeView()
        }
    }
}
```

## Components

### SubscribeView

The main view for displaying subscription options and handling purchases.

### LifetimeOfferTimerView

A standalone view that displays a limited-time offer with a countdown timer.

### RevenueCatClient

A wrapper around the RevenueCat SDK for handling purchases and subscription status.

### SubscribeManagerConfig

A configuration class that allows you to customize the subscription experience, including RevenueCat API settings and feature list customization.

## Requirements

- iOS 16.0+
- Swift 5.0+
- RevenueCat SDK
