//
//  SingleFeatureSubscribeView.swift
//  SwiftMarketingKit
//
//  Created by Cascade AI on 05/05/2025.
//

import SwiftUI
import StoreKit
import RevenueCat
import RevenueCatUI
import Foundation
import Combine

/// A focused subscribe view that showcases a single feature prominently
public struct SingleFeatureSubscribeView: View {
    @ObservedObject var viewModel: SubscribeViewModel
    @Environment(\.dismiss) var dismiss
    
    // Feature details
    private var featureIcon: String
    private var featureTitle: String
    private var featureDescription: String
    
    public init(featureIcon: String, featureTitle: String, featureDescription: String) {
        viewModel = SubscribeViewModel()
        
        self.featureIcon = featureIcon
        self.featureTitle = featureTitle
        self.featureDescription = featureDescription
        
        viewModel.onDismiss = { @MainActor [self] in dismiss() }
    }
    
    /// Initialize with a SubscribeFeature object
    public init(feature: SubscribeFeature) {
        viewModel = SubscribeViewModel()
        
        self.featureIcon = feature.icon
        self.featureTitle = feature.title
        self.featureDescription = feature.description
        
        viewModel.onDismiss = { @MainActor [self] in dismiss() }
        
        
    }
    
    // Helper method for purchasing current plan
    private func purchaseCurrentPlan() async {
        if let selectedPackage = viewModel.selectedPackage {
            await viewModel.purchaseSubscription(selectedPackage.storeProduct.productIdentifier)
        }
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        // Icon (optional)
                        
//                        Spacer()
                        // Feature title in big bold font
                        VStack(spacing: 15) {
                            Text(featureTitle)
                                .font(.system(size: 28, weight: .bold))
                                .multilineTextAlignment(.center)
//                                .lineLimit(2)
    //                                .padding(.horizontal)
                            
    //                            // Feature description
                                Text(featureDescription)
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                        }
//                        .frame(minHeight: 170)
                        
                        
                        Image("unlimited_chats")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 320)
//                            .background(Color.red)
//                            Image(systemName: featureIcon)
//                                .font(.system(size: 48))
//                                .foregroundColor(SubscribeManagerConfig.getTintColor())
//                                .padding(.bottom, 8)
                        
//                        Spacer()
                        
                        
                    }
                    .padding()
                
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            // Subscription options at the bottom
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    // Free trial toggle
                    HStack {
                        Text("Enable Free Trial")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { viewModel.freeTrialEnabled },
                            set: { viewModel.toggleFreeTrial($0) }
                        ))
                            .labelsHidden()
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(24)
                    
                    if viewModel.availablePackages.isEmpty {
                        // Show loading or error state when no packages are available
                        Text("Loading subscription options...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                    } else {
                        // Dynamic subscription plans from RevenueCat
                        ForEach(viewModel.getSubscriptionPlanModels(), id: \.package.identifier) { planModel in
                            SubscriptionPlanCard(
                                title: planModel.title,
                                subtitle: planModel.subtitle,
                                price: planModel.price,
                                period: planModel.period,
                                perWeekPrice: planModel.perWeekPrice,
                                isSelected: planModel.isSelected,
                                hasTrial: planModel.hasTrial,
                                showPricePerPeriod: planModel.showPricePerPeriod,
                                trialDays: 7, // Default trial days
                                isBestValue: planModel.isBestValue,
                                savingsText: planModel.savingsText,
                                lifetimeOfferViewModel: planModel.isLifetime ? viewModel.lifetimeOfferViewModel : nil,
                                action: {
                                    viewModel.selectPlan(planModel.package.identifier)
                                }
                            )
                        }
                    }
                    
                    // Subscribe button with gradient
                    Button {
                        Task {
                            await purchaseCurrentPlan()
                        }
                    } label: {
                        HStack {
                            Text("Subscribe Now")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [SubscribeManagerConfig.getTintColor(), SubscribeManagerConfig.getTintColor().opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .foregroundColor(.white)
                    }
                    .disabled(viewModel.selectedPackage == nil || viewModel.isPremium || viewModel.isLoading)
                    
                    // Restore purchases button
                    Button {
                        Task {
                            await viewModel.restorePurchases()
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .onAppear {
                Task {
                    await viewModel.onAppear()
                }
            }
        }
    }
}
