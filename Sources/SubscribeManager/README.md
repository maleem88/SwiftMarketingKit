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

## Requirements

- iOS 16.0+
- Swift 5.0+
- RevenueCat SDK
