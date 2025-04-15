////
////  RatingService.swift
////  SuperTuber
////
////  Created by mohamed abd elaleem on 06/04/2025.
////
//
//import SwiftUI
//import StoreKit
//import ComposableArchitecture
//
//// MARK: - Rating Service Singleton
//
//public final class RatingService: ObservableObject {
//    // MARK: - Singleton
//    public static let shared = RatingService()
//    
//    // MARK: - Published Properties
//    @Published var showPrePromptAlert = false
//    @Published var showFeedbackPrompt = false
//    
//    // MARK: - Constants
//    private enum Constants {
//        static let firstLaunchDateKey = "com.supertuber.firstLaunchDate"
//        static let successfulActionCountKey = "com.supertuber.successfulActionCount"
//        static let ratingPromptBaseKey = "com.supertuber.hasPromptedForRating"
//    }
//    
//    // MARK: - Properties
//    private let userDefaults: UserDefaults
//    private let appVersion: String
//    
//    // Configurable thresholds
//    var minimumDaysBeforePrompting: Int = 3
//    var minimumActionsBeforePrompting: Int = 5
//    
//    // MARK: - Initialization
//    init(userDefaults: UserDefaults = .standard) {
//        self.userDefaults = userDefaults
//        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
//        registerFirstLaunchIfNeeded()
//    }
//    
//    // MARK: - Public Methods
//    
//    /// Record a successful user action (like completing a video summary)
//    func recordSuccessfulAction() {
//        let currentCount = successfulActionCount
//        userDefaults.set(currentCount + 1, forKey: Constants.successfulActionCountKey)
//        
//        if shouldPromptForRating() {
//            showRatingPrompt()
//        }
//    }
//    
//    /// Check if conditions are met to show rating prompt
//    func shouldPromptForRating() -> Bool {
//        // Don't prompt if already prompted for this version
//        guard !hasPromptedForRating else { return false }
//        
//        // Check if app has been used for minimum days
//        guard let firstLaunch = firstLaunchDate,
//              Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0 >= minimumDaysBeforePrompting else {
//            return false
//        }
//        
//        // Check if user has performed minimum successful actions
//        guard successfulActionCount >= minimumActionsBeforePrompting else { return false }
//        
//        return true
//    }
//    
//    /// Show rating prompt with pre-prompt dialog
//    func showRatingPrompt() {
//        DispatchQueue.main.async { [weak self] in
//            self?.showPrePromptAlert = true
//        }
//    }
//    
//    /// Request app review using StoreKit
//    func requestReview() {
//        if let scene = UIApplication.shared.connectedScenes
//            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
//            SKStoreReviewController.requestReview(in: scene)
//            markAsPrompted()
//        }
//    }
//    
//    /// Mark that we've prompted the user for this version
//    func markAsPrompted() {
//        userDefaults.set(true, forKey: ratingPromptKey)
//    }
//    
//    /// Reset all rating-related state (mainly for testing)
//    func resetState() {
//        userDefaults.set(false, forKey: ratingPromptKey)
//        userDefaults.set(0, forKey: Constants.successfulActionCountKey)
//        userDefaults.removeObject(forKey: Constants.firstLaunchDateKey)
//        registerFirstLaunchIfNeeded()
//    }
//    
//    // MARK: - Private Methods
//    private func registerFirstLaunchIfNeeded() {
//        if userDefaults.object(forKey: Constants.firstLaunchDateKey) == nil {
//            userDefaults.set(Date(), forKey: Constants.firstLaunchDateKey)
//        }
//    }
//    
//    // MARK: - Computed Properties
//    
//    /// Get the key used to track if rating has been prompted for current version
//    private var ratingPromptKey: String {
//        "\(Constants.ratingPromptBaseKey).\(appVersion)"
//    }
//    
//    /// Check if user has been prompted for rating in current version
//    var hasPromptedForRating: Bool {
//        userDefaults.bool(forKey: ratingPromptKey)
//    }
//    
//    /// Get the date of first app launch
//    var firstLaunchDate: Date? {
//        userDefaults.object(forKey: Constants.firstLaunchDateKey) as? Date
//    }
//    
//    /// Get count of successful actions
//    var successfulActionCount: Int {
//        userDefaults.integer(forKey: Constants.successfulActionCountKey)
//    }
//}
//
//// MARK: - TCA Integration
//
//// Define a dependency key for the rating service
//public enum RatingServiceKey: DependencyKey {
//    public static let liveValue = RatingService.shared
//    
//    // For testing
//    public static var testValue = RatingService(userDefaults: .standard)
//}
//
//extension DependencyValues {
//    public var ratingService: RatingService {
//        get { self[RatingServiceKey.self] }
//        set { self[RatingServiceKey.self] = newValue }
//    }
//}
//
//// MARK: - TCA Feature
//@Reducer
//public struct RatingFeature {
//    @ObservableState
//    public struct State: Equatable {
//        var showPrePromptAlert = false
//        var showFeedbackPrompt = false
//    }
//
//    public enum Action: BindableAction, Equatable {
//        case onAppear
//        case triggerRating
//        case recordSuccessfulAction
//        case resetPromptState
//
//        case prePromptConfirmed(Bool) // true if user likes the app
//        case dismissFeedbackPrompt
//
//        case binding(BindingAction<State>)
//    }
//
//    @Dependency(\.ratingService) public var ratingService
//
//    public var body: some ReducerOf<Self> {
//        
//        BindingReducer()
//        
//        Reduce { state, action in
//            switch action {
//            case .onAppear:
//                // No initialization needed as the service handles this
//                return .none
//
//            case .recordSuccessfulAction:
//                ratingService.recordSuccessfulAction()
//                return .none
//
//            case .triggerRating:
//                if ratingService.shouldPromptForRating() {
//                    state.showPrePromptAlert = true
//                }
//                return .none
//
//            case .prePromptConfirmed(let likesApp):
//                state.showPrePromptAlert = false
//                if likesApp {
//                    ratingService.requestReview()
//                } else {
//                    state.showFeedbackPrompt = true
//                }
//                return .none
//
//            case .dismissFeedbackPrompt:
//                state.showFeedbackPrompt = false
//                return .none
//
//            case .resetPromptState:
//                ratingService.resetState()
//                return .none
//
//            default:
//                return .none
//            }
//        }
//    }
//
//}
//
//// MARK: - SwiftUI Views
//
//// Rating alerts modifier that can be attached to any view
//public struct RatingAlertsModifier: ViewModifier {
//    @ObservedObject private var ratingService = RatingService.shared
//    
//    // Optional callback for when rating is completed
//    public var onRatingCompleted: (() -> Void)? = nil
//    
//    public func body(content: Content) -> some View {
//                
//        content
//            .alert("Do you enjoy using the app?", isPresented: $ratingService.showPrePromptAlert) {
//                Button("Yes, I love it!") {
//                    ratingService.requestReview()
//                    onRatingCompleted?()
//                }
//                Button("Not really") {
//                    ratingService.showFeedbackPrompt = true
//                }
//                Button("Cancel", role: .cancel) {}
//            }
//            .alert("We'd love your feedback", isPresented: $ratingService.showFeedbackPrompt) {
//                Button("OK", role: .cancel) {
//                    onRatingCompleted?()
//                }
//            } message: {
//                Text("Please contact us and let us know how we can improve your experience.")
//            }
//    }
//}
//
//// Extension to easily add rating alerts to any view
//extension View {
//    func withRatingAlerts(onRatingCompleted: (() -> Void)? = nil) -> some View {
//        self.modifier(RatingAlertsModifier(onRatingCompleted: onRatingCompleted))
//    }
//}
//
//// TCA version for use with the RatingFeature
//struct RatingViewModifier: ViewModifier {
//    
//    @Bindable var store: StoreOf<RatingFeature>
//
//    func body(content: Content) -> some View {
//        content
//            .onAppear {
//                store.send(.onAppear)
//            }
//            .alert("Do you enjoy using the app?", isPresented: $store.showPrePromptAlert) {
//                Button("Yes, I love it!") {
//                    store.send(.prePromptConfirmed(true))
//                }
//                Button("Not really") {
//                    store.send(.prePromptConfirmed(false))
//                }
//                Button("Cancel", role: .cancel) {}
//            }
//            .alert("We'd love your feedback", isPresented: $store.showFeedbackPrompt) {
//                Button("OK", role: .cancel) {
//                    store.send(.dismissFeedbackPrompt)
//                }
//            } message: {
//                Text("Please contact us and let us know how we can improve your experience.")
//            }
//    }
//    
//}
