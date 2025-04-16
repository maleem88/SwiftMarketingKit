//
//  CreditClient.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 07/04/2025.
//

import Foundation
import SwiftUI

// MARK: - Credit Client

/// A service that manages the monthly credit system
public struct CreditClient {
    // MARK: - Constants
    enum Constants {
        static let totalCreditsKey = "com.supertuber.totalCredits"
        static let consumedCreditsKey = "com.supertuber.consumedCredits"
        static let nextRenewalDateKey = "com.supertuber.nextRenewalDate"
        static let creditHistoryKey = "com.supertuber.creditHistory"
    }
    
    // MARK: - Configuration Properties
    public var totalMonthlyCredits: Int
    
    // MARK: - Public Methods
    public var consumeCredits: (Int) -> Bool
    public var getRemainingCredits: () -> Int
    public var getTotalCredits: () -> Int
    public var getNextRenewalDate: () -> Date
    public var getDaysUntilRenewal: () -> Int
    public var resetCredits: () -> Void
    public var checkAndRenewCreditsIfNeeded: () -> Bool
    public var getCreditHistory: () -> [CreditHistoryItem]
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

// MARK: - Live Implementation
extension CreditClient {
    public static func live(
        userDefaults: UserDefaults = .standard,
        totalMonthlyCredits: Int = 100,
        resetState: Bool = false
    ) -> Self {
        // Reset state if requested
        if resetState {
            userDefaults.removeObject(forKey: Constants.totalCreditsKey)
            userDefaults.removeObject(forKey: Constants.consumedCreditsKey)
            userDefaults.removeObject(forKey: Constants.nextRenewalDateKey)
            userDefaults.removeObject(forKey: Constants.creditHistoryKey)
        }
        
        // Initialize total credits if not set
        if userDefaults.object(forKey: Constants.totalCreditsKey) == nil {
            userDefaults.set(totalMonthlyCredits, forKey: Constants.totalCreditsKey)
        }
        
        // Initialize consumed credits if not set
        if userDefaults.object(forKey: Constants.consumedCreditsKey) == nil {
            userDefaults.set(0, forKey: Constants.consumedCreditsKey)
        }
        
        // Initialize next renewal date if not set
        if userDefaults.object(forKey: Constants.nextRenewalDateKey) == nil {
            // Set next renewal date to first day of next month
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month], from: Date())
            components.month = (components.month ?? 1) + 1
            components.day = 1
            components.hour = 0
            components.minute = 0
            components.second = 0
            
            if let nextRenewalDate = calendar.date(from: components) {
                userDefaults.set(nextRenewalDate, forKey: Constants.nextRenewalDateKey)
            }
        }
        
        // Initialize credit history if not set
        if userDefaults.object(forKey: Constants.creditHistoryKey) == nil {
            let emptyHistory: [CreditHistoryItem] = []
            if let encoded = try? JSONEncoder().encode(emptyHistory) {
                userDefaults.set(encoded, forKey: Constants.creditHistoryKey)
            }
        }
        
        return Self(
            totalMonthlyCredits: totalMonthlyCredits,
            
            consumeCredits: { amount in
                // First check if renewal is needed
                let renewalOccurred = checkAndRenewCreditsIfNeeded(userDefaults: userDefaults)
                
                let consumedCredits = userDefaults.integer(forKey: Constants.consumedCreditsKey)
                let totalCredits = userDefaults.integer(forKey: Constants.totalCreditsKey)
                
                // Check if enough credits are available
                if consumedCredits + amount <= totalCredits {
                    userDefaults.set(consumedCredits + amount, forKey: Constants.consumedCreditsKey)
                    
                    // Add to history
                    if let historyData = userDefaults.data(forKey: Constants.creditHistoryKey),
                       var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                        let newItem = CreditHistoryItem(amount: amount, description: "Credit consumed")
                        history.append(newItem)
                        // Keep only last 50 items
                        if history.count > 50 {
                            history = Array(history.suffix(50))
                        }
                        if let encoded = try? JSONEncoder().encode(history) {
                            userDefaults.set(encoded, forKey: Constants.creditHistoryKey)
                        }
                    }
                    
                    return true
                }
                return false
            },
            
            getRemainingCredits: {
                // Check if renewal is needed
                let renewalOccurred = checkAndRenewCreditsIfNeeded(userDefaults: userDefaults)
                
                let consumedCredits = userDefaults.integer(forKey: Constants.consumedCreditsKey)
                let totalCredits = userDefaults.integer(forKey: Constants.totalCreditsKey)
                return totalCredits - consumedCredits
            },
            
            getTotalCredits: {
                return userDefaults.integer(forKey: Constants.totalCreditsKey)
            },
            
            getNextRenewalDate: {
                if let nextRenewalDate = userDefaults.object(forKey: Constants.nextRenewalDateKey) as? Date {
                    return nextRenewalDate
                }
                
                // If not set, calculate and set it
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month], from: Date())
                components.month = (components.month ?? 1) + 1
                components.day = 1
                components.hour = 0
                components.minute = 0
                components.second = 0
                
                let nextRenewalDate = calendar.date(from: components) ?? Date()
                userDefaults.set(nextRenewalDate, forKey: Constants.nextRenewalDateKey)
                return nextRenewalDate
            },
            
            getDaysUntilRenewal: {
                if let nextRenewalDate = userDefaults.object(forKey: Constants.nextRenewalDateKey) as? Date {
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.day], from: Date(), to: nextRenewalDate)
                    return max(0, components.day ?? 0)
                }
                return 0
            },
            
            resetCredits: {
                let totalCredits = userDefaults.integer(forKey: Constants.totalCreditsKey)
                userDefaults.set(0, forKey: Constants.consumedCreditsKey)
                
//                // Calculate next renewal date
//                let calendar = Calendar.current
//                if let currentRenewalDate = userDefaults.object(forKey: Constants.nextRenewalDateKey) as? Date {
//                    var components = DateComponents()
//                    components.month = 1
//                    if let nextRenewalDate = calendar.date(byAdding: components, to: currentRenewalDate) {
//                        userDefaults.set(nextRenewalDate, forKey: Constants.nextRenewalDateKey)
//                    }
//                }
                
//                // Add to history
//                if let historyData = userDefaults.data(forKey: Constants.creditHistoryKey),
//                   var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
//                    let newItem = CreditHistoryItem(amount: totalCredits, description: "Credits renewed")
//                    history.append(newItem)
//                    if let encoded = try? JSONEncoder().encode(history) {
//                        userDefaults.set(encoded, forKey: Constants.creditHistoryKey)
//                    }
//                }
            },
            
            checkAndRenewCreditsIfNeeded: {
                if let nextRenewalDate = userDefaults.object(forKey: Constants.nextRenewalDateKey) as? Date {
                    if Date() >= nextRenewalDate {
                        // Reset consumed credits
                        userDefaults.set(0, forKey: Constants.consumedCreditsKey)
                        
                        // Calculate next renewal date
                        let calendar = Calendar.current
                        var components = DateComponents()
                        components.month = 1
                        if let newRenewalDate = calendar.date(byAdding: components, to: nextRenewalDate) {
                            userDefaults.set(newRenewalDate, forKey: Constants.nextRenewalDateKey)
                        }
                        
                        // Add to history
                        if let historyData = userDefaults.data(forKey: Constants.creditHistoryKey),
                           var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                            let totalCredits = userDefaults.integer(forKey: Constants.totalCreditsKey)
                            let newItem = CreditHistoryItem(amount: totalCredits, description: "Credits renewed")
                            history.append(newItem)
                            if let encoded = try? JSONEncoder().encode(history) {
                                userDefaults.set(encoded, forKey: Constants.creditHistoryKey)
                            }
                        }
                        
                        return true
                    }
                }
                return false
            },
            
            getCreditHistory: {
                if let historyData = userDefaults.data(forKey: Constants.creditHistoryKey),
                   let history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                    return history
                }
                return []
            }
        )
    }
    
    // Helper function for checking renewal
    private static func checkAndRenewCreditsIfNeeded(userDefaults: UserDefaults) -> Bool {
        if let nextRenewalDate = userDefaults.object(forKey: Constants.nextRenewalDateKey) as? Date {
            if Date() >= nextRenewalDate {
                // Reset consumed credits
                userDefaults.set(0, forKey: Constants.consumedCreditsKey)
                
                // Calculate next renewal date
                let calendar = Calendar.current
                var components = DateComponents()
                components.month = 1
                if let newRenewalDate = calendar.date(byAdding: components, to: nextRenewalDate) {
                    userDefaults.set(newRenewalDate, forKey: Constants.nextRenewalDateKey)
                }
                
                // Add to history
                if let historyData = userDefaults.data(forKey: Constants.creditHistoryKey),
                   var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                    let totalCredits = userDefaults.integer(forKey: Constants.totalCreditsKey)
                    let newItem = CreditHistoryItem(amount: totalCredits, description: "Credits renewed")
                    history.append(newItem)
                    if let encoded = try? JSONEncoder().encode(history) {
                        userDefaults.set(encoded, forKey: Constants.creditHistoryKey)
                    }
                }
                
                return true
            }
        }
        return false
    }
    
    // Mock implementation for testing
    public static func mock() -> Self {
        Self(
            totalMonthlyCredits: 100,
            consumeCredits: { _ in true },
            getRemainingCredits: { 50 },
            getTotalCredits: { 100 },
            getNextRenewalDate: { Date().addingTimeInterval(86400 * 15) }, // 15 days from now
            getDaysUntilRenewal: { 15 },
            resetCredits: {},
            checkAndRenewCreditsIfNeeded: { false },
            getCreditHistory: { [] }
        )
    }
}

// MARK: - Factory Methods
extension CreditClient {
    public static func live(totalMonthlyCredits: Int = 100, resetState: Bool = false) -> CreditClient {
        return CreditClient.live(userDefaults: .standard, totalMonthlyCredits: totalMonthlyCredits, resetState: resetState)
    }
}
