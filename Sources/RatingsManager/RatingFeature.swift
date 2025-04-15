//
//  RatingFeature.swift
//  YoutubeSummarizer
//
//  Created by mohamed abd elaleem on 06/04/2025.
//

import Foundation
import SwiftUI
import MessageUI
import UIKit
import EmailSupport

// MARK: - Rating Feature

public class RatingFeature: ObservableObject {
    // MARK: - Published Properties
    @Published public var showPrePromptAlert = false
    @Published public var showFeedbackPrompt = false
    @Published public var showFeedbackConfirmation = false
    
    // MARK: - Dependencies
    private let ratingClient: RatingClient
    private let emailSupportViewModel = EmailSupportViewModel()
    
    // MARK: - Initialization
    public init(ratingClient: RatingClient = RatingClient.shared) {
        self.ratingClient = ratingClient
    }
    
    // MARK: - Public Methods
    public func onAppear() {
        // No initialization needed
    }
    
    public func triggerRating() {
        if ratingClient.shouldPromptForRating() {
            showRatingPrompt()
        }
    }
    
    public func recordSuccessfulAction() {
        ratingClient.recordSuccessfulAction()
        
        // Check if we should show the rating prompt
        if ratingClient.shouldPromptForRating() {
            showRatingPrompt()
        }
    }
    
    public func showRatingPrompt() {
        showPrePromptAlert = true
    }
    
    public func requestReview() {
        showPrePromptAlert = false
        ratingClient.requestReview()
        ratingClient.markAsPrompted()
    }
    
//    public func showFeedbackPrompt() {
//        showPrePromptAlert = false
//        showFeedbackConfirmation = true
//        ratingClient.postponeRating()
//    }
    
    public func showEmailFeedback() {
        showFeedbackConfirmation = false
        emailSupportViewModel.contactSupportTapped()
    }
    
    public func dismissFeedbackPrompt() {
        showFeedbackPrompt = false
    }
    
    public func resetPromptState() {
        ratingClient.resetState()
    }
    
    public func cancelRatingPrompt() {
        showPrePromptAlert = false
        ratingClient.postponeRating()
    }
    
    // MARK: - Email Support Properties
    public var isMailViewPresented: Binding<Bool> {
        Binding(
            get: { self.emailSupportViewModel.isMailViewPresented },
            set: { self.emailSupportViewModel.isMailViewPresented = $0 }
        )
    }
    
    public var isMailUnavailableAlertPresented: Binding<Bool> {
        Binding(
            get: { self.emailSupportViewModel.isMailUnavailableAlertPresented },
            set: { self.emailSupportViewModel.isMailUnavailableAlertPresented = $0 }
        )
    }
    
    public var isMailSentConfirmationPresented: Binding<Bool> {
        Binding(
            get: { self.emailSupportViewModel.isMailSentConfirmationPresented },
            set: { self.emailSupportViewModel.isMailSentConfirmationPresented = $0 }
        )
    }
    
    public func handleMailSent(_ sent: Bool) {
        emailSupportViewModel.handleMailSent(sent)
    }
}

// MARK: - SwiftUI View Modifier

//public struct RatingViewModifier: ViewModifier {
//    @ObservedObject var viewModel: RatingFeature
//    
//    public init(viewModel: RatingFeature) {
//        self.viewModel = viewModel
//    }
//    
//    public func body(content: Content) -> some View {
//        content
//            .alert("Do you enjoy using the app?", isPresented: $viewModel.showPrePromptAlert) {
//                Button("Yes, I love it!") {
//                    viewModel.requestReview()
//                }
//                Button("Not really") {
//                    viewModel.showFeedbackPrompt()
//                }
//                Button("Cancel", role: .cancel) {
//                    viewModel.cancelRatingPrompt()
//                }
//            }
//            // Feedback confirmation alert
//            .alert("We'd love your feedback", isPresented: $viewModel.showFeedbackConfirmation) {
//                Button("Send Feedback") {
//                    viewModel.showEmailFeedback()
//                }
//                Button("Cancel", role: .cancel) {
//                    viewModel.dismissFeedbackPrompt()
//                }
//            } message: {
//                Text("Would you like to send us feedback about what could be improved?")
//            }
//            
//            // Email support integration
//            .sheet(isPresented: viewModel.isMailViewPresented) {
//                MailView(
//                    subject: "SuperTuber Feedback",
//                    body: """
//                    Hello SuperTuber Team,
//                    
//                    I'd like to provide some feedback about the app:
//                    
//                    [Please describe what you don't like or what could be improved]
//                    
//                    ------------------------
//                    \(DeviceInfoHelper.getDeviceInfo())
//                    ------------------------
//                    """,
//                    toRecipients: ["supertuber@smartappsfor.us"],
//                    onDismiss: { sent in
//                        viewModel.handleMailSent(sent)
//                    }
//                )
//            }
//            .alert("Mail Not Configured", isPresented: viewModel.isMailUnavailableAlertPresented) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text("Please configure the Mail app on your device to send feedback emails.")
//            }
//            .alert("Thanks!", isPresented: viewModel.isMailSentConfirmationPresented) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text("Your feedback email was sent successfully. We appreciate your input!")
//            }
//    }
//}

// MARK: - View Extension

//extension View {
//    public func withRatingFeature(_ viewModel: RatingFeature = RatingFeature()) -> some View {
//        self.modifier(RatingViewModifier(viewModel: viewModel))
//    }
//}


