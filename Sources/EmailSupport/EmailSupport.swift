import SwiftUI
import MessageUI
import Foundation
import UIKit


// MARK: - ViewModel
public class EmailSupportViewModel: ObservableObject {
    @Published public var isMailViewPresented = false
    @Published public var isMailUnavailableAlertPresented = false
    @Published public var isMailSentConfirmationPresented = false
    
    private let mailChecker: MailCheckable
    private let config: EmailSupportConfig
    
    /// Initialize with default settings
    public init(mailChecker: MailCheckable = DefaultMailChecker(), config: EmailSupportConfig = EmailSupportConfig.shared) {
        self.mailChecker = mailChecker
        self.config = config
    }
    
    /// Handles the contact support button tap
    public func contactSupportTapped() {
        if mailChecker.canSendMail() {
            isMailViewPresented = true
        } else {
            isMailUnavailableAlertPresented = true
        }
    }
    
    /// Handles the mail sent callback
    public func handleMailSent(_ success: Bool) {
        isMailViewPresented = false
        if success {
            isMailSentConfirmationPresented = true
        }
    }
    
    // MARK: - Configuration Access Methods
    
    /// Gets the email subject from config
    public func getEmailSubject() -> String {
        return config.getEmailSubject()
    }
    
    /// Gets the email body from config
    public func getEmailBody() -> String {
        let template = config.getEmailBodyTemplate()
        if config.shouldIncludeDeviceInfo() {
            return String(format: template, DeviceInfoHelper.getDeviceInfo())
        } else {
            return template.replacingOccurrences(of: "%@", with: "")
        }
    }
    
    /// Gets the recipient email addresses from config
    public func getToRecipients() -> [String] {
        return config.getToRecipients()
    }
    
    /// Gets the support button text from config
    public func getSupportButtonText() -> String {
        return config.getSupportButtonText()
    }
    
    /// Gets the support button icon from config
    public func getSupportButtonIcon() -> String {
        return config.getSupportButtonIcon()
    }
    
    /// Gets the primary color from config
    public func getPrimaryColor() -> Color {
        return config.getPrimaryColor()
    }
    
    /// Gets the text color from config
    public func getTextColor() -> Color {
        return config.getTextColor()
    }
    
    /// Gets the button font from config
    public func getButtonFont() -> Font {
        return config.getButtonFont()
    }
    
    /// Gets the mail unavailable alert title from config
    public func getMailUnavailableAlertTitle() -> String {
        return config.getMailUnavailableAlertTitle()
    }
    
    /// Gets the mail unavailable alert message from config
    public func getMailUnavailableAlertMessage() -> String {
        return config.getMailUnavailableAlertMessage()
    }
    
    /// Gets the mail sent confirmation title from config
    public func getMailSentConfirmationTitle() -> String {
        return config.getMailSentConfirmationTitle()
    }
    
    /// Gets the mail sent confirmation message from config
    public func getMailSentConfirmationMessage() -> String {
        return config.getMailSentConfirmationMessage()
    }
    
    /// Gets the alert OK button text from config
    public func getAlertOkButtonText() -> String {
        return config.getAlertOkButtonText()
    }
}

// MARK: - Protocol for Testability
public protocol MailCheckable {
    func canSendMail() -> Bool
}

public struct DefaultMailChecker: MailCheckable {
    public init() {}
    
    public func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
}

// MARK: - MailView for SwiftUI (Same as original)
public struct MailViewVM: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    var subject: String
    var body: String
    var toRecipients: [String]
    var onDismiss: (Bool) -> Void

    public init(
        
        subject: String,
        body: String,
        toRecipients: [String],
        onDismiss: @escaping (Bool) -> Void
    ) {
        
        self.subject = subject
        self.body = body
        self.toRecipients = toRecipients
        self.onDismiss = onDismiss
    }
    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailViewVM

        public init(_ parent: MailViewVM) {
            self.parent = parent
        }

        public func mailComposeController(_ controller: MFMailComposeViewController,
                                          didFinishWith result: MFMailComposeResult,
                                          error: Error?) {
            controller.dismiss(animated: true) {
                self.parent.presentation.wrappedValue.dismiss()
                self.parent.onDismiss(result == .sent)
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.setToRecipients(toRecipients)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

// MARK: - View
public struct SupportButtonVM: View {
    @ObservedObject var viewModel: EmailSupportViewModel

    /// Initialize with default view model
    public init(viewModel: EmailSupportViewModel = EmailSupportViewModel()) {
        self.viewModel = viewModel
    }
    
    /// Initialize with custom configuration
    public init(config: EmailSupportConfig) {
        self.viewModel = EmailSupportViewModel(config: config)
    }
    
    public var body: some View {
        Button {
            viewModel.contactSupportTapped()
        } label: {
            Label(viewModel.getSupportButtonText(), systemImage: viewModel.getSupportButtonIcon())
                .font(viewModel.getButtonFont())
                .foregroundColor(viewModel.getTextColor())
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .tint(viewModel.getPrimaryColor())
        .sheet(isPresented: $viewModel.isMailViewPresented) {
            MailViewVM(
                subject: viewModel.getEmailSubject(),
                body: viewModel.getEmailBody(),
                toRecipients: viewModel.getToRecipients(),
                onDismiss: { sent in
                    viewModel.handleMailSent(sent)
                }
            )
        }
        .alert(viewModel.getMailUnavailableAlertTitle(), isPresented: $viewModel.isMailUnavailableAlertPresented) {
            Button(viewModel.getAlertOkButtonText(), role: .cancel) {}
        } message: {
            Text(viewModel.getMailUnavailableAlertMessage())
        }
        .alert(viewModel.getMailSentConfirmationTitle(), isPresented: $viewModel.isMailSentConfirmationPresented) {
            Button(viewModel.getAlertOkButtonText(), role: .cancel) {}
        } message: {
            Text(viewModel.getMailSentConfirmationMessage())
        }
    }
}
