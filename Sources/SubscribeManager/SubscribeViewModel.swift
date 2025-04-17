import Foundation
import SwiftUI
import RevenueCat

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
    @Published var freeTrialEnabled: Bool = true
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
                    self.selectedPackageIdentifier = self.availablePackages.first?.identifier
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
            // Find a yearly package
            if let yearlyPackage = availablePackages.first(where: { $0.packageType == .annual }) {
                selectedPackageIdentifier = yearlyPackage.identifier
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
