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
            .alert("Do you enjoy using the app?", isPresented: $viewModel.showPrePromptAlert) {
                Button("Yes, I love it!") {
                    viewModel.requestReview()
                }
                Button("Not really") {
                    viewModel.showFeedbackConfirmation = true
                }
                Button("Cancel", role: .cancel) {
                    viewModel.postponeRating()
                }
            }
            // Feedback confirmation alert
            .alert("We'd love your feedback", isPresented: $viewModel.showFeedbackConfirmation) {
                Button("Send Feedback") {
                    viewModel.showEmailFeedback()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.showFeedbackConfirmation = false
                }
            } message: {
                Text("Would you like to send us feedback about what could be improved?")
            }
            
            // Email support integration
            .sheet(isPresented: $viewModel.isMailViewPresented) {
                
                MailViewVM(
                    subject: "SuperTuber Feedback",
                    body: """
                    Hello SuperTuber Team,
                    
                    I'd like to provide some feedback about the app:
                    
                    [Please describe what you don't like or what could be improved]
                    
                    ------------------------
                    \(DeviceInfoHelper.getDeviceInfo())
                    ------------------------
                    """,
                    toRecipients: ["supertuber@smartappsfor.us"],
                    onDismiss: { sent in
                        viewModel.handleMailSent(sent)
                    }
                )
            }
            .alert("Mail Not Configured", isPresented: $viewModel.isMailUnavailableAlertPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please configure the Mail app on your device to send feedback emails.")
            }
            .alert("Thanks!", isPresented: $viewModel.isMailSentConfirmationPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your feedback email was sent successfully. We appreciate your input!")
            }
    }
}

// MARK: - View Extension
extension View {
    public func withRatingFeature(viewModel: RatingViewModel = RatingViewModel.shared) -> some View {
        self.modifier(RatingViewModifier(viewModel: viewModel))
    }
}
