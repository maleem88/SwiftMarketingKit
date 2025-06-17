//
//  CreditClient.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 07/04/2025.
//

import Foundation
import SwiftUI

// MARK: - Credit Mode

/// Defines the mode of operation for the credit system
public enum CreditMode: String, Codable {
    /// Credits are allocated once and do not automatically renew
    case oneTime
    
    /// Credits are renewed periodically based on the configured renewal period
    case renewal
}

// MARK: - Credit Client

/// A service that manages the credit system
public class CreditClient {
    // MARK: - Singleton
    public static let shared = CreditClient()
    
    // MARK: - UserDefaults Keys
    private let totalCreditsKey = "com.credits.totalCredits"
    private let consumedCreditsKey = "com.credits.consumedCredits"
    private let nextRenewalDateKey = "com.credits.nextRenewalDate"
    private let creditHistoryKey = "com.credits.creditHistory"
    private let creditModeKey = "com.credits.creditMode"
    
    // MARK: - Configuration Properties
    
    /// The current credit mode (one-time or renewal)
    public var creditMode: CreditMode = .renewal {
        didSet {
            // Save the credit mode to UserDefaults
            if let encoded = try? JSONEncoder().encode(creditMode) {
                UserDefaults.standard.set(encoded, forKey: creditModeKey)
            }
            
            // Update UI text based on mode
            updateUITextForCurrentMode()
        }
    }
    
    public var creditAmount: Int = 100 {
        didSet {
            // Update total credits when credit amount changes
            UserDefaults.standard.set(creditAmount, forKey: totalCreditsKey)
        }
    }
    
    // MARK: - UI Customization
    public var daysUntilRenewText: String = "Days until renewal"
    public var creditsTitleText: String = "Monthly Credits"
    public var oneTimeCreditsTitleText: String = "Available Credits"
    public var historyTitleText: String = "Recent Activity"
    public var insufficientCreditsAlertTitle: String = "Insufficient Credits"
    public var insufficientCreditsAlertMessage: String = "You need %@ credits but only have %@ remaining. Your credits will renew in %@ days."
    public var oneTimeInsufficientCreditsAlertMessage: String = "You need %@ credits but only have %@ remaining."
    
    // MARK: - Color Settings
    public var highCreditThreshold: Double = 0.6  // Above this percentage is green
    public var mediumCreditThreshold: Double = 0.3 // Above this percentage is orange, below is red
    public var highCreditColor: Color = .green
    public var mediumCreditColor: Color = .orange
    public var lowCreditColor: Color = .red
    
    // MARK: - Display Options
    public var showHistorySection: Bool = true
    public var maxHistoryItems: Int = 5
    
    // MARK: - Renewal Period
    public enum RenewalPeriod: CustomStringConvertible {
        case daily
        case weekly(dayOfWeek: Int)  // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        case monthly(dayOfMonth: Int) // 1-28 (to handle February)
        
        public var description: String {
            switch self {
            case .daily:
                return "Daily"
            case .weekly:
                return "Weekly"
            case .monthly:
                return "Monthly"
            }
        }
        
        var calendarComponent: Calendar.Component {
            switch self {
            case .daily:
                return .day
            case .weekly:
                return .weekOfYear
            case .monthly:
                return .month
            }
        }
    }
    
    public var renewalPeriod: RenewalPeriod = .monthly(dayOfMonth: 1) {
        didSet {
            // Update the next renewal date based on the new period
            let nextRenewalDate = calculateNextRenewalDate()
            UserDefaults.standard.set(nextRenewalDate, forKey: nextRenewalDateKey)
            
            // Only update title text if it contains the old period description
            if creditsTitleText.contains(oldValue.description) {
                creditsTitleText = "\(renewalPeriod.description) Credits"
            }
        }
    }
    
    
    // MARK: - Initialization
    private init() {
        // Load credit mode from UserDefaults if available
        if let modeData = UserDefaults.standard.data(forKey: creditModeKey),
           let savedMode = try? JSONDecoder().decode(CreditMode.self, from: modeData) {
            self.creditMode = savedMode
        }
        
        // Initialize UserDefaults if needed
        initializeUserDefaultsIfNeeded()
        
        // Update UI text based on current mode
        updateUITextForCurrentMode()
    }
    
    // MARK: - Public Methods
    
    public func consumeCredits(amount: Int) -> Bool {
        // Only check for renewal if in renewal mode
        if creditMode == .renewal {
            let renewalOccurred = checkAndRenewCreditsIfNeeded()
        }
        
        let consumedCredits = UserDefaults.standard.integer(forKey: consumedCreditsKey)
        let totalCredits = UserDefaults.standard.integer(forKey: totalCreditsKey)
        
        // Check if enough credits are available
        if consumedCredits + amount <= totalCredits {
            UserDefaults.standard.set(consumedCredits + amount, forKey: consumedCreditsKey)
            
            // Add to history
            if let historyData = UserDefaults.standard.data(forKey: creditHistoryKey),
               var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                let newItem = CreditHistoryItem(amount: amount, description: "Credit consumed")
                history.append(newItem)
                // Keep only last 50 items
                if history.count > 50 {
                    history = Array(history.suffix(50))
                }
                if let encoded = try? JSONEncoder().encode(history) {
                    UserDefaults.standard.set(encoded, forKey: creditHistoryKey)
                }
            }
            
            return true
        }
        return false
    }
    
    public func getRemainingCredits() -> Int {
        // Check if renewal is needed
        let renewalOccurred = checkAndRenewCreditsIfNeeded()
        
        let consumedCredits = UserDefaults.standard.integer(forKey: consumedCreditsKey)
        let totalCredits = UserDefaults.standard.integer(forKey: totalCreditsKey)
        return totalCredits - consumedCredits
    }
    
    public func getTotalCredits() -> Int {
        return UserDefaults.standard.integer(forKey: totalCreditsKey)
    }
    
    public func getNextRenewalDate() -> Date {
        if let nextRenewalDate = UserDefaults.standard.object(forKey: nextRenewalDateKey) as? Date {
            return nextRenewalDate
        }
        
        // If not set, calculate and set it
        let nextRenewalDate = calculateNextRenewalDate()
        UserDefaults.standard.set(nextRenewalDate, forKey: nextRenewalDateKey)
        return nextRenewalDate
    }
    
    public func getDaysUntilRenewal() -> Int {
        // In one-time mode, there's no renewal
        if creditMode == .oneTime {
            return 0
        }
        
        if let nextRenewalDate = UserDefaults.standard.object(forKey: nextRenewalDateKey) as? Date {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: Date(), to: nextRenewalDate)
            return max(0, components.day ?? 0)
        }
        return 0
    }
    
    public func resetCredits() {
        let totalCredits = UserDefaults.standard.integer(forKey: totalCreditsKey)
        UserDefaults.standard.set(0, forKey: consumedCreditsKey)
        
        // If in one-time mode, this is effectively adding credits
        
        // Add to history
        if let historyData = UserDefaults.standard.data(forKey: creditHistoryKey),
           var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
            let newItem = CreditHistoryItem(amount: totalCredits, description: "Credits renewed")
            history.append(newItem)
            if let encoded = try? JSONEncoder().encode(history) {
                UserDefaults.standard.set(encoded, forKey: creditHistoryKey)
            }
        }
    }
    
    /// Sets the credit mode for the system
    /// - Parameter mode: The credit mode to use (.oneTime or .renewal)
    /// - Returns: The client instance for chaining
    @discardableResult
    public func setCreditMode(_ mode: CreditMode) -> Self {
        self.creditMode = mode
        return self
    }
    
    /// Updates UI text elements based on the current credit mode
    private func updateUITextForCurrentMode() {
        if creditMode == .oneTime {
            creditsTitleText = oneTimeCreditsTitleText
        } else {
            // Set based on renewal period
            switch renewalPeriod {
            case .daily:
                creditsTitleText = "Daily Credits"
            case .weekly:
                creditsTitleText = "Weekly Credits"
            case .monthly:
                creditsTitleText = "Monthly Credits"
            }
        }
    }
    
    public func checkAndRenewCreditsIfNeeded() -> Bool {
        // Skip renewal if in one-time mode
        if creditMode == .oneTime {
            return false
        }
        
        if let nextRenewalDate = UserDefaults.standard.object(forKey: nextRenewalDateKey) as? Date {
            if Date() >= nextRenewalDate {
                // Reset consumed credits
                UserDefaults.standard.set(0, forKey: consumedCreditsKey)
                
                // Calculate next renewal date based on configured period
                let newRenewalDate = calculateNextRenewalDate(from: nextRenewalDate)
                UserDefaults.standard.set(newRenewalDate, forKey: nextRenewalDateKey)
                
                // Add to history
                if let historyData = UserDefaults.standard.data(forKey: creditHistoryKey),
                   var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                    let totalCredits = UserDefaults.standard.integer(forKey: totalCreditsKey)
                    let renewalDescription = "\(renewalPeriod.description) credits renewed"
                    let newItem = CreditHistoryItem(amount: totalCredits, description: renewalDescription)
                    history.append(newItem)
                    if let encoded = try? JSONEncoder().encode(history) {
                        UserDefaults.standard.set(encoded, forKey: creditHistoryKey)
                    }
                }
                
                return true
            }
        }
        return false
    }
    
    public func getCreditHistory() -> [CreditHistoryItem] {
        if let historyData = UserDefaults.standard.data(forKey: creditHistoryKey),
           let history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
            return history
        }
        return []
    }
    
    // MARK: - Private Methods
    
    private func initializeUserDefaultsIfNeeded() {
        // Initialize credit mode if not set
        if UserDefaults.standard.object(forKey: creditModeKey) == nil {
            if let encoded = try? JSONEncoder().encode(creditMode) {
                UserDefaults.standard.set(encoded, forKey: creditModeKey)
            }
        }
        
        // Reset state if requested
        if UserDefaults.standard.object(forKey: totalCreditsKey) == nil {
            UserDefaults.standard.set(creditAmount, forKey: totalCreditsKey)
        }
        
        // Initialize consumed credits if not set
        if UserDefaults.standard.object(forKey: consumedCreditsKey) == nil {
            UserDefaults.standard.set(0, forKey: consumedCreditsKey)
        }
        
        // Initialize next renewal date if not set (only relevant for renewal mode)
        if UserDefaults.standard.object(forKey: nextRenewalDateKey) == nil {
            // Calculate next renewal date based on configured period
            let nextRenewalDate = calculateNextRenewalDate()
            UserDefaults.standard.set(nextRenewalDate, forKey: nextRenewalDateKey)
        }
        
        // Initialize credit history if not set
        if UserDefaults.standard.object(forKey: creditHistoryKey) == nil {
            let emptyHistory: [CreditHistoryItem] = []
            if let encoded = try? JSONEncoder().encode(emptyHistory) {
                UserDefaults.standard.set(encoded, forKey: creditHistoryKey)
            }
        }
    }
    
    private func calculateNextRenewalDate(from date: Date? = nil) -> Date {
        let calendar = Calendar.current
        let startDate = date ?? Date()
        
        switch renewalPeriod {
        case .daily:
            // For daily, simply add one day
            var components = DateComponents()
            components.day = 1
            return calendar.date(byAdding: components, to: startDate) ?? startDate.addingTimeInterval(86400)
            
        case .weekly(let dayOfWeek):
            // For weekly, find the next occurrence of the specified day of week
            let currentDayOfWeek = calendar.component(.weekday, from: startDate)
            var daysToAdd = dayOfWeek - currentDayOfWeek
            
            // If today is the specified day or we've already passed it this week, move to next week
            if daysToAdd <= 0 {
                daysToAdd += 7
            }
            
            var components = DateComponents()
            components.day = daysToAdd
            return calendar.date(byAdding: components, to: startDate) ?? startDate.addingTimeInterval(Double(daysToAdd) * 86400)
            
        case .monthly(let dayOfMonth):
            // For monthly, move to the specified day in the next month
            let currentMonth = calendar.component(.month, from: startDate)
            let currentYear = calendar.component(.year, from: startDate)
            let currentDay = calendar.component(.day, from: startDate)
            
            var components = DateComponents()
            components.year = currentYear
            
            // If we haven't reached the renewal day this month yet, use this month
            if currentDay < dayOfMonth {
                components.month = currentMonth
            } else {
                // Otherwise use next month
                components.month = currentMonth + 1
                // Handle December -> January transition
                if components.month! > 12 {
                    components.month = 1
                    components.year = currentYear + 1
                }
            }
            
            // Set the day, capping at the last day of the month if needed
            components.day = min(dayOfMonth, 28) // Cap at 28 to handle February
            
            if let nextDate = calendar.date(from: components) {
                return nextDate
            }
            
            // Fallback: add one month
            components = DateComponents()
            components.month = 1
            return calendar.date(byAdding: components, to: startDate) ?? startDate.addingTimeInterval(30 * 86400)
        }
    }
}

// MARK: - Credit History Item
public struct CreditHistoryItem: Codable, Equatable, Identifiable {
    public var id: UUID
    public var amount: Int
    public var timestamp: Date
    public var description: String
    
    public init(id: UUID = UUID(), amount: Int, timestamp: Date = Date(), description: String) {
        self.id = id
        self.amount = amount
        self.timestamp = timestamp
        self.description = description
    }
}

