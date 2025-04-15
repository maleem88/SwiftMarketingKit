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
    
    /// Type of media to display (image or video)
    public let mediaType: MediaType
    
    /// Source identifier for the media (image name or video name)
    public let mediaSource: String
    
    /// Whether this is the final step in the sequence
    public let isLastStep: Bool
    
    /// The current index of this step in the sequence
    public let currentStepIndex: Int
    
    /// The total number of steps in the sequence
    public let totalSteps: Int
    
    /// Creates a new onboarding step
    public init(id: String, title: String, description: String, mediaType: MediaType, mediaSource: String, isLastStep: Bool, currentStepIndex: Int, totalSteps: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.mediaType = mediaType
        self.mediaSource = mediaSource
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
    
    /// Returns the appropriate view for the media type
    @ViewBuilder
    public func view(source: String) -> some View {
        PhoneFrameView {
            switch self {
            case .image:
                if let uiImage = UIImage(named: source) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        
                } else {
                    // Fallback to a gradient background if image is not found
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white.opacity(0.8))
                    )
                }
            case .video:
                // Use our custom VideoPlayerView for video playback
                VideoPlayerView(videoName: source, looping: true)
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
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
            mediaType: .image,
            mediaSource: "onboarding_welcome",
            isLastStep: false,
            currentStepIndex: 1,
            totalSteps: 5
        ),
        OnboardingStep(
            id: "summaries",
            title: "Smart Summaries",
            description: "Get concise summaries of any YouTube video without watching the whole thing.",
            mediaType: .image,
            mediaSource: "onboarding_summaries",
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
