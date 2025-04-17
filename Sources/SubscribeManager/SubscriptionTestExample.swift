import SwiftUI
import StoreKit
import RevenueCat

/// This file provides examples of how to test the subscription flow using StoreKit Configuration
/// To use this in your app:
/// 1. Add the StoreKitConfig.storekit file to your project
/// 2. In your scheme settings, enable StoreKit Configuration and select the file
/// 3. Run your app in the simulator or on a device

// MARK: - Example App Entry Point
public struct SubscriptionTestApp: App {
    public init() {
        // Configure RevenueCat with your API key
        Purchases.configure(withAPIKey: "your_api_key_here")
        
        // For testing with StoreKit Configuration, you can enable debug logs
        Purchases.logLevel = .debug
    }
    
    public var body: some Scene {
        WindowGroup {
            SubscriptionTestView()
        }
    }
}

// MARK: - Example View
public struct SubscriptionTestView: View {
    @State private var showSubscribeView = false
    @State private var isPremium = false
    @State private var showLifetimeOffer = true
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Subscription Test Example")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if isPremium {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Premium Subscription Active")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("You have access to all premium features")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Restore Purchases") {
                            Task {
                                await checkPremiumStatus()
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Button {
                            showSubscribeView = true
                        } label: {
                            Text("Subscribe Now")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        
                        if showLifetimeOffer {
                            // Example of using the LifetimeOfferTimerView
                            let lifetimeViewModel = LifetimeOfferViewModel(
                                isOfferAvailable: true,
                                remainingSeconds: 3600 * 12, // 12 hours remaining
                                title: "Special Launch Offer",
                                subtitle: "Lifetime access offer expires in:"
                            )
                            
                            LifetimeOfferTimerView(
                                viewModel: lifetimeViewModel,
                                onSubscribeAction: { showSubscribeView = true }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                
                // Instructions for testing
                VStack(alignment: .leading, spacing: 8) {
                    Text("Testing Instructions:")
                        .font(.headline)
                    
                    Text("1. Tap 'Subscribe Now' to open the subscription view")
                    Text("2. Choose a subscription plan")
                    Text("3. Complete the purchase using the StoreKit test environment")
                    Text("4. Your premium status will update automatically")
                    
                    Text("Note: Make sure you've enabled the StoreKit Configuration in your scheme settings.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Subscription Test")
            .sheet(isPresented: $showSubscribeView) {
                // Present the SubscribeView
                SubscribeView()
                    .onDisappear {
                        // Check premium status when the view disappears
                        Task {
                            await checkPremiumStatus()
                        }
                    }
            }
            .onAppear {
                // Check premium status when the view appears
                Task {
                    await checkPremiumStatus()
                }
            }
        }
    }
    
    // Check premium status using RevenueCat
    private func checkPremiumStatus() async {
        do {
            isPremium = try await RevenueCatClient.shared.checkPremiumStatus()
        } catch {
            print("Error checking premium status: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview Provider
struct SubscriptionTestView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionTestView()
    }
}

// MARK: - Additional Examples

// Example of creating a custom SubscribeView with a specific configuration
public struct CustomSubscribeViewExample: View {
    public var body: some View {
        // Create a custom SubscribeView
        SubscribeView()
            // You can add modifiers here if needed
    }
}

// Example of using the LifetimeOfferTimerView standalone
public struct LifetimeOfferExample: View {
    @StateObject private var viewModel = LifetimeOfferViewModel(
        isOfferAvailable: true,
        remainingSeconds: 3600 * 5, // 5 hours remaining
        title: "Limited Time Offer",
        subtitle: "Get lifetime access before time runs out:"
    )
    
    public var body: some View {
        VStack {
            Text("Example of Lifetime Offer Timer")
                .font(.title)
                .padding()
            
            LifetimeOfferTimerView(
                viewModel: viewModel,
                onSubscribeAction: {
                    print("Subscribe button tapped")
                    // Present your subscription view here
                }
            )
            .padding()
            
            Button("Simulate Time Passing") {
                // Simulate time passing by reducing the remaining seconds
                viewModel.remainingSeconds -= 300 // Subtract 5 minutes
            }
            .padding()
        }
    }
}
