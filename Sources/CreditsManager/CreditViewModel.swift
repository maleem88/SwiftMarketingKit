//
//  CreditViewModel.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 15/04/2025.
//

import Foundation
import SwiftUI
import Combine

public class CreditViewModel: ObservableObject {
    // MARK: - Properties
    private let creditClient: CreditClient
    private let config: CreditsManagerConfig
    
    // MARK: - Published State
    @Published public var remainingCredits: Int = 0
    @Published public var totalCredits: Int = 0
    @Published public var nextRenewalDate: Date = Date()
    @Published public var daysUntilRenewal: Int = 0
    @Published public var creditHistory: [CreditHistoryItem] = []
    @Published public var showInsufficientCreditsAlert: Bool = false
    @Published public var lastConsumeAttempt: Int = 0
    
    // MARK: - Initialization
    public init(creditClient: CreditClient = .live(), config: CreditsManagerConfig = CreditsManagerConfig.shared) {
        self.creditClient = creditClient
        self.config = config
        refreshCreditStatus()
    }
    
    // MARK: - Actions
    public func onAppear() {
        refreshCreditStatus()
    }
    
    public func refreshCreditStatus() {
        // Check if credits need renewal
        let _ = creditClient.checkAndRenewCreditsIfNeeded()
        
        // Get updated credit info
        remainingCredits = creditClient.getRemainingCredits()
        totalCredits = creditClient.getTotalCredits()
        nextRenewalDate = creditClient.getNextRenewalDate()
        daysUntilRenewal = creditClient.getDaysUntilRenewal()
        creditHistory = creditClient.getCreditHistory()
    }
    
    public func consumeCredits(_ amount: Int, description: String) {
        lastConsumeAttempt = amount
        
        let success = creditClient.consumeCredits(amount)
        showInsufficientCreditsAlert = !success
        
        if success {
            refreshCreditStatus()
        }
    }
    
    public func dismissInsufficientCreditsAlert() {
        showInsufficientCreditsAlert = false
    }
    
    public func resetCredits() {
        creditClient.resetCredits()
        refreshCreditStatus()
    }
    
    // MARK: - Helper Methods
    public var creditColor: Color {
        let percentage = Double(remainingCredits) / Double(max(1, totalCredits))
        return config.getCreditColor(for: percentage)
    }
    
    // Get the title for the credits display
    public var creditsTitleText: String {
        return config.getCreditsTitleText()
    }
    
    // Get the days until renew for the credits display
    public var daysUntilRenew: String {
        return config.getDaysUntilRenew()
    }
    
    // Get the title for the history section
    public var historyTitleText: String {
        return config.getHistoryTitleText()
    }
    
    // Check if history section should be shown
    public var shouldShowHistorySection: Bool {
        return config.shouldShowHistorySection() && !creditHistory.isEmpty
    }
    
    // Get max number of history items to display
    public var maxHistoryItems: Int {
        return config.getMaxHistoryItems()
    }
    
    // Get the formatted insufficient credits alert message
    public func getInsufficientCreditsAlertMessage() -> String {
        let message = config.getInsufficientCreditsAlertMessage()
        return message
            .replacingOccurrences(of: "%@", with: "\(lastConsumeAttempt)", options: [], range: message.range(of: "%@"))
            .replacingOccurrences(of: "%@", with: "\(remainingCredits)", options: [], range: message.range(of: "%@"))
            .replacingOccurrences(of: "%@", with: "\(daysUntilRenewal)", options: [], range: message.range(of: "%@"))
    }
}
