//
//  OnboardingStep.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 07/04/2025.
//

import Foundation
import SwiftUI

/// Represents a single step in the onboarding process
public struct OnboardingStep: Identifiable, Equatable {
    /// Unique identifier for the step
    public let id: String
    
    /// Title displayed at the top of the step
    public let title: String
    
    /// Descriptive text explaining the feature or concept
    public let description: String
    
    /// Type of media to display (image, video, or custom view)
    public let mediaType: MediaType
    
    /// Source identifier for the media (image name or video name)
    /// Not used when mediaType is .customView
    public let mediaSource: String
    
    /// Custom SwiftUI view to display when mediaType is .customView
    public let customView: AnyView?
    
    /// Whether this is the final step in the sequence
    public var isLastStep: Bool
    
    /// The current index of this step in the sequence
    public var currentStepIndex: Int
    
    /// The total number of steps in the sequence
    public var totalSteps: Int
    
    
    
    /// Creates a new onboarding step with image or video media
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        mediaType: MediaType,
        mediaSource: String,
        isLastStep: Bool = false,
        currentStepIndex: Int = 0,
        totalSteps: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.mediaType = mediaType
        self.mediaSource = mediaSource
        self.customView = nil
        self.isLastStep = isLastStep
        self.currentStepIndex = currentStepIndex
        self.totalSteps = totalSteps
    }
    
    /// Creates a new onboarding step with a custom SwiftUI view
    public init<V: CustomOnboardingView>(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        customView: V,
        isLastStep: Bool = false,
        currentStepIndex: Int = 0,
        totalSteps: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.mediaType = .customView
        self.mediaSource = ""
        self.customView = AnyView(customView)
        self.isLastStep = isLastStep
        self.currentStepIndex = currentStepIndex
        self.totalSteps = totalSteps
        
    }
    
    public static func == (lhs: OnboardingStep, rhs: OnboardingStep) -> Bool {
        lhs.id == rhs.id
    }
}




/// Defines the type of media to be displayed in an onboarding step
public enum MediaType {
    /// Static image media type
    case image
    /// Video media type for more engaging content
    case video
    /// Custom SwiftUI view for complete customization
    case customView
    
    /// Returns the appropriate view for the media type
//    @ViewBuilder
//    public func view(source: String) -> some View {
//        PhoneFrameView {
//            switch self {
//            case .image:
//                if let uiImage = UIImage(named: source) {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .scaledToFit()
//                        
//                } else {
//                    // Fallback to a gradient background if image is not found
//                    LinearGradient(
//                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                    .overlay(
//                        Image(systemName: "photo")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 80, height: 80)
//                            .foregroundColor(.white.opacity(0.8))
//                    )
//                }
//            case .video:
//                // Use our custom VideoPlayerView for video playback
//                VideoPlayerView(videoName: source, looping: true)
//                    .aspectRatio(contentMode: .fill)
//            }
//        }
//    }
}

/// Sample onboarding steps for the app
public extension OnboardingStep {
    static let sampleSteps: [OnboardingStep] = [
        OnboardingStep(
            id: "welcome",
            title: "Welcome to SuperTuber",
            description: "Your personal YouTube summary assistant that helps you get the most out of your videos.",
            mediaType: .image,
            mediaSource: "onboarding_welcome",
            isLastStep: false,
            currentStepIndex: 0,
            totalSteps: 5
        ),
        OnboardingStep(
            id: "intro",
            title: "Discover SuperTuber",
            description: "SuperTuber helps you save time by providing quick summaries of YouTube videos.",
            mediaType: .video,
            mediaSource: "onboarding_1",
            isLastStep: false,
            currentStepIndex: 1,
            totalSteps: 5
        ),
        OnboardingStep(
            id: "summaries",
            title: "Smart Summaries",
            description: "Get concise summaries of any YouTube video without watching the whole thing.",
            mediaType: .video,
            mediaSource: "onboarding_2",
            isLastStep: false,
            currentStepIndex: 2,
            totalSteps: 5
        ),
        OnboardingStep(
            id: "bookmarks",
            title: "Save Your Favorites",
            description: "Bookmark videos and summaries to access them anytime, even offline.",
            mediaType: .image,
            mediaSource: "onboarding_bookmarks",
            isLastStep: false,
            currentStepIndex: 3,
            totalSteps: 5
        ),
        OnboardingStep(
            id: "getStarted",
            title: "Ready to Get Started?",
            description: "Paste a YouTube link and experience the power of SuperTuber!",
            mediaType: .image,
            mediaSource: "onboarding_getstarted",
            isLastStep: true,
            currentStepIndex: 4,
            totalSteps: 5
        )
    ]
}

/// Sample onboarding steps with video content
public extension OnboardingStep {
    static let videoSampleSteps: [OnboardingStep] = [
        OnboardingStep(
            id: "welcome_video",
            title: "Welcome to the App",
            description: "Experience our app through engaging video tutorials.",
            mediaType: .video,
            mediaSource: "onboarding_1",
            isLastStep: false,
            currentStepIndex: 0,
            totalSteps: 3
        ),
        OnboardingStep(
            id: "feature_video",
            title: "Key Features",
            description: "Watch how our powerful features can help you achieve more.",
            mediaType: .video,
            mediaSource: "onboarding_1", // Using the same video for demonstration
            isLastStep: false,
            currentStepIndex: 1,
            totalSteps: 3
        ),
        OnboardingStep(
            id: "final_video",
            title: "Get Started Now",
            description: "You're all set! Start using our app to its full potential.",
            mediaType: .video,
            mediaSource: "onboarding_1", // Using the same video for demonstration
            isLastStep: true,
            currentStepIndex: 2,
            totalSteps: 3
        )
    ]
}
