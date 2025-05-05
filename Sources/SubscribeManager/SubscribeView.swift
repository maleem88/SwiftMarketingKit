//
//  SubscribeView.swift
//  SuperTuber
//
//  Created by mohamed abd elaleem on 03/04/2025.
//

import SwiftUI
import StoreKit
import RevenueCat
import RevenueCatUI
import Foundation
import Combine


public struct SubscribeView: View {
    @ObservedObject var viewModel: SubscribeViewModel
    @Environment(\.dismiss) var dismiss
    
    public init() {
        self.viewModel = SubscribeViewModel()
        self.viewModel.onDismiss = { [self] in dismiss() }
    }
    
    // Helper method for purchasing current plan
    private func purchaseCurrentPlan() async {
        if let selectedPackage = viewModel.selectedPackage {
            // Use the product identifier from the selected package
            await viewModel.purchaseSubscription(selectedPackage.storeProduct.productIdentifier)
        }
    }
    

    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        
                        if viewModel.isPremium {
                            premiumStatusView
                        } else {
                            featuresView
                        }
                    }
                    .padding()
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button {
//                        viewModel.dismiss()
//                    } label: {
//                        Image(systemName: "xmark")
//                    }
//                }
//            }
            // Card-style subscription options with gradient button
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    // Free trial toggle
                    HStack {
                        Text("Enable Free Trial")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { viewModel.freeTrialEnabled },
                            set: { viewModel.toggleFreeTrial($0) }
                        ))
                            .labelsHidden()
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(24)
                    
                    if viewModel.availablePackages.isEmpty {
                        // Show loading or error state when no packages are available
                        Text("Loading subscription options...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                    } else {
                        
                        // Dynamic subscription plans from RevenueCat
                        ForEach(viewModel.getSubscriptionPlanModels(), id: \.package.identifier) { planModel in
                            SubscriptionPlanCard(
                                title: planModel.title,
                                subtitle: planModel.subtitle,
                                price: planModel.price,
                                period: planModel.period,
                                perWeekPrice: planModel.perWeekPrice,
                                isSelected: planModel.isSelected,
                                hasTrial: planModel.hasTrial,
                                showPricePerPeriod: planModel.showPricePerPeriod,
                                trialDays: 3,
                                isBestValue: planModel.isBestValue,
                                savingsText: planModel.savingsText,
                                lifetimeOfferViewModel: planModel.isLifetime ? viewModel.lifetimeOfferViewModel : nil,
                                action: {
                                    viewModel.selectPlan(planModel.package.identifier)
                                }
                            )
                        }
                    }
                    
                    // Subscribe button with gradient
                    Button {
                        Task {
                            await purchaseCurrentPlan()
                        }
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                SubscribeManagerConfig.getTintColor()
                                .cornerRadius(24)
                                .opacity(viewModel.selectedPackage == nil || viewModel.isPremium ? 0.5 : 1.0)
                            )
                            .foregroundColor(.white)
                    }
                    .disabled(viewModel.selectedPackage == nil || viewModel.isPremium || viewModel.isLoading)
                    
                    // Subscription info text
    //                Text("Any active subscription will be refunded.\nCancel any time.")
    //                    .font(.footnote)
    //                    .foregroundColor(.secondary)
    //                    .multilineTextAlignment(.center)
                    
                    // Restore purchases text button
                    Button("Restore Purchases") {
                        Task {
                            await viewModel.restorePurchases()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .onAppear {
                Task {
                    await viewModel.onAppear()
                }
                viewModel.onDismiss = { dismiss() }
            }
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
            
    //        .alert(item: Binding<ErrorWrapper?>(
    //            get: { store.errorMessage.map { ErrorWrapper(message: $0) } },
    //            set: { _ in store.send(.offeringsResponse(.success(nil))) }
    //        )) { error in
    //            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
    //        }
        }
        
    }
    
    private var headerView: some View {
//        VStack(spacing: 12) {
            Group {
                if SubscribeManagerConfig.shouldShowIconBesideTitle() {
                    HStack(spacing: 10) {
                        AppIconView()

                        Text(SubscribeManagerConfig.getSubscribeViewTitle(isPremium: viewModel.isPremium))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text(SubscribeManagerConfig.getSubscribeViewTitle(isPremium: viewModel.isPremium))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
//            Text("Take your YouTube experience to the next level")
//                .font(.headline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .padding(.top, 20)
    }
    
    private var premiumStatusView: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text("Premium Active")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You have access to all premium features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.1))
            )
            
            // List of premium features the user now has access to
            featuresView
        }
    }
    
    private var featuresView: some View {
        VStack(spacing: 8) {
            if SubscribeManagerConfig.shouldShowFeaturesTitle() {
                Text(SubscribeManagerConfig.getFeaturesTitle())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
            
            ForEach(SubscribeManagerConfig.getFeatures()) { feature in
                FeatureRow(icon: feature.icon, 
                          title: feature.title, 
                          description: feature.description,
                          showDescription: SubscribeManagerConfig.shouldShowFeatureDescriptions())
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.horizontal, 4)
    }
    

}

public struct FeatureRow: View {
    
    public init(icon: String, title: String, description: String, showDescription: Bool) {
        self.icon = icon
        self.title = title
        self.description = description
        self.showDescription = showDescription
    }
    
    public let icon: String
    public let title: String
    public let description: String
    public var showDescription: Bool = true
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(SubscribeManagerConfig.getTintColor())
                .frame(width: 24, height: 24)
            
            if showDescription {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .medium))
                        
                    
                    Text(description)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

// Subscription plan card view
struct SubscriptionPlanCard: View {
    let title: String
    let subtitle: String?
    let price: String
    let period: String
    let perWeekPrice: String?
    let isSelected: Bool
    let hasTrial: Bool
    let showPricePerPeriod: Bool
    let trialDays: Int
    let isBestValue: Bool
    let savingsText: String?
    let lifetimeOfferViewModel: LifetimeOfferViewModel?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                // Plan title and price
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .center, spacing: 6) {
                            Text(title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            if let savingsText = savingsText {
                                Text(savingsText)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.green)
                                    )
                            } else if isBestValue {
                                Text("Best Value")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.green)
                                    )
                            }
                        }
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        
                        
                    }
                    
                    Spacer()
                    
                    
                    
                    HStack(spacing: 4) {
                        Spacer()
                        
                        // Show countdown timer for lifetime offer if available
                        if let lifetimeOfferViewModel = lifetimeOfferViewModel, lifetimeOfferViewModel.isOfferAvailable {
                            CountdownTimer(remainingSeconds: lifetimeOfferViewModel.remainingSeconds)
                                .padding(.top, 4)
                        }
                        
                        if showPricePerPeriod {
                            Text(price)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(period)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        
                        if let perWeekPrice = perWeekPrice {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 0) {
                                Text(perWeekPrice)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("per week")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? SubscribeManagerConfig.getTintColor().opacity(0.15) : Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? SubscribeManagerConfig.getTintColor() : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        price: String,
        period: String,
        perWeekPrice: String? = nil,
        isSelected: Bool,
        hasTrial: Bool = false,
        showPricePerPeriod: Bool = true,
        trialDays: Int = 0,
        isBestValue: Bool = false,
        savingsText: String? = nil,
        lifetimeOfferViewModel: LifetimeOfferViewModel? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.period = period
        self.perWeekPrice = perWeekPrice
        self.isSelected = isSelected
        self.hasTrial = hasTrial
        self.showPricePerPeriod = showPricePerPeriod
        self.trialDays = trialDays
        self.isBestValue = isBestValue
        self.savingsText = savingsText
        self.lifetimeOfferViewModel = lifetimeOfferViewModel
        self.action = action
    }
}



// Helper for error alerts
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

// Helper function to format remaining time
func formatTimeRemaining(_ seconds: Double) -> String {
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    let seconds = Int(seconds) % 60
    
    if hours > 0 {
        return String(format: "%@ \n%dh %02dm %02ds", "Offer Ends In", hours, minutes, seconds)
    } else {
        return String(format: "%@ \n%dm %02ds", "Offer Ends In", minutes, seconds)
    }
}

// Extension to make Optional<String> work with .alert(item:)
extension Optional where Wrapped == String {
    func map<T>(_ transform: (Wrapped) -> T) -> T? {
        if let wrapped = self {
            return transform(wrapped)
        }
        return nil
    }
}

// MARK: - Mock Environment for Previews

#if DEBUG
// Mock product for previews
struct MockProduct {
    let id: String
    let title: String
    let price: Decimal
    let priceString: String
    let type: String // "monthly" or "annual"
}

// Mock subscription package
struct MockPackage {
    let id: String
    let product: MockProduct
}

// Mock offering for previews
struct MockOffering {
    let id: String = "standard"
    let description: String = "Standard offering"
    let packages: [MockPackage]
    
    static func createStandardOffering() -> MockOffering {
        let monthlyProduct = MockProduct(
            id: "com.supertuber.subscription.monthly",
            title: "Monthly Subscription",
            price: 4.99,
            priceString: "$4.99",
            type: "monthly"
        )
        
        let annualProduct = MockProduct(
            id: "com.supertuber.subscription.annual",
            title: "Annual Subscription",
            price: 39.99,
            priceString: "$39.99",
            type: "annual"
        )
        
        let monthlyPackage = MockPackage(id: "monthly", product: monthlyProduct)
        let annualPackage = MockPackage(id: "annual", product: annualProduct)
        
        return MockOffering(packages: [monthlyPackage, annualPackage])
    }
}

// Mock RevenueCat service for previews
class MockRevenueCatService {
    static let shared = MockRevenueCatService()
    
    let mockOffering = MockOffering.createStandardOffering()
    var mockIsPremium = false
    
    func getCustomerInfo(completion: @escaping (Bool, Error?) -> Void) {
        // Return the mock premium status
        completion(mockIsPremium, nil)
    }
    
    func purchase(productID: String, completion: @escaping (Bool, Error?) -> Void) {
        // Simulate successful purchase
        mockIsPremium = true
        completion(true, nil)
    }
    
    func restorePurchases(completion: @escaping (Bool, Error?) -> Void) {
        // Simulate successful restore
        mockIsPremium = true
        completion(true, nil)
    }
}

// Preview version of SubscribeView that uses mocks
//struct SubscribeView_Preview: View {
//    @ObservedObject var viewModel: SubscribeViewModel
//    
//    init(isPremium: Bool = false) {
//        self.store = Store(initialState: .init(isPremium: isPremium)) {
//            SubscribeReducer()
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            Color(UIColor.systemBackground)
//                .ignoresSafeArea()
//            
//            ScrollView {
//                VStack(spacing: 24) {
//                    headerView
//                    
//                    if store.isPremium {
//                        premiumStatusView
//                    } else {
//                        featuresView
//                    }
//                }
//                .padding()
//            }
//            
//            if store.isLoading {
//                ProgressView()
//                    .scaleEffect(1.5)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.black.opacity(0.2))
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Close") {
//                    dismiss()
//                }
//            }
//        }
//        // Card-style subscription options with gradient button
//        .safeAreaInset(edge: .bottom) {
//            VStack(spacing: 16) {
//                // Free trial toggle
//                HStack {
//                    Text("Enable 3-day free trial")
//                        .font(.subheadline)
//                    
//                    Spacer()
//                    
//                    Toggle("", isOn: $freeTrialEnabled)
//                        .labelsHidden()
//                        .onChange(of: freeTrialEnabled) {
//                            if freeTrialEnabled {
//                                // When free trial is enabled, select weekly plan
//                                selectedPlan = "weekly"
//                            } else {
//                                selectedPlan = "yearly"
//                            }
//                        }
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 12)
//                .background(Color(UIColor.secondarySystemBackground))
//                .cornerRadius(24)
//                
//                // Weekly subscription with trial
//                SubscriptionPlanCard(
//                    title: freeTrialEnabled ? "3-Day Free Trial" : "Weekly",
//                    price: freeTrialEnabled ? "then $1.99" : "$1.99",
//                    period: "/ week",
//                    isSelected: selectedPlan == "weekly",
//                    hasTrial: false,
//                    trialDays: 3,
//                    action: {
//                        selectedPlan = "weekly"
//                        freeTrialEnabled = true
//                    }
//                )
//                
//                // Yearly subscription with no trial
//                SubscriptionPlanCard(
//                    title: "Yearly",
//                    subtitle: "$49.99 per year",
//                    price: "$0.96",
//                    period: "/ week",
//                    perWeekPrice: nil,
//                    isSelected: selectedPlan == "yearly",
//                    hasTrial: false,
//                    isBestValue: true,
//                    action: {
//                        selectedPlan = "yearly"
//                        freeTrialEnabled = false
//                    }
//                )
//                
//                // Subscribe button with gradient
//                Button {
//                    mockPurchase()
//                } label: {
//                    Text("Continue")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                        .background(
////                            LinearGradient(
////                                gradient: Gradient(colors: [Color.orange, Color.pink, Color.purple, Color.blue]),
////                                startPoint: .leading,
////                                endPoint: .trailing
////                            )
//                            Color.red
//                            .cornerRadius(24)
//                        )
//                        .foregroundColor(.white)
//                }
//                
//                // Subscription info text
////                Text("Any active subscription will be refunded.\nCancel any time.")
////                    .font(.footnote)
////                    .foregroundColor(.secondary)
////                    .multilineTextAlignment(.center)
//                
//                // Restore purchases text button
//                Button("Restore Purchases") {
//                    // Mock restore for preview
//                    mockRestore()
//                }
//                .font(.caption)
//                .foregroundColor(.secondary)
//            }
//            .padding()
//            .background(Color(UIColor.systemBackground))
//            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
//        }
//    }
//    
//    // Mock functions for preview
//    private func mockPurchase() {
//        isLoading = true
//        
//        // Simulate network delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            // Use mock service to simulate purchase
//            MockRevenueCatService.shared.purchase(productID: "com.supertuber.subscription.monthly") { success, error in
//                self.isLoading = false
//                if success {
//                    self.isPremium = true
//                } else if let error = error {
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//    
//    private func mockRestore() {
//        isLoading = true
//        
//        // Simulate network delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            // Use mock service to simulate restore
//            MockRevenueCatService.shared.restorePurchases { success, error in
//                self.isLoading = false
//                if success {
//                    self.isPremium = true
//                } else if let error = error {
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//    
//    // Reuse the same UI components from the main view
//    private var headerView: some View {
//        VStack(spacing: 12) {
//            HStack(spacing: 10) {
//                AppIconView()
//                
//                Text(store.isPremium ? "Premium Features" : "Unlock Premium Features")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//            }
//            
//            Text("Take your YouTube experience to the next level")
//                .font(.headline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .padding(.top, 20)
//    }
//    
//    private var premiumStatusView: some View {
//        VStack(spacing: 20) {
//            HStack(spacing: 10) {
//                Image(systemName: "checkmark.seal.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(.green)
//                
//                VStack(alignment: .leading) {
//                    Text("Premium Active")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                    
//                    Text("You have access to all premium features")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.green.opacity(0.1))
//            )
//            
//            // List of premium features the user now has access to
//            featuresView
//        }
//    }
//    
//    private var featuresView: some View {
//        VStack(spacing: 8) {
////            Text("Premium Features")
////                .font(.subheadline)
////                .fontWeight(.medium)
////                .frame(maxWidth: .infinity, alignment: .leading)
////                .padding(.horizontal, 12)
////                .padding(.top, 8)
//            
//            FeatureRow(icon: "bookmark.circle.fill", 
//                      title: "Bookmark Insights", 
//                      description: "Save key moments and insights",
//                      showDescription: true)
//            
//            FeatureRow(icon: "infinity.circle.fill", 
//                      title: "Unlimited Summaries", 
//                      description: "Generate as many summaries as you need",
//                      showDescription: true)
//            
//            FeatureRow(icon: "list.bullet.rectangle.fill", 
//                      title: "Section Sub-Summaries", 
//                      description: "View detailed summaries for each section",
//                      showDescription: true)
//            
//            
//        }
//        .padding(.vertical, 8)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(UIColor.secondarySystemBackground))
//        )
//        .padding(.horizontal, 4)
//    }
//}
#endif

//struct SubscribeView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            NavigationView {
//                #if DEBUG
//                SubscribeView_Preview(isPremium: false)
//                    .previewDisplayName("Non-Premium State")
//                #else
//                SubscribeView()
//                #endif
//            }
//            
//            NavigationView {
//                #if DEBUG
//                SubscribeView_Preview(isPremium: true)
//                    .previewDisplayName("Premium State")
//                #else
//                SubscribeView()
//                #endif
//            }
//        }
//    }
//}

struct AppIconView: View {
    var body: some View {
        Image("iconDistilled")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60.0)
    }
}
