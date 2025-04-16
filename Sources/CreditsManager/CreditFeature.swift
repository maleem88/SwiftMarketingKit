////
////  CreditFeature.swift
////  YoutubeSummarizer
////
////  Created by mohamed abd elaleem on 07/04/2025.
////
//
//import Foundation
//import SwiftUI
//import ComposableArchitecture
//
//// MARK: - Credit Feature
//
//@Reducer
//public struct CreditFeature {
//    // MARK: - State
//    @ObservableState
//    public struct State: Equatable {
//        public var remainingCredits: Int = 0
//        public var totalCredits: Int = 0
//        public var nextRenewalDate: Date = Date()
//        public var daysUntilRenewal: Int = 0
//        public var creditHistory: [CreditHistoryItem] = []
//        public var showInsufficientCreditsAlert: Bool = false
//        public var lastConsumeAttempt: Int = 0
//        
//        public init() {}
//    }
//    
//    // MARK: - Actions
//    @CasePathable
//    public enum Action: BindableAction, Equatable {
//        case onAppear
//        case refreshCreditStatus
//        case consumeCredits(Int, description: String)
//        case consumeCreditsResult(Bool)
//        case creditStatusRefreshed(remaining: Int, total: Int, daysUntil: Int, nextDate: Date)
//        case creditHistoryLoaded([CreditHistoryItem])
//        case dismissInsufficientCreditsAlert
//        case resetCredits
//        case binding(BindingAction<State>)
//    }
//    
//    // MARK: - Dependencies
//    @Dependency(\.creditClient) private var creditClient
//    
//    public init() {}
//    
//    // MARK: - Reducer
//    public var body: some ReducerOf<Self> {
//        BindingReducer()
//        
//        Reduce { state, action in
//            switch action {
//            case .onAppear:
//                return .run { send in
//                    await send(.refreshCreditStatus)
//                }
//                
//            case .refreshCreditStatus:
//                // Check if credits need renewal
//                let _ = creditClient.checkAndRenewCreditsIfNeeded()
//                
//                // Get updated credit info
//                let remaining = creditClient.getRemainingCredits()
//                let total = creditClient.getTotalCredits()
//                let nextDate = creditClient.getNextRenewalDate()
//                let daysUntil = creditClient.getDaysUntilRenewal()
//                let history = creditClient.getCreditHistory()
//                
//                return .merge(
//                    .send(.creditStatusRefreshed(
//                        remaining: remaining,
//                        total: total,
//                        daysUntil: daysUntil,
//                        nextDate: nextDate
//                    )),
//                    .send(.creditHistoryLoaded(history))
//                )
//                
//            case let .consumeCredits(amount, description):
//                state.lastConsumeAttempt = amount
//                
//                return .run { send in
//                    let success = creditClient.consumeCredits(amount)
//                    await send(.consumeCreditsResult(success))
//                    if success {
//                        await send(.refreshCreditStatus)
//                    }
//                }.animation(.default)
//                
//            case let .consumeCreditsResult(success):
//                state.showInsufficientCreditsAlert = !success
//                return .none
//                
//            case let .creditStatusRefreshed(remaining, total, daysUntil, nextDate):
//                state.remainingCredits = remaining
//                state.totalCredits = total
//                state.daysUntilRenewal = daysUntil
//                state.nextRenewalDate = nextDate
//                return .none
//                
//            case let .creditHistoryLoaded(history):
//                state.creditHistory = history
//                return .none
//                
//            case .dismissInsufficientCreditsAlert:
//                state.showInsufficientCreditsAlert = false
//                return .none
//                
//            case .resetCredits:
//                creditClient.resetCredits()
//                return .send(.refreshCreditStatus)
//                
//            case .binding:
//                return .none
//            }
//        }
//    }
//}
//
//// MARK: - SwiftUI View
//
//public struct CreditStatusView: View {
//    @Bindable var store: StoreOf<CreditFeature>
//    
//    public init(store: StoreOf<CreditFeature>) {
//        self.store = store
//    }
//    
//    public var body: some View {
//        VStack(spacing: 16) {
//            // Credit Status Card
////            VStack(spacing: 12) {
//                HStack {
//                    Text("monthly_credits".localized)
//                        .font(.headline)
//                    Spacer()
//                    Text("remaining_credits".localized(with: store.remainingCredits, store.totalCredits))
//                        .font(.headline)
//                        .foregroundColor(creditColor)
//                }
//                
//                // Progress Bar
//                GeometryReader { geometry in
//                    ZStack(alignment: .leading) {
//                        // Background
//                        Rectangle()
//                            .foregroundColor(Color(.systemGray5))
//                            .cornerRadius(10)
//                        
//                        // Foreground
//                        Rectangle()
//                            .foregroundColor(creditColor)
//                            .frame(width: max(0, min(CGFloat(store.remainingCredits) / CGFloat(max(1, store.totalCredits)) * geometry.size.width, geometry.size.width)))
//                            .cornerRadius(10)
//                    }
//                    .frame(height: 10)
//                }
//                .frame(height: 10)
//                
//                // Renewal Info
//                HStack {
//                    Image(systemName: "calendar")
//                        .foregroundColor(.secondary)
//                    Text("days_until_renewal".localized(with: store.daysUntilRenewal))
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Spacer()
//                }
////            }
////            .padding()
////            .background(Color(.secondarySystemBackground))
////            .cornerRadius(12)
////            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//        }
////        .padding(.horizontal)
//        .onAppear {
//            store.send(.onAppear)
//        }
//        .alert("insufficient_credits".localized, isPresented: $store.showInsufficientCreditsAlert) {
//            Button("ok".localized, role: .cancel) {
//                store.send(.dismissInsufficientCreditsAlert)
//            }
//        } message: {
//            Text("insufficient_credits_message".localized(with: store.lastConsumeAttempt, store.remainingCredits, store.daysUntilRenewal))
//        }
//    }
//    
//    private var creditColor: Color {
//        let percentage = Double(store.remainingCredits) / Double(max(1, store.totalCredits))
//        if percentage > 0.6 {
//            return .green
//        } else if percentage > 0.3 {
//            return .orange
//        } else {
//            return .red
//        }
//    }
//}
//
//// MARK: - View Modifier
//
//public struct CreditViewModifier: ViewModifier {
//    @Bindable var store: StoreOf<CreditFeature>
//    
//    public init(store: StoreOf<CreditFeature>) {
//        self.store = store
//    }
//    
//    public func body(content: Content) -> some View {
//        content
//            .alert("Insufficient Credits", isPresented: $store.showInsufficientCreditsAlert) {
//                Button("OK", role: .cancel) {
//                    store.send(.dismissInsufficientCreditsAlert)
//                }
//            } message: {
//                Text("You need \(store.lastConsumeAttempt) credits for this action, but you only have \(store.remainingCredits) credits remaining. Your credits will renew in \(store.daysUntilRenewal) days.")
//            }
//    }
//}
//
//// MARK: - View Extension
//
//extension View {
//    public func withCreditFeature(_ store: StoreOf<CreditFeature>) -> some View {
//        self.modifier(CreditViewModifier(store: store))
//    }
//}
