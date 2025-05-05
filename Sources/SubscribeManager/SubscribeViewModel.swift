import Foundation
import SwiftUI
import RevenueCat

/// Model representing a subscription plan for display in the UI
public struct SubscriptionPlanModel {
    let package: Package
    let title: String
    let subtitle: String?
    let price: String
    let period: String
    let perWeekPrice: String?
    let isSelected: Bool
    let hasTrial: Bool
    let showPricePerPeriod: Bool
    let isBestValue: Bool
    let savingsText: String?
    let isLifetime: Bool
}

// UserDefaults keys
private enum UserDefaultsKeys {
    static let firstLaunchDate = "com.supertuber.firstLaunchDate"
}

// Helper for managing first launch date
public enum AppFirstLaunch {
    static func registerFirstLaunchIfNeeded() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: UserDefaultsKeys.firstLaunchDate) == nil {
            defaults.set(Date(), forKey: UserDefaultsKeys.firstLaunchDate)
        }
    }
    
    static func getFirstLaunchDate() -> Date? {
        return UserDefaults.standard.object(forKey: UserDefaultsKeys.firstLaunchDate) as? Date
    }
    
    static func isLifetimeOfferAvailable() -> Bool {
        guard let firstLaunchDate = getFirstLaunchDate() else {
            // If no first launch date is recorded, register it now and return true
            registerFirstLaunchIfNeeded()
            return true
        }
        
        // Check if less than 24 hours have passed since first launch
        let timeInterval = Date().timeIntervalSince(firstLaunchDate)
        let hoursElapsed = timeInterval / 3600 // Convert seconds to hours
        return hoursElapsed < 24
    }
    
    static func getRemainingSecondsForLifetimeOffer() -> Double {
        guard let firstLaunchDate = getFirstLaunchDate() else { return 0 }
        
        // Calculate time remaining until 24 hours after first launch
        let expirationDate = firstLaunchDate.addingTimeInterval(24 * 3600) // 24 hours in seconds
        let timeRemaining = expirationDate.timeIntervalSince(Date())
        
        // If time remaining is negative, offer has expired
        if timeRemaining <= 0 {
            return 0
        }
        
        return timeRemaining
    }
}

public class SubscribeViewModel: ObservableObject {
    // Properties
    @Published var currentOffering: Offering?
    @Published var availablePackages: [Package] = []
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var selectedPackageIdentifier: String? = nil
    @Published var freeTrialEnabled: Bool = false
    @Published var isLifetimeOfferAvailable: Bool = false
    @Published var lifetimeOfferRemainingSeconds: Double = 0
    @Published var lifetimeOfferViewModel: LifetimeOfferViewModel
    var timerTask: Task<Void, Never>? = nil
    
    // Computed property for selected package
    var selectedPackage: Package? {
        guard let identifier = selectedPackageIdentifier else { return nil }
        return availablePackages.first { $0.identifier == identifier }
    }
    
    // RevenueCat client
    private let revenueCatClient: RevenueCatClient
    
    // Dismiss action
    var onDismiss: (() -> Void)?
    
    // Initializer
    public init(revenueCatClient: RevenueCatClient = RevenueCatClient.shared) {
        self.revenueCatClient = revenueCatClient
        self.lifetimeOfferViewModel = LifetimeOfferViewModel()
    }
    
    // MARK: - Public Methods
    
    /// Get a formatted subscription plan model for a package
    /// - Parameter package: The RevenueCat package
    /// - Returns: A formatted SubscriptionPlanModel for display
    public func getSubscriptionPlanModel(for package: Package) -> SubscriptionPlanModel {
        let isWeekly = package.packageType == .weekly
        let isLifetime = package.packageType == .lifetime
        let shouldShowPerWeek = !isWeekly && !isLifetime
        let isSelected = selectedPackageIdentifier == package.identifier
        let isBestValue = package.packageType == SubscribeManagerConfig.getBestValuePackageType()
        
        // Calculate savings text if this is the best value package and savings display is enabled
        var savingsText: String? = nil
        if isBestValue && SubscribeManagerConfig.shouldShowSavingsPercentage() {
            if let savingsPercentage = calculateSavingsPercentage(for: package) {
                let formatString = SubscribeManagerConfig.getSavingsTextFormat()
                savingsText = formatString.replacingOccurrences(of: "{percentage}", with: "\(savingsPercentage)")
            }
        }
        
        return SubscriptionPlanModel(
            package: package,
            title: getPackageTitle(package),
            subtitle: shouldShowPerWeek ? getSubtitle(package) : isLifetime ? getPackagePrice(package) : nil,
            price: getPackagePrice(package),
            period: getPackagePeriod(package),
            perWeekPrice: shouldShowPerWeek ? getWeeklyPrice(package) : nil,
            isSelected: isSelected,
            hasTrial: isWeekly && freeTrialEnabled,
            showPricePerPeriod: !shouldShowPerWeek && !isLifetime,
            isBestValue: isBestValue,
            savingsText: savingsText,
            isLifetime: isLifetime
        )
    }
    
    /// Get subscription plan models for all available packages
    /// - Returns: Array of SubscriptionPlanModel objects
    public func getSubscriptionPlanModels() -> [SubscriptionPlanModel] {
        return availablePackages.map { getSubscriptionPlanModel(for: $0) }
    }
    
    // Helper methods for formatting package information
    private func getPackageTitle(_ package: Package) -> String {
        switch package.packageType {
        case .weekly:
            return freeTrialEnabled ? "3-Day Free Trial" : "Weekly"
        case .monthly:
            return "Monthly"
        case .annual:
            return "Yearly"
        case .lifetime:
            return "Lifetime Access"
        default:
            return package.identifier
        }
    }
    
    private func getPackagePrice(_ package: Package) -> String {
        let price = package.storeProduct.localizedPriceString
        if package.packageType == .weekly && freeTrialEnabled {
            return "then \(price)"
        }
        return price
    }
    
    private func getPackagePeriod(_ package: Package) -> String {
        switch package.packageType {
        case .weekly:
            return "per week"
        case .monthly:
            return "per month"
        case .annual:
            return "per year"
        case .lifetime:
            return ""
        default:
            return ""
        }
    }
    
    private func getSubtitle(_ package: Package) -> String {
        return getPackagePrice(package)
    }
    
    private func getWeeklyPrice(_ package: Package) -> String? {
        guard package.packageType == .annual || package.packageType == .monthly else { return nil }
        return package.storeProduct.localizedPricePerWeek
    }
    
    /// Calculate the savings percentage between the weekly package and the given package
    /// - Parameter package: The package to compare with the weekly package
    /// - Returns: The savings percentage as an integer, or nil if calculation is not possible
    public func calculateSavingsPercentage(for package: Package) -> Int? {
        // Find the weekly package for comparison
        guard let weeklyPackage = availablePackages.first(where: { $0.packageType == .weekly }) else {
            return nil
        }
        
        // Get the price per week for both packages
        guard let weeklyPrice = weeklyPackage.storeProduct.price as NSDecimalNumber?,
              let packagePrice = package.storeProduct.price as NSDecimalNumber? else {
            return nil
        }
        
        // Calculate the price per week for the package
        var pricePerWeek: NSDecimalNumber
        
        switch package.packageType {
        case .weekly:
            pricePerWeek = packagePrice
        case .monthly:
            // Assuming 4.3 weeks per month on average
            pricePerWeek = packagePrice.dividing(by: NSDecimalNumber(value: 4.3))
        case .annual:
            // 52 weeks per year
            pricePerWeek = packagePrice.dividing(by: NSDecimalNumber(value: 52))
        default:
            return nil
        }
        
        // Calculate savings percentage
        if weeklyPrice.doubleValue <= 0 || pricePerWeek.doubleValue <= 0 {
            return nil
        }
        
        let savingsPercentage = (1 - (pricePerWeek.doubleValue / weeklyPrice.doubleValue)) * 100
        
        // Return as rounded integer
        return abs(Int(round(savingsPercentage)))
    }
    
    // Called when the view appears
    public func onAppear() async {
        // Register first launch date if not already set
        AppFirstLaunch.registerFirstLaunchIfNeeded()
        
        // Load offerings, check premium status, and check lifetime offer availability
        await loadOfferings()
        await checkPremiumStatus()
        await checkLifetimeOfferAvailability()
        
        // Initialize the lifetime offer view model
        await lifetimeOfferViewModel.onAppear()
    }
    
    // Load offerings from RevenueCat
    
    @MainActor
    public func loadOfferings() async {
        
        isLoading = true
        
        do {
            let offerings = try await revenueCatClient.getOfferings()
            
            // Update state with offerings data
            self.currentOffering = offerings?.current
            
            // Extract available packages from the offering
            if let packages = offerings?.current?.availablePackages, !packages.isEmpty {
                // If lifetime offer is available, filter packages to include lifetime product
                if isLifetimeOfferAvailable {
                    self.availablePackages = packages
                } else {
                    // Filter out lifetime packages if offer has expired
                    self.availablePackages = packages.filter { $0.packageType != .lifetime }
                }
                
                // Select the first package by default
                if !self.availablePackages.isEmpty {
                    self.selectedPackageIdentifier = self.availablePackages.first {$0.packageType == SubscribeManagerConfig.getBestValuePackageType()}?.identifier
                }
            }
            
            // Start timer updates if lifetime offer is available
            if isLifetimeOfferAvailable {
                await updateLifetimeOfferTimer()
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Error loading offerings: \(error.localizedDescription)"
        }
    }
    
    // Check premium status
    @MainActor
    public func checkPremiumStatus() async {
        do {
            isPremium = try await revenueCatClient.checkPremiumStatus()
        } catch {
            errorMessage = "Error checking premium status: \(error.localizedDescription)"
        }
    }
    
    // Select a plan by package identifier
    public func selectPlan(_ packageIdentifier: String) {
        selectedPackageIdentifier = packageIdentifier
        
        // Determine if this package has a free trial
        if let selectedPackage = selectedPackage {
            // Check if this is a weekly package (assuming shorter duration = weekly)
            let isWeekly = selectedPackage.packageType == .weekly || selectedPackage.packageType == .monthly
            freeTrialEnabled = isWeekly
        }
    }
    
    // Toggle free trial
    public func toggleFreeTrial(_ enabled: Bool) {
        freeTrialEnabled = enabled
        
        // Select appropriate package based on trial preference
        if freeTrialEnabled {
            // Find a weekly/monthly package that supports trials
            if let weeklyPackage = availablePackages.first(where: { $0.packageType == .weekly }) {
                selectedPackageIdentifier = weeklyPackage.identifier
            } else if let monthlyPackage = availablePackages.first(where: { $0.packageType == .monthly }) {
                selectedPackageIdentifier = monthlyPackage.identifier
            }
        } else {
            // Find the best value package as configured
            let bestValuePackageType = SubscribeManagerConfig.getBestValuePackageType()
            if let bestValuePackage = availablePackages.first(where: { $0.packageType == bestValuePackageType }) {
                selectedPackageIdentifier = bestValuePackage.identifier
            }
        }
    }
    
    // Purchase subscription
    public func purchaseSubscription(_ productID: String) async {
        isLoading = true
        
        do {
            isPremium = try await revenueCatClient.purchase(productID)
            isLoading = false
            
            if isPremium {
                onDismiss?()
            }
        } catch {
            isLoading = false
            errorMessage = "Error during purchase: \(error.localizedDescription)"
        }
    }
    
    // Restore purchases
    public func restorePurchases() async {
        isLoading = true
        
        do {
            isPremium = try await revenueCatClient.restore()
            isLoading = false
            
            if isPremium {
                onDismiss?()
            }
        } catch {
            isLoading = false
            errorMessage = "Error restoring purchases: \(error.localizedDescription)"
        }
    }
    
    // Check lifetime offer availability
    @MainActor
    public func checkLifetimeOfferAvailability() async {
        // Check if lifetime offer is available based on first launch date
        isLifetimeOfferAvailable = AppFirstLaunch.isLifetimeOfferAvailable()
        lifetimeOfferRemainingSeconds = AppFirstLaunch.getRemainingSecondsForLifetimeOffer()
        
        // If lifetime offer is available, start a timer to update the countdown
        if isLifetimeOfferAvailable {
            // Cancel any existing timer task
            timerTask?.cancel()
            
            // Create a new timer task
            timerTask = Task {
                while !Task.isCancelled {
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        await updateLifetimeOfferTimer()
                    } catch {
                        break
                    }
                }
            }
        }
    }
    
    // Update lifetime offer timer
    @MainActor
    public func updateLifetimeOfferTimer() async {
        // Update the remaining time for the lifetime offer
        lifetimeOfferRemainingSeconds = AppFirstLaunch.getRemainingSecondsForLifetimeOffer()
        
        // If the offer has expired, update the availability and filter packages
        if lifetimeOfferRemainingSeconds <= 0 {
            isLifetimeOfferAvailable = false
            
            // Remove lifetime packages from available packages
            availablePackages = availablePackages.filter { $0.packageType != .lifetime }
            
            // If the selected package was a lifetime package, select a different one
            if let selectedPackage = selectedPackage, selectedPackage.packageType == .lifetime {
                selectedPackageIdentifier = availablePackages.first?.identifier
            }
            
            // Cancel the timer task
            timerTask?.cancel()
            timerTask = nil
        }
    }
    
    // Dismiss the view
    public func dismiss() {
        // Cancel any running timer tasks
        timerTask?.cancel()
        timerTask = nil
        
        // Call the dismiss closure
        onDismiss?()
    }
    
    deinit {
        // Cancel any running timer tasks
        timerTask?.cancel()
    }
}
