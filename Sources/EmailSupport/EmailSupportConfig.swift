import SwiftUI
import Foundation

/// Configuration class for the EmailSupport module
public class EmailSupportConfig {
    // MARK: - Singleton
    
    /// Shared instance for easy access
    public static let shared = EmailSupportConfig()
    
    // MARK: - Email Configuration
    
    /// The subject line for support emails
    private var emailSubject: String = "App Support Request"
    
    /// The default email body template
    private var emailBodyTemplate: String = "Hello Support Team,\n\n[Please describe your issue here.]\n\n------------------------\n%@\n------------------------"
    
    /// The recipient email addresses
    private var toRecipients: [String] = ["support@example.com"]
    
    /// Whether to include device information in the email
    private var includeDeviceInfo: Bool = true
    
    // MARK: - UI Configuration
    
    /// The text for the support button
    private var supportButtonText: String = "Contact Support"
    
    /// The system image name for the support button
    private var supportButtonIcon: String = "mail"
    
    /// The primary color for the support button
    private var primaryColor: Color = .blue
    
    /// The text color for the support button
    private var textColor: Color = .white
    
    /// The font for the support button
    private var buttonFont: Font = .headline
    
    // MARK: - Alert Configuration
    
    /// The title for the mail unavailable alert
    private var mailUnavailableAlertTitle: String = "Mail Not Configured"
    
    /// The message for the mail unavailable alert
    private var mailUnavailableAlertMessage: String = "Please configure the Mail app on your device to send support emails."
    
    /// The title for the mail sent confirmation alert
    private var mailSentConfirmationTitle: String = "Thanks!"
    
    /// The message for the mail sent confirmation alert
    private var mailSentConfirmationMessage: String = "Your support email was sent successfully."
    
    /// The text for the OK button in alerts
    private var alertOkButtonText: String = "OK"
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - Email Configuration Methods
    
    /// Sets the subject line for support emails
    /// - Parameter subject: The subject line
    /// - Returns: The config instance for chaining
    public func setEmailSubject(_ subject: String) -> Self {
        self.emailSubject = subject
        return self
    }
    
    /// Gets the subject line for support emails
    /// - Returns: The subject line
    public func getEmailSubject() -> String {
        return emailSubject
    }
    
    /// Sets the email body template
    /// - Parameter template: The email body template. Use %@ as a placeholder for device info
    /// - Returns: The config instance for chaining
    public func setEmailBodyTemplate(_ template: String) -> Self {
        self.emailBodyTemplate = template
        return self
    }
    
    /// Gets the email body template
    /// - Returns: The email body template
    public func getEmailBodyTemplate() -> String {
        return emailBodyTemplate
    }
    
    /// Sets the recipient email addresses
    /// - Parameter recipients: Array of email addresses
    /// - Returns: The config instance for chaining
    public func setToRecipients(_ recipients: [String]) -> Self {
        self.toRecipients = recipients
        return self
    }
    
    /// Gets the recipient email addresses
    /// - Returns: Array of email addresses
    public func getToRecipients() -> [String] {
        return toRecipients
    }
    
    /// Sets whether to include device information in the email
    /// - Parameter include: Boolean indicating whether to include device info
    /// - Returns: The config instance for chaining
    public func setIncludeDeviceInfo(_ include: Bool) -> Self {
        self.includeDeviceInfo = include
        return self
    }
    
    /// Gets whether to include device information in the email
    /// - Returns: Boolean indicating whether to include device info
    public func shouldIncludeDeviceInfo() -> Bool {
        return includeDeviceInfo
    }
    
    // MARK: - UI Configuration Methods
    
    /// Sets the text for the support button
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    public func setSupportButtonText(_ text: String) -> Self {
        self.supportButtonText = text
        return self
    }
    
    /// Gets the text for the support button
    /// - Returns: The button text
    public func getSupportButtonText() -> String {
        return supportButtonText
    }
    
    /// Sets the system image name for the support button
    /// - Parameter iconName: The SF Symbol name
    /// - Returns: The config instance for chaining
    public func setSupportButtonIcon(_ iconName: String) -> Self {
        self.supportButtonIcon = iconName
        return self
    }
    
    /// Gets the system image name for the support button
    /// - Returns: The SF Symbol name
    public func getSupportButtonIcon() -> String {
        return supportButtonIcon
    }
    
    /// Sets the primary color for the support button
    /// - Parameter color: The color
    /// - Returns: The config instance for chaining
    public func setPrimaryColor(_ color: Color) -> Self {
        self.primaryColor = color
        return self
    }
    
    /// Gets the primary color for the support button
    /// - Returns: The color
    public func getPrimaryColor() -> Color {
        return primaryColor
    }
    
    /// Sets the text color for the support button
    /// - Parameter color: The color
    /// - Returns: The config instance for chaining
    public func setTextColor(_ color: Color) -> Self {
        self.textColor = color
        return self
    }
    
    /// Gets the text color for the support button
    /// - Returns: The color
    public func getTextColor() -> Color {
        return textColor
    }
    
    /// Sets the font for the support button
    /// - Parameter font: The font
    /// - Returns: The config instance for chaining
    public func setButtonFont(_ font: Font) -> Self {
        self.buttonFont = font
        return self
    }
    
    /// Gets the font for the support button
    /// - Returns: The font
    public func getButtonFont() -> Font {
        return buttonFont
    }
    
    // MARK: - Alert Configuration Methods
    
    /// Sets the title for the mail unavailable alert
    /// - Parameter title: The alert title
    /// - Returns: The config instance for chaining
    public func setMailUnavailableAlertTitle(_ title: String) -> Self {
        self.mailUnavailableAlertTitle = title
        return self
    }
    
    /// Gets the title for the mail unavailable alert
    /// - Returns: The alert title
    public func getMailUnavailableAlertTitle() -> String {
        return mailUnavailableAlertTitle
    }
    
    /// Sets the message for the mail unavailable alert
    /// - Parameter message: The alert message
    /// - Returns: The config instance for chaining
    public func setMailUnavailableAlertMessage(_ message: String) -> Self {
        self.mailUnavailableAlertMessage = message
        return self
    }
    
    /// Gets the message for the mail unavailable alert
    /// - Returns: The alert message
    public func getMailUnavailableAlertMessage() -> String {
        return mailUnavailableAlertMessage
    }
    
    /// Sets the title for the mail sent confirmation alert
    /// - Parameter title: The alert title
    /// - Returns: The config instance for chaining
    public func setMailSentConfirmationTitle(_ title: String) -> Self {
        self.mailSentConfirmationTitle = title
        return self
    }
    
    /// Gets the title for the mail sent confirmation alert
    /// - Returns: The alert title
    public func getMailSentConfirmationTitle() -> String {
        return mailSentConfirmationTitle
    }
    
    /// Sets the message for the mail sent confirmation alert
    /// - Parameter message: The alert message
    /// - Returns: The config instance for chaining
    public func setMailSentConfirmationMessage(_ message: String) -> Self {
        self.mailSentConfirmationMessage = message
        return self
    }
    
    /// Gets the message for the mail sent confirmation alert
    /// - Returns: The alert message
    public func getMailSentConfirmationMessage() -> String {
        return mailSentConfirmationMessage
    }
    
    /// Sets the text for the OK button in alerts
    /// - Parameter text: The button text
    /// - Returns: The config instance for chaining
    public func setAlertOkButtonText(_ text: String) -> Self {
        self.alertOkButtonText = text
        return self
    }
    
    /// Gets the text for the OK button in alerts
    /// - Returns: The button text
    public func getAlertOkButtonText() -> String {
        return alertOkButtonText
    }
}
