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
    
    public init(mailChecker: MailCheckable = DefaultMailChecker()) {
        self.mailChecker = mailChecker
    }
    
    
    
    public func contactSupportTapped() {
        if mailChecker.canSendMail() {
            isMailViewPresented = true
        } else {
            isMailUnavailableAlertPresented = true
        }
    }
    
    public func handleMailSent(_ success: Bool) {
        isMailViewPresented = false
        if success {
            isMailSentConfirmationPresented = true
        }
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

    public init(viewModel: EmailSupportViewModel = EmailSupportViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Button {
            viewModel.contactSupportTapped()
        } label: {
            Label("Contact Support", systemImage: "mail")
        }
        .sheet(isPresented: $viewModel.isMailViewPresented) {
            MailViewVM(
                subject: "SuperTuber Support Request",
                body: String(format: "Hello Support Team,\n\n[Please describe your issue here.]\n\n------------------------\n%@\n------------------------", DeviceInfoHelper.getDeviceInfo()),
                toRecipients: ["supertuber@smartappsfor.us"],
                onDismiss: { sent in
                    viewModel.handleMailSent(sent)
                }
            )
        }
        .alert("Mail Not Configured", isPresented: $viewModel.isMailUnavailableAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please configure the Mail app on your device to send support emails.")
        }
        .alert("Thanks!", isPresented: $viewModel.isMailSentConfirmationPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your support email was sent successfully.")
        }
    }
}
