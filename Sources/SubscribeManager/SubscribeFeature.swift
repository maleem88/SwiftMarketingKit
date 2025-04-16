import Foundation
import ComposableArchitecture
import RevenueCat

// UserDefaults keys
private enum UserDefaultsKeys {
    static let firstLaunchDate = "com.supertuber.firstLaunchDate"
}

// Helper for managing first launch date
private enum AppFirstLaunch {
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

// Reducer implementation
@Reducer
public struct SubscribeReducer {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.revenueCat) var revenueCat
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var currentOffering: Offering?
        var availablePackages: [Package] = []
        var isPremium: Bool = false
        var isLoading: Bool = true
        var errorMessage: String? = nil
        var selectedPackageIdentifier: String? = nil
        var freeTrialEnabled: Bool = true
        var isLifetimeOfferAvailable: Bool = false
        var lifetimeOfferRemainingSeconds: Double = 0
        var lifetimeOffer = LifetimeOfferReducer.State()
        
        public init(currentOffering: Offering? = nil,
             availablePackages: [Package] = [],
             isPremium: Bool = false,
             isLoading: Bool = true,
             errorMessage: String? = nil,
             selectedPackageIdentifier: String? = nil,
             freeTrialEnabled: Bool = true,
             isLifetimeOfferAvailable: Bool = false,
             lifetimeOfferRemainingSeconds: Double = 0) {
            self.currentOffering = currentOffering
            self.availablePackages = availablePackages
            self.isPremium = isPremium
            self.isLoading = isLoading
            self.errorMessage = errorMessage
            self.selectedPackageIdentifier = selectedPackageIdentifier
            self.freeTrialEnabled = freeTrialEnabled
            self.isLifetimeOfferAvailable = isLifetimeOfferAvailable
            self.lifetimeOfferRemainingSeconds = lifetimeOfferRemainingSeconds
        }
        
        var selectedPackage: Package? {
            guard let identifier = selectedPackageIdentifier else { return nil }
            return availablePackages.first { $0.identifier == identifier }
        }
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case loadOfferings
        case offeringsResponse(TaskResult<Offerings?>)
        case checkPremiumStatus
        case premiumStatusResponse(TaskResult<Bool>)
        case selectPlan(String)
        case toggleFreeTrial(Bool)
        case purchaseSubscription(String)
        case purchaseResponse(TaskResult<Bool>)
        case restorePurchases
        case restoreResponse(TaskResult<Bool>)
        case checkLifetimeOfferAvailability
        case updateLifetimeOfferTimer
        case dismiss
        case lifetimeOffer(LifetimeOfferReducer.Action)
    }
    
    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.lifetimeOffer, action: \.lifetimeOffer) {
            LifetimeOfferReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Register first launch date if not already set
                AppFirstLaunch.registerFirstLaunchIfNeeded()
                
                return .run { send in
                    await send(.loadOfferings)
                    await send(.checkPremiumStatus)
                    await send(.checkLifetimeOfferAvailability)
                    await send(.lifetimeOffer(.onAppear))
                }
                
            case .loadOfferings:
                state.isLoading = true
                return .run { send in
                    await send(.offeringsResponse(TaskResult {
                        try await revenueCat.getOfferings()
                    }))
                }
                
            case let .offeringsResponse(.success(offerings)):
                state.isLoading = false
                state.currentOffering = offerings?.current
                
                // Extract available packages from the offering
                if let packages = offerings?.current?.availablePackages, !packages.isEmpty {
                    // If lifetime offer is available, filter packages to include lifetime product
                    if state.isLifetimeOfferAvailable {
                        state.availablePackages = packages
                    } else {
                        // Filter out lifetime packages if offer has expired
                        state.availablePackages = packages.filter { $0.packageType != .lifetime }
                    }
                    
                    // Select the first package by default
                    if !state.availablePackages.isEmpty {
                        state.selectedPackageIdentifier = state.availablePackages.first?.identifier
                    }
                }
                
                // Start timer updates if lifetime offer is available
                if state.isLifetimeOfferAvailable {
                    return .run { send in
                        await send(.updateLifetimeOfferTimer)
                    }
                }
                
                return .none
                
            case let .offeringsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Error loading offerings: \(error.localizedDescription)"
                return .none
                
            case .checkPremiumStatus:
                return .run { send in
                    await send(.premiumStatusResponse(TaskResult {
                        try await revenueCat.checkPremiumStatus()
                    }))
                }
                
            case let .premiumStatusResponse(.success(isPremium)):
                state.isPremium = isPremium
                return .none
                
            case let .premiumStatusResponse(.failure(error)):
                state.errorMessage = "Error checking premium status: \(error.localizedDescription)"
                return .none
                
            case let .selectPlan(packageIdentifier):
                state.selectedPackageIdentifier = packageIdentifier
                
                // Determine if this package has a free trial
                if let selectedPackage = state.selectedPackage {
                    // Check if this is a weekly package (assuming shorter duration = weekly)
                    let isWeekly = selectedPackage.packageType == .weekly || selectedPackage.packageType == .monthly
                    state.freeTrialEnabled = isWeekly
                }
                return .none
                
            case .binding(\.freeTrialEnabled):
//                state.freeTrialEnabled = enabled
                
                // Select appropriate package based on trial preference
                if state.freeTrialEnabled {
                    // Find a weekly/monthly package that supports trials
                    if let weeklyPackage = state.availablePackages.first(where: { $0.packageType == .weekly }) {
                        state.selectedPackageIdentifier = weeklyPackage.identifier
                    } else if let monthlyPackage = state.availablePackages.first(where: { $0.packageType == .monthly }) {
                        state.selectedPackageIdentifier = monthlyPackage.identifier
                    }
                } else {
                    // Find a yearly package
                    if let yearlyPackage = state.availablePackages.first(where: { $0.packageType == .annual }) {
                        state.selectedPackageIdentifier = yearlyPackage.identifier
                    }
                }
                return .none
                
            case let .purchaseSubscription(productID):
                state.isLoading = true
                return .run { send in
                    await send(.purchaseResponse(TaskResult {
                        try await revenueCat.purchase(productID)
                    }))
                }
                
            case let .purchaseResponse(.success(isPremium)):
                state.isLoading = false
                state.isPremium = isPremium
                if isPremium {
                    return .run { _ in await self.dismiss() }
                }
                return .none
                
            case let .purchaseResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Error during purchase: \(error.localizedDescription)"
                return .none
                
            case .restorePurchases:
                state.isLoading = true
                return .run { send in
                    await send(.restoreResponse(TaskResult {
                        try await revenueCat.restore()
                    }))
                }
                
            case let .restoreResponse(.success(isPremium)):
                state.isLoading = false
                state.isPremium = isPremium
                if isPremium {
                    return .run { _ in await self.dismiss() }
                }
                return .none
                
            case let .restoreResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Error restoring purchases: \(error.localizedDescription)"
                return .none
                
            case .checkLifetimeOfferAvailability:
                // Check if lifetime offer is available based on first launch date
                state.isLifetimeOfferAvailable = AppFirstLaunch.isLifetimeOfferAvailable()
                state.lifetimeOfferRemainingSeconds = AppFirstLaunch.getRemainingSecondsForLifetimeOffer()
                
                // If lifetime offer is available, start a timer to update the countdown
                if state.isLifetimeOfferAvailable {
                    return .run { send in
                        // Update the timer every second
                        while true {
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                            await send(.updateLifetimeOfferTimer)
                        }
                    }
                }
                return .none
                
            case .updateLifetimeOfferTimer:
                // Update the remaining time for the lifetime offer
                state.lifetimeOfferRemainingSeconds = AppFirstLaunch.getRemainingSecondsForLifetimeOffer()
                
                // If the offer has expired, update the availability and filter packages
                if state.lifetimeOfferRemainingSeconds <= 0 {
                    state.isLifetimeOfferAvailable = false
                    
                    // Remove lifetime packages from available packages
                    state.availablePackages = state.availablePackages.filter { $0.packageType != .lifetime }
                    
                    // If the selected package was a lifetime package, select a different one
                    if let selectedPackage = state.selectedPackage, selectedPackage.packageType == .lifetime {
                        state.selectedPackageIdentifier = state.availablePackages.first?.identifier
                    }
                }
                return .none
                
            case .dismiss:
                return .run { _ in await self.dismiss() }
                
            case .lifetimeOffer:
                return .none
                
            default:
                return .none
            }
        }
    }
}
