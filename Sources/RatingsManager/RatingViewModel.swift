import Foundation
import MessageUI
import SwiftUI
import StoreKit
import UIKit

public class RatingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var showPrePromptAlert = false
    @Published public var showFeedbackPrompt = false
    @Published public var showFeedbackConfirmation = false
    @Published public var isMailViewPresented = false
    @Published public var isMailUnavailableAlertPresented = false
    @Published public var isMailSentConfirmationPresented = false
    
    // MARK: - Constants
    private enum Constants {
        static let firstLaunchDateKey = "com.supertuber.firstLaunchDate"
        static let lastPromptDateKey = "com.supertuber.lastPromptDate"
        static let successfulActionCountKey = "com.supertuber.successfulActionCount"
    }
    
    // MARK: - Properties
    private let userDefaults: UserDefaults
    public var minimumDaysBeforePrompting: Int
    public var minimumActionsBeforePrompting: Int
    
    // MARK: - Initialization
    public init(
        userDefaults: UserDefaults = .standard,
        minimumDaysBeforePrompting: Int = 3,
        minimumActionsBeforePrompting: Int = 5,
        resetState: Bool = false
    ) {
        self.userDefaults = userDefaults
        self.minimumDaysBeforePrompting = minimumDaysBeforePrompting
        self.minimumActionsBeforePrompting = minimumActionsBeforePrompting
        
        if resetState {
            self.resetState()
        }
        
        // Initialize first launch date if not set
        if userDefaults.object(forKey: Constants.firstLaunchDateKey) == nil {
            userDefaults.set(Date(), forKey: Constants.firstLaunchDateKey)
        }
    }
    
    // MARK: - Public Methods
    
    /// Record a successful user action
    public func recordSuccessfulAction() {
        let currentCount = userDefaults.integer(forKey: Constants.successfulActionCountKey)
        userDefaults.set(currentCount + 1, forKey: Constants.successfulActionCountKey)
        
        // Check if we should show the rating prompt
        if shouldPromptForRating() {
            showRatingPrompt()
        }
    }
    
    /// Check if conditions are met to show rating prompt
    public func shouldPromptForRating() -> Bool {
        // Don't show if we've prompted recently
        if let lastPromptDate = userDefaults.object(forKey: Constants.lastPromptDateKey) as? Date {
            // Don't prompt more than once every 90 days
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPromptDate, to: Date()).day ?? 0
            if daysSinceLastPrompt < 90 {
                return false
            }
        }
        
        // Check if app has been used for minimum number of days
        guard let firstLaunchDate = userDefaults.object(forKey: Constants.firstLaunchDateKey) as? Date else { return false }
        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
        guard daysSinceFirstLaunch >= minimumDaysBeforePrompting else { return false }
        
        // Check if user has performed minimum number of successful actions
        let actionCount = userDefaults.integer(forKey: Constants.successfulActionCountKey)
        guard actionCount >= minimumActionsBeforePrompting else { return false }
        
        return true
    }
    
    /// Show rating prompt
    public func showRatingPrompt() {
        DispatchQueue.main.async { [weak self] in
            self?.showPrePromptAlert = true
        }
    }
    
    /// Request app review using StoreKit
    public func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            markAsPrompted()
        }
    }
    
    /// Mark that we've prompted the user
    public func markAsPrompted() {
        userDefaults.set(Date(), forKey: Constants.lastPromptDateKey)
    }
    
    /// Reset all rating-related state
    public func resetState() {
        userDefaults.removeObject(forKey: Constants.firstLaunchDateKey)
        userDefaults.removeObject(forKey: Constants.lastPromptDateKey)
        userDefaults.removeObject(forKey: Constants.successfulActionCountKey)
        
        // Record new first launch date
        userDefaults.set(Date(), forKey: Constants.firstLaunchDateKey)
    }
    
    /// Postpone rating by resetting action count
    public func postponeRating() {
        // Reset action count
        userDefaults.set(0, forKey: Constants.successfulActionCountKey)
    }
    
    // MARK: - Email Support Methods
    
    /// Show email feedback form
    public func showEmailFeedback() {
        showFeedbackConfirmation = false
        if MFMailComposeViewController.canSendMail() {
            isMailViewPresented = true
        } else {
            isMailUnavailableAlertPresented = true
        }
    }
    
    /// Handle mail sent callback
    public func handleMailSent(_ sent: Bool) {
        isMailViewPresented = false
        if sent {
            isMailSentConfirmationPresented = true
        }
    }
}

// MARK: - Shared Instance
extension RatingViewModel {
    public static let shared = RatingViewModel(
        minimumDaysBeforePrompting: 0,
        minimumActionsBeforePrompting: 2,
        resetState: true
    )
}
