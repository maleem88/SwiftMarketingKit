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
    
    // MARK: - Published State
    @Published public var remainingCredits: Int = 0
    @Published public var totalCredits: Int = 0
    @Published public var nextRenewalDate: Date = Date()
    @Published public var daysUntilRenewal: Int = 0
    @Published public var creditHistory: [CreditHistoryItem] = []
    @Published public var showInsufficientCreditsAlert: Bool = false
    @Published public var lastConsumeAttempt: Int = 0
    
    // MARK: - Initialization
    public init(creditClient: CreditClient = .live()) {
        self.creditClient = creditClient
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
        if percentage > 0.6 {
            return .green
        } else if percentage > 0.3 {
            return .orange
        } else {
            return .red
        }
    }
}
