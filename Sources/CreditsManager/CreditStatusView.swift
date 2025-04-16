//
//  CreditStatusView.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 15/04/2025.
//

import SwiftUI

public struct CreditStatusView: View {
    @ObservedObject var viewModel: CreditViewModel
    
    public init(viewModel: CreditViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("monthly_credits")
                    .font(.headline)
                Spacer()
                Text("remaining_credits \(viewModel.remainingCredits) / \(viewModel.totalCredits)")
                    .font(.headline)
                    .foregroundColor(viewModel.creditColor)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .cornerRadius(10)
                    
                    // Foreground
                    Rectangle()
                        .foregroundColor(viewModel.creditColor)
                        .frame(width: max(0, min(CGFloat(viewModel.remainingCredits) / CGFloat(max(1, viewModel.totalCredits)) * geometry.size.width, geometry.size.width)))
                        .cornerRadius(10)
                }
                .frame(height: 10)
            }
            .frame(height: 10)
            
            // Renewal Info
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text("days_until_renewal \(viewModel.daysUntilRenewal)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .alert("insufficient_credits", isPresented: $viewModel.showInsufficientCreditsAlert) {
            Button("ok", role: .cancel) {
                viewModel.dismissInsufficientCreditsAlert()
            }
        } message: {
            Text("insufficient_credits_message \(viewModel.lastConsumeAttempt), \(viewModel.remainingCredits), \(viewModel.daysUntilRenewal)")
        }
    }
}

#Preview {
    CreditStatusView(viewModel: CreditViewModel())
}
