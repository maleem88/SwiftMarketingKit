//
//  CreditDemoViewModel.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 15/04/2025.
//

import Foundation
import SwiftUI
import Combine

public class CreditDemoViewModel: ObservableObject {
    // MARK: - Properties
    @Published public var creditViewModel: CreditViewModel
    @Published public var isAuthenticated: Bool = false
    
    // MARK: - Initialization
    public init(creditViewModel: CreditViewModel = CreditViewModel()) {
        self.creditViewModel = creditViewModel
    }
    
    // MARK: - Actions
    public func summarizeVideo() {
        creditViewModel.consumeCredits(20, description: "video_summary")
    }
    
    public func generateTranscript() {
        creditViewModel.consumeCredits(10, description: "subscription")
    }
}
