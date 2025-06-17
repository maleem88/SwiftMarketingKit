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
    private let creditClient = CreditClient.shared
    
    // MARK: - Published State
    @Published public var remainingCredits: Int = 0
    @Published public var totalCredits: Int = 0
    @Published public var nextRenewalDate: Date = Date()
    @Published public var daysUntilRenewal: Int = 0
    @Published public var creditHistory: [CreditHistoryItem] = []
    @Published public var showInsufficientCreditsAlert: Bool = false
    @Published public var lastConsumeAttempt: Int = 0
    @Published public var creditMode: CreditMode = .renewal
    
    // MARK: - Initialization
    public init() {
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
        creditMode = creditClient.creditMode
    }
    
    public func consumeCredits(_ amount: Int, description: String) {
        lastConsumeAttempt = amount
        
        let success = creditClient.consumeCredits(amount: amount)
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
        if percentage > creditClient.highCreditThreshold {
            return creditClient.highCreditColor
        } else if percentage > creditClient.mediumCreditThreshold {
            return creditClient.mediumCreditColor
        } else {
            return creditClient.lowCreditColor
        }
    }
    
    // Get the title for the credits display
    public var creditsTitleText: String {
        return creditClient.creditsTitleText
    }
    
    // Check if we're in renewal mode
    public var isRenewalMode: Bool {
        return creditClient.creditMode == .renewal
    }
    
    // Set the credit mode
    public func setCreditMode(_ mode: CreditMode) {
        creditClient.setCreditMode(mode)
        refreshCreditStatus()
    }
    
    // Get the days until renew for the credits display
    public var daysUntilRenewText: String {
        creditClient.daysUntilRenewText
    }
    
    // Get the title for the history section
    public var historyTitleText: String {
        return creditClient.historyTitleText
    }
    
    // Check if history section should be shown
    public var shouldShowHistorySection: Bool {
        return creditClient.showHistorySection && !creditHistory.isEmpty
    }
    
    // Get max number of history items to display
    public var maxHistoryItems: Int {
        return creditClient.maxHistoryItems
    }
    
    // Get the formatted insufficient credits alert message
    public func getInsufficientCreditsAlertMessage() -> String {
        if creditClient.creditMode == .oneTime {
            // For one-time credits, use the simpler message without renewal info
            let message = creditClient.oneTimeInsufficientCreditsAlertMessage
            return message
                .replacingOccurrences(of: "%@", with: "\(lastConsumeAttempt)", options: [], range: message.range(of: "%@"))
                .replacingOccurrences(of: "%@", with: "\(remainingCredits)", options: [], range: message.range(of: "%@"))
        } else {
            // For renewal credits, include the renewal info
            let message = creditClient.insufficientCreditsAlertMessage
            return message
                .replacingOccurrences(of: "%@", with: "\(lastConsumeAttempt)", options: [], range: message.range(of: "%@"))
                .replacingOccurrences(of: "%@", with: "\(remainingCredits)", options: [], range: message.range(of: "%@"))
                .replacingOccurrences(of: "%@", with: "\(daysUntilRenewal)", options: [], range: message.range(of: "%@"))
        }
    }
}
