import Foundation
import SwiftUI

// UserDefaults keys
private enum UserDefaultsKeys {
    static let ratingFirstLaunchDate = "com.supertuber.ratingfirstLaunchDate"
    static let lifetimeOfferfirstLaunchDate = "com.supertuber.lifetimeOfferfirstLaunchDate"
}

public class LifetimeOfferViewModel: ObservableObject {
    // Properties
    @Published var isOfferAvailable: Bool = false
    @Published var remainingSeconds: Double = 0
    @Published var title: String = "Special Launch Offer"
    @Published var subtitle: String = "Lifetime access offer expires in:"
    @Published var showSubscribeView = false
    @Published var didInit = false
    var timerTask: Task<Void, Never>? = nil
    
    // Initializer
    public init(
        isOfferAvailable: Bool = false,
        remainingSeconds: Double = 0,
        title: String = "Special Launch Offer",
        subtitle: String = "Lifetime access offer expires in:"
    ) {
        self.isOfferAvailable = isOfferAvailable
        self.remainingSeconds = remainingSeconds
        self.title = title
        self.subtitle = subtitle
    }
    
    // Helper for managing first launch date
    public enum AppFirstLaunch {
        static func registerFirstLaunchIfNeeded() {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: UserDefaultsKeys.lifetimeOfferfirstLaunchDate) == nil {
                defaults.set(Date(), forKey: UserDefaultsKeys.lifetimeOfferfirstLaunchDate)
            }
        }
        
        static func getFirstLaunchDate() -> Date? {
            return UserDefaults.standard.object(forKey: UserDefaultsKeys.lifetimeOfferfirstLaunchDate) as? Date
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
    
    // MARK: - Public Methods
    
    // Called when the view appears
    public func onAppear() async {
        guard !didInit else { return }
        
        didInit = true
        // Register first launch date if not already set
        AppFirstLaunch.registerFirstLaunchIfNeeded()
        
        await checkOfferAvailability()
    }
    
    // Check if lifetime offer is available
    public func checkOfferAvailability() async {
        // Check if lifetime offer is available based on first launch date
        isOfferAvailable = AppFirstLaunch.isLifetimeOfferAvailable()
        remainingSeconds = AppFirstLaunch.getRemainingSecondsForLifetimeOffer()
        
        // If lifetime offer is available, start a timer to update the countdown
        if isOfferAvailable && remainingSeconds > 0 {
            // Cancel any existing timer task
            timerTask?.cancel()
            
            // Create a new timer task
            timerTask = Task {
                while !Task.isCancelled {
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        await updateTimer()
                    } catch {
                        break
                    }
                }
            }
        }
    }
    
    // Update the timer
    public func updateTimer() async {
        // Update the remaining time for the lifetime offer
        remainingSeconds = AppFirstLaunch.getRemainingSecondsForLifetimeOffer()
        
        // If the offer has expired, update the availability
        if remainingSeconds <= 0 {
            isOfferAvailable = false
            
            // Cancel the timer task
            timerTask?.cancel()
            timerTask = nil
        }
    }
    
    // Set show subscribe view
    public func setShowSubscribeView(_ value: Bool) {
        showSubscribeView = value
    }
    
    deinit {
        // Cancel any running timer tasks
        timerTask?.cancel()
    }
}
