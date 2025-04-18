//
//  CreditView.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 07/04/2025.
//

import SwiftUI

public struct CreditView: View {
    @ObservedObject var viewModel: CreditViewModel
    
    public init(viewModel: CreditViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Credit Status Card
            VStack(spacing: 16) {
                HStack {
                    Text(viewModel.creditsTitleText)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                // Credit Counter
                HStack(alignment: .firstTextBaseline) {
                    Text("\(viewModel.remainingCredits)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(viewModel.creditColor)
                    Text("/ \(viewModel.totalCredits)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Spacer()
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
                    .frame(height: 12)
                }
                .frame(height: 12)
                
                // Renewal Info
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.secondary)
                    Text("Days until renewal: \(viewModel.daysUntilRenewal)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    Text(viewModel.nextRenewalDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Credit History Section
            if viewModel.shouldShowHistorySection {
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.historyTitleText)
                        .font(.headline)
                    
                    Divider()
                    
                    ForEach(Array(viewModel.creditHistory.prefix(viewModel.maxHistoryItems).enumerated()), id: \.element.id) { index, item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.description)
                                    .font(.subheadline)
                                Text(item.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(item.description.contains("renewed") ? "+\(item.amount)" : "-\(item.amount)")
                                .font(.subheadline)
                                .foregroundColor(item.description.contains("renewed") ? .green : .red)
                        }
                        .padding(.vertical, 4)
                        
                        if index < min(viewModel.maxHistoryItems - 1, viewModel.creditHistory.count - 1) {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            // Test Buttons (for demonstration)
            #if DEBUG
            Spacer()
            
            VStack(spacing: 12) {
                Button("Consume 10 Credits") {
                    viewModel.consumeCredits(10, description: "Test Consumption")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Consume 50 Credits") {
                    viewModel.consumeCredits(50, description: "Large Test Consumption")
                }
                .buttonStyle(.bordered)
                
                Button("Refresh Status") {
                    viewModel.refreshCreditStatus()
                }
                .font(.caption)
                
                Button("Reset Credits") {
                    viewModel.resetCredits()
                }
                .foregroundColor(.red)
                .font(.caption)
            }
            .padding()
            #endif
        }
        .padding()
        .navigationTitle("Credits")
        .onAppear {
            viewModel.onAppear()
        }
        .alert(CreditsManagerConfig.shared.getInsufficientCreditsAlertTitle(), isPresented: $viewModel.showInsufficientCreditsAlert) {
            Button("OK", role: .cancel) {
                viewModel.dismissInsufficientCreditsAlert()
            }
        } message: {
            Text(viewModel.getInsufficientCreditsAlertMessage())
        }
    }
    

}

#Preview {
    NavigationStack {
        CreditView(viewModel: CreditViewModel())
    }
}
