import Foundation
import UIKit
import SwiftUI

/// Configuration class for customizing the RatingsManager experience
public class RatingsManagerConfig {
    // MARK: - Singleton
    public static let shared = RatingsManagerConfig()
    
    // MARK: - Properties
    
    // Timing configuration
    private var minimumDaysBeforePrompting: Int = 3
    private var minimumActionsBeforePrompting: Int = 5
    
    // App information
    private var appName: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "App"
    private var appIcon: UIImage?
    
    // Email feedback configuration
    private var feedbackEmailRecipients: [String] = []
    private var feedbackEmailSubject: String = "App Feedback"
    private var feedbackEmailBodyTemplate: String = """
    Hello,
    
    I'd like to provide some feedback about the app:
    
    [Please describe what you don't like or what could be improved]
    
    ------------------------
    [DEVICE_INFO]
    ------------------------
    """
    private var includeFeedbackOption: Bool = true
    
    // Alert text customization
    private var enjoymentPromptTitle: String = "Do you enjoy using the app?"
    private var enjoymentPromptPositiveButtonText: String = "Yes, I love it!"
    private var enjoymentPromptNegativeButtonText: String = "Not really"
    private var enjoymentPromptCancelButtonText: String = "Cancel"
    
    private var feedbackPromptTitle: String = "We'd love your feedback"
    private var feedbackPromptMessage: String = "Would you like to send us feedback about what could be improved?"
    private var feedbackPromptPositiveButtonText: String = "Send Feedback"
    private var feedbackPromptCancelButtonText: String = "Cancel"
    
    private var mailSentConfirmationTitle: String = "Thanks!"
    private var mailSentConfirmationMessage: String = "Your feedback email was sent successfully. We appreciate your input!"
    private var mailSentConfirmationButtonText: String = "OK"
    
    private var mailUnavailableAlertTitle: String = "Mail Not Configured"
    private var mailUnavailableAlertMessage: String = "Please configure the Mail app on your device to send feedback emails."
    private var mailUnavailableAlertButtonText: String = "OK"
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Configuration Methods
    
    /// Set the minimum number of days before prompting for a rating
    /// - Parameter days: Number of days (default: 3)
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setMinimumDaysBeforePrompting(_ days: Int) -> Self {
        self.minimumDaysBeforePrompting = days
        return self
    }
    
    /// Set the minimum number of successful actions before prompting for a rating
    /// - Parameter actions: Number of actions (default: 5)
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setMinimumActionsBeforePrompting(_ actions: Int) -> Self {
        self.minimumActionsBeforePrompting = actions
        return self
    }
    
    /// Set the app name used in prompts and emails
    /// - Parameter name: The app name
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setAppName(_ name: String) -> Self {
        self.appName = name
        return self
    }
    
    /// Set the app icon used in feedback emails
    /// - Parameter icon: UIImage of the app icon
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setAppIcon(_ icon: UIImage) -> Self {
        self.appIcon = icon
        return self
    }
    
    /// Configure the email feedback recipients
    /// - Parameter recipients: Array of email addresses
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setFeedbackEmailRecipients(_ recipients: [String]) -> Self {
        self.feedbackEmailRecipients = recipients
        return self
    }
    
    /// Configure the email feedback subject
    /// - Parameter subject: Email subject line
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setFeedbackEmailSubject(_ subject: String) -> Self {
        self.feedbackEmailSubject = subject
        return self
    }
    
    /// Configure the email feedback body template
    /// - Parameter template: Email body template. Use [DEVICE_INFO] placeholder to include device information.
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setFeedbackEmailBodyTemplate(_ template: String) -> Self {
        self.feedbackEmailBodyTemplate = template
        return self
    }
    
    /// Configure whether to include the feedback option when user doesn't enjoy the app
    /// - Parameter include: Boolean indicating whether to include feedback option
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setIncludeFeedbackOption(_ include: Bool) -> Self {
        self.includeFeedbackOption = include
        return self
    }
    
    /// Customize the enjoyment prompt title
    /// - Parameter title: The title text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setEnjoymentPromptTitle(_ title: String) -> Self {
        self.enjoymentPromptTitle = title
        return self
    }
    
    /// Customize the enjoyment prompt positive button text
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setEnjoymentPromptPositiveButtonText(_ text: String) -> Self {
        self.enjoymentPromptPositiveButtonText = text
        return self
    }
    
    /// Customize the enjoyment prompt negative button text
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setEnjoymentPromptNegativeButtonText(_ text: String) -> Self {
        self.enjoymentPromptNegativeButtonText = text
        return self
    }
    
    /// Customize the enjoyment prompt cancel button text
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setEnjoymentPromptCancelButtonText(_ text: String) -> Self {
        self.enjoymentPromptCancelButtonText = text
        return self
    }
    
    /// Customize the feedback prompt title
    /// - Parameter title: The title text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setFeedbackPromptTitle(_ title: String) -> Self {
        self.feedbackPromptTitle = title
        return self
    }
    
    /// Customize the feedback prompt message
    /// - Parameter message: The message text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setFeedbackPromptMessage(_ message: String) -> Self {
        self.feedbackPromptMessage = message
        return self
    }
    
    /// Customize the feedback prompt positive button text
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setFeedbackPromptPositiveButtonText(_ text: String) -> Self {
        self.feedbackPromptPositiveButtonText = text
        return self
    }
    
    /// Customize the feedback prompt cancel button text
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setFeedbackPromptCancelButtonText(_ text: String) -> Self {
        self.feedbackPromptCancelButtonText = text
        return self
    }
    
    /// Customize the mail sent confirmation title
    /// - Parameter title: The title text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setMailSentConfirmationTitle(_ title: String) -> Self {
        self.mailSentConfirmationTitle = title
        return self
    }
    
    /// Customize the mail sent confirmation message
    /// - Parameter message: The message text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setMailSentConfirmationMessage(_ message: String) -> Self {
        self.mailSentConfirmationMessage = message
        return self
    }
    
    /// Customize the mail sent confirmation button text
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setMailSentConfirmationButtonText(_ text: String) -> Self {
        self.mailSentConfirmationButtonText = text
        return self
    }
    
    /// Customize the mail unavailable alert title
    /// - Parameter title: The title text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setMailUnavailableAlertTitle(_ title: String) -> Self {
        self.mailUnavailableAlertTitle = title
        return self
    }
    
    /// Customize the mail unavailable alert message
    /// - Parameter message: The message text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setMailUnavailableAlertMessage(_ message: String) -> Self {
        self.mailUnavailableAlertMessage = message
        return self
    }
    
    /// Customize the mail unavailable alert button text
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setMailUnavailableAlertButtonText(_ text: String) -> Self {
        self.mailUnavailableAlertButtonText = text
        return self
    }
    
    // MARK: - Internal Getters
    
    func getMinimumDaysBeforePrompting() -> Int {
        return minimumDaysBeforePrompting
    }
    
    func getMinimumActionsBeforePrompting() -> Int {
        return minimumActionsBeforePrompting
    }
    
    func getAppName() -> String {
        return appName
    }
    
    func getAppIcon() -> UIImage? {
        return appIcon
    }
    
    func getFeedbackEmailRecipients() -> [String] {
        return feedbackEmailRecipients
    }
    
    func getFeedbackEmailSubject() -> String {
        return feedbackEmailSubject
    }
    
    func getFeedbackEmailBodyTemplate() -> String {
        return feedbackEmailBodyTemplate
    }
    
    func getIncludeFeedbackOption() -> Bool {
        return includeFeedbackOption
    }
    
    func getEnjoymentPromptTitle() -> String {
        return enjoymentPromptTitle
    }
    
    func getEnjoymentPromptPositiveButtonText() -> String {
        return enjoymentPromptPositiveButtonText
    }
    
    func getEnjoymentPromptNegativeButtonText() -> String {
        return enjoymentPromptNegativeButtonText
    }
    
    func getEnjoymentPromptCancelButtonText() -> String {
        return enjoymentPromptCancelButtonText
    }
    
    func getFeedbackPromptTitle() -> String {
        return feedbackPromptTitle
    }
    
    func getFeedbackPromptMessage() -> String {
        return feedbackPromptMessage
    }
    
    func getFeedbackPromptPositiveButtonText() -> String {
        return feedbackPromptPositiveButtonText
    }
    
    func getFeedbackPromptCancelButtonText() -> String {
        return feedbackPromptCancelButtonText
    }
    
    func getMailSentConfirmationTitle() -> String {
        return mailSentConfirmationTitle
    }
    
    func getMailSentConfirmationMessage() -> String {
        return mailSentConfirmationMessage
    }
    
    func getMailSentConfirmationButtonText() -> String {
        return mailSentConfirmationButtonText
    }
    
    func getMailUnavailableAlertTitle() -> String {
        return mailUnavailableAlertTitle
    }
    
    func getMailUnavailableAlertMessage() -> String {
        return mailUnavailableAlertMessage
    }
    
    func getMailUnavailableAlertButtonText() -> String {
        return mailUnavailableAlertButtonText
    }
}
