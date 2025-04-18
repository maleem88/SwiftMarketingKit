import SwiftUI
import MessageUI
import UIKit
import EmailSupport



//
//// MARK: - Mail View
//public struct MailView: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) var presentation
//    var subject: String
//    var body: String
//    var toRecipients: [String]
//    var onDismiss: (Bool) -> Void
//
//    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//        var parent: MailView
//
//        init(_ parent: MailView) {
//            self.parent = parent
//        }
//
//        public func mailComposeController(_ controller: MFMailComposeViewController,
//                                   didFinishWith result: MFMailComposeResult,
//                                   error: Error?) {
//            controller.dismiss(animated: true) {
//                self.parent.presentation.wrappedValue.dismiss()
//                self.parent.onDismiss(result == .sent)
//            }
//        }
//    }
//
//    public func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
//        let vc = MFMailComposeViewController()
//        vc.setSubject(subject)
//        vc.setMessageBody(body, isHTML: false)
//        vc.setToRecipients(toRecipients)
//        vc.mailComposeDelegate = context.coordinator
//        return vc
//    }
//
//    public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
//}
//
//// MARK: - Device Info Helper
//public struct DeviceInfoHelper {
//    public static func getDeviceInfo() -> String {
//        let device = UIDevice.current
//        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
//        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
//        
//        return """
//        Device: \(device.model)
//        iOS Version: \(device.systemVersion)
//        App Version: \(appVersion) (\(buildNumber))
//        """
//    }
//}

// MARK: - Rating View Modifier
public struct RatingViewModifier: ViewModifier {
    @ObservedObject var viewModel: RatingViewModel
    
    public init(viewModel: RatingViewModel) {
        self.viewModel = viewModel
    }
    
    public func body(content: Content) -> some View {
        content
            .alert(RatingsManagerConfig.shared.getEnjoymentPromptTitle(), isPresented: $viewModel.showPrePromptAlert) {
                Button(RatingsManagerConfig.shared.getEnjoymentPromptPositiveButtonText()) {
                    viewModel.requestReview()
                }
                
                if RatingsManagerConfig.shared.getIncludeFeedbackOption() {
                    Button(RatingsManagerConfig.shared.getEnjoymentPromptNegativeButtonText()) {
                        viewModel.showFeedbackConfirmation = true
                    }
                }
                
                Button(RatingsManagerConfig.shared.getEnjoymentPromptCancelButtonText(), role: .cancel) {
                    viewModel.postponeRating()
                }
            }
            // Feedback confirmation alert
            .alert(RatingsManagerConfig.shared.getFeedbackPromptTitle(), isPresented: $viewModel.showFeedbackConfirmation) {
                Button(RatingsManagerConfig.shared.getFeedbackPromptPositiveButtonText()) {
                    viewModel.showEmailFeedback()
                }
                Button(RatingsManagerConfig.shared.getFeedbackPromptCancelButtonText(), role: .cancel) {
                    viewModel.showFeedbackConfirmation = false
                }
            } message: {
                Text(RatingsManagerConfig.shared.getFeedbackPromptMessage())
            }
            
            // Email support integration
            .sheet(isPresented: $viewModel.isMailViewPresented) {
                
                MailViewVM(
                    subject: viewModel.getEmailSubject(),
                    body: viewModel.getEmailBody(),
                    toRecipients: viewModel.getEmailRecipients(),
                    onDismiss: { sent in
                        viewModel.handleMailSent(sent)
                    }
                )
            }
            .alert(RatingsManagerConfig.shared.getMailUnavailableAlertTitle(), isPresented: $viewModel.isMailUnavailableAlertPresented) {
                Button(RatingsManagerConfig.shared.getMailUnavailableAlertButtonText(), role: .cancel) {}
            } message: {
                Text(RatingsManagerConfig.shared.getMailUnavailableAlertMessage())
            }
            .alert(RatingsManagerConfig.shared.getMailSentConfirmationTitle(), isPresented: $viewModel.isMailSentConfirmationPresented) {
                Button(RatingsManagerConfig.shared.getMailSentConfirmationButtonText(), role: .cancel) {}
            } message: {
                Text(RatingsManagerConfig.shared.getMailSentConfirmationMessage())
            }
    }
}

// MARK: - View Extension
extension View {
    public func withRatingFeature(viewModel: RatingViewModel = RatingViewModel.shared) -> some View {
        self.modifier(RatingViewModifier(viewModel: viewModel))
    }
}
