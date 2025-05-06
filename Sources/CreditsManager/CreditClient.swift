//
//  CreditClient.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 07/04/2025.
//

import Foundation
import SwiftUI

// MARK: - Credit Client

/// A service that manages the credit system with configurable renewal periods
public struct CreditClient {
    // MARK: - Properties
    private let config: CreditsManagerConfig
    
    // Convenience accessors for UserDefaults keys
    private var totalCreditsKey: String { config.getTotalCreditsKey() }
    private var consumedCreditsKey: String { config.getConsumedCreditsKey() }
    private var nextRenewalDateKey: String { config.getNextRenewalDateKey() }
    private var creditHistoryKey: String { config.getCreditHistoryKey() }
    
    // MARK: - Configuration Properties
    private var creditAmount: Int
    
    // MARK: - Initialization
    public init(
        creditAmount: Int,
        config: CreditsManagerConfig,
        consumeCredits: @escaping (Int) -> Bool,
        getRemainingCredits: @escaping () -> Int,
        getTotalCredits: @escaping () -> Int,
        getNextRenewalDate: @escaping () -> Date,
        getDaysUntilRenewal: @escaping () -> Int,
        resetCredits: @escaping () -> Void,
        checkAndRenewCreditsIfNeeded: @escaping () -> Bool,
        getCreditHistory: @escaping () -> [CreditHistoryItem]
    ) {
        self.creditAmount = creditAmount
        self.config = config
        self.consumeCredits = consumeCredits
        self.getRemainingCredits = getRemainingCredits
        self.getTotalCredits = getTotalCredits
        self.getNextRenewalDate = getNextRenewalDate
        self.getDaysUntilRenewal = getDaysUntilRenewal
        self.resetCredits = resetCredits
        self.checkAndRenewCreditsIfNeeded = checkAndRenewCreditsIfNeeded
        self.getCreditHistory = getCreditHistory
    }
    
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
        config: CreditsManagerConfig = CreditsManagerConfig.shared,
        resetState: Bool = false
    ) -> Self {
        let totalCreditsKey = config.getTotalCreditsKey()
        let consumedCreditsKey = config.getConsumedCreditsKey()
        let nextRenewalDateKey = config.getNextRenewalDateKey()
        let creditHistoryKey = config.getCreditHistoryKey()
        
        // Reset state if requested
        if resetState {
            userDefaults.removeObject(forKey: totalCreditsKey)
            userDefaults.removeObject(forKey: consumedCreditsKey)
            userDefaults.removeObject(forKey: nextRenewalDateKey)
            userDefaults.removeObject(forKey: creditHistoryKey)
        }
        
        // Always update total credits with the current config value
        // This ensures that changes to the credit amount via setCreditAmount are reflected
        userDefaults.set(config.getCreditAmount(), forKey: totalCreditsKey)
        
        // Initialize consumed credits if not set
        if userDefaults.object(forKey: consumedCreditsKey) == nil {
            userDefaults.set(0, forKey: consumedCreditsKey)
        }
        
        // Initialize next renewal date if not set
        if userDefaults.object(forKey: nextRenewalDateKey) == nil {
            // Calculate next renewal date based on configured period
            let nextRenewalDate = config.calculateNextRenewalDate()
            userDefaults.set(nextRenewalDate, forKey: nextRenewalDateKey)
        }
        
        // Initialize credit history if not set
        if userDefaults.object(forKey: creditHistoryKey) == nil {
            let emptyHistory: [CreditHistoryItem] = []
            if let encoded = try? JSONEncoder().encode(emptyHistory) {
                userDefaults.set(encoded, forKey: creditHistoryKey)
            }
        }
        
        return Self(
            creditAmount: config.getCreditAmount(),
            config: config,
            
            consumeCredits: { amount in
                // First check if renewal is needed
                let renewalOccurred = checkAndRenewCreditsIfNeeded(userDefaults: userDefaults, config: config)
                
                let consumedCredits = userDefaults.integer(forKey: config.getConsumedCreditsKey())
                let totalCredits = userDefaults.integer(forKey: config.getTotalCreditsKey())
                
                // Check if enough credits are available
                if consumedCredits + amount <= totalCredits {
                    userDefaults.set(consumedCredits + amount, forKey: config.getConsumedCreditsKey())
                    
                    // Add to history
                    if let historyData = userDefaults.data(forKey: config.getCreditHistoryKey()),
                       var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                        let newItem = CreditHistoryItem(amount: amount, description: "Credit consumed")
                        history.append(newItem)
                        // Keep only last 50 items
                        if history.count > 50 {
                            history = Array(history.suffix(50))
                        }
                        if let encoded = try? JSONEncoder().encode(history) {
                            userDefaults.set(encoded, forKey: config.getCreditHistoryKey())
                        }
                    }
                    
                    return true
                }
                return false
            },
            
            getRemainingCredits: {
                // Check if renewal is needed
                let renewalOccurred = checkAndRenewCreditsIfNeeded(userDefaults: userDefaults, config: config)
                
                let consumedCredits = userDefaults.integer(forKey: config.getConsumedCreditsKey())
                let totalCredits = userDefaults.integer(forKey: config.getTotalCreditsKey())
                return totalCredits - consumedCredits
            },
            
            getTotalCredits: {
                return userDefaults.integer(forKey: config.getTotalCreditsKey())
            },
            
            getNextRenewalDate: {
                if let nextRenewalDate = userDefaults.object(forKey: config.getNextRenewalDateKey()) as? Date {
                    return nextRenewalDate
                }
                
                // If not set, calculate and set it
                let nextRenewalDate = config.calculateNextRenewalDate()
                userDefaults.set(nextRenewalDate, forKey: config.getNextRenewalDateKey())
                return nextRenewalDate
            },
            
            getDaysUntilRenewal: {
                if let nextRenewalDate = userDefaults.object(forKey: config.getNextRenewalDateKey()) as? Date {
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.day], from: Date(), to: nextRenewalDate)
                    return max(0, components.day ?? 0)
                }
                return 0
            },
            
            resetCredits: {
                let totalCredits = userDefaults.integer(forKey: config.getTotalCreditsKey())
                userDefaults.set(0, forKey: config.getConsumedCreditsKey())
                
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
                if let nextRenewalDate = userDefaults.object(forKey: config.getNextRenewalDateKey()) as? Date {
                    if Date() >= nextRenewalDate {
                        // Reset consumed credits
                        userDefaults.set(0, forKey: config.getConsumedCreditsKey())
                        
                        // Calculate next renewal date based on configured period
                        let newRenewalDate = config.calculateNextRenewalDate(from: nextRenewalDate)
                        userDefaults.set(newRenewalDate, forKey: config.getNextRenewalDateKey())
                        
                        // Add to history
                        if let historyData = userDefaults.data(forKey: config.getCreditHistoryKey()),
                           var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                            let totalCredits = userDefaults.integer(forKey: config.getTotalCreditsKey())
                            let renewalDescription = "\(config.getRenewalPeriodDescription()) credits renewed"
                            let newItem = CreditHistoryItem(amount: totalCredits, description: renewalDescription)
                            history.append(newItem)
                            if let encoded = try? JSONEncoder().encode(history) {
                                userDefaults.set(encoded, forKey: config.getCreditHistoryKey())
                            }
                        }
                        
                        return true
                    }
                }
                return false
            },
            
            getCreditHistory: {
                if let historyData = userDefaults.data(forKey: config.getCreditHistoryKey()),
                   let history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                    return history
                }
                return []
            }
        )
    }
    
    // Helper function for checking renewal
    private static func checkAndRenewCreditsIfNeeded(userDefaults: UserDefaults, config: CreditsManagerConfig) -> Bool {
        if let nextRenewalDate = userDefaults.object(forKey: config.getNextRenewalDateKey()) as? Date {
            if Date() >= nextRenewalDate {
                // Reset consumed credits
                userDefaults.set(0, forKey: config.getConsumedCreditsKey())
                
                // Calculate next renewal date based on configured period
                let newRenewalDate = config.calculateNextRenewalDate(from: nextRenewalDate)
                userDefaults.set(newRenewalDate, forKey: config.getNextRenewalDateKey())
                
                // Add to history
                if let historyData = userDefaults.data(forKey: config.getCreditHistoryKey()),
                   var history = try? JSONDecoder().decode([CreditHistoryItem].self, from: historyData) {
                    let totalCredits = userDefaults.integer(forKey: config.getTotalCreditsKey())
                    let renewalDescription = "\(config.getRenewalPeriodDescription()) credits renewed"
                    let newItem = CreditHistoryItem(amount: totalCredits, description: renewalDescription)
                    history.append(newItem)
                    if let encoded = try? JSONEncoder().encode(history) {
                        userDefaults.set(encoded, forKey: config.getCreditHistoryKey())
                    }
                }
                
                return true
            }
        }
        return false
    }
    
    // Mock implementation for testing
    public static func mock(config: CreditsManagerConfig = CreditsManagerConfig.shared) -> Self {
        Self(
            creditAmount: config.getCreditAmount(),
            config: config,
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
    public static func live(config: CreditsManagerConfig = CreditsManagerConfig.shared, resetState: Bool = false) -> CreditClient {
        return CreditClient.live(userDefaults: .standard, config: config, resetState: resetState)
    }
}
