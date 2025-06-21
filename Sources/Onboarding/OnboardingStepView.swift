//
//  OnboardingStepView.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 07/04/2025.
//

import SwiftUI

/// A view that displays a single step in the onboarding process
public struct OnboardingStepView: View {
    // MARK: - Required Properties
    /// The onboarding step to display
    public let step: OnboardingStep
    /// Whether this is the first step in the sequence
    public let isFirstStep: Bool
    /// Action to perform when the next button is tapped
    public let onNext: () -> Void
    /// Action to perform when the previous button is tapped
    public let onPrevious: () -> Void
    /// Action to perform when the skip button is tapped
    public let onSkip: () -> Void
    
    // MARK: - Customization Properties
    /// Primary color for buttons and highlights
    public let primaryColor: Color
    /// Secondary color for inactive elements
    public let secondaryColor: Color
    /// Font for titles
    public let titleFont: Font
    /// Font for descriptions
    public let descriptionFont: Font
    /// Font for buttons
    public let buttonFont: Font
    /// Text for the next button
    public let nextButtonText: String
    /// Text for the previous button
    public let previousButtonText: String
    /// Text for the skip button
    public let skipButtonText: String
    /// Text for the get started button (on last step)
    public let getStartedButtonText: String
    /// Whether to show the skip button
    public let showSkipButton: Bool
    /// Whether to show the progress indicator
    public let showProgressIndicator: Bool
    /// Style of the progress indicator
    public let progressIndicatorStyle: OnboardingManagerConfig.ProgressIndicatorStyle
    /// Style of the text overlay
    public let textOverlayStyle: OnboardingManagerConfig.TextOverlayStyle
    /// Whether to enable swipe navigation
    public let enableSwipeNavigation: Bool
    
    /// Creates a new onboarding step view with default styling
    public init(
        step: OnboardingStep, 
        isFirstStep: Bool, 
        onNext: @escaping () -> Void, 
        onPrevious: @escaping () -> Void, 
        onSkip: @escaping () -> Void
    ) {
        self.step = step
        self.isFirstStep = isFirstStep
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.onSkip = onSkip
        
        // Default values
        self.primaryColor = .blue
        self.secondaryColor = .gray
        self.titleFont = .title2
        self.descriptionFont = .body
        self.buttonFont = .headline
        self.nextButtonText = "Next"
        self.previousButtonText = "Back"
        self.skipButtonText = "Skip"
        self.getStartedButtonText = "Get Started"
        self.showSkipButton = true
        self.showProgressIndicator = true
        self.progressIndicatorStyle = .dots
        self.textOverlayStyle = .standard
        self.enableSwipeNavigation = true
    }
    
    /// Creates a new onboarding step view with custom styling
    public init(
        step: OnboardingStep, 
        isFirstStep: Bool, 
        onNext: @escaping () -> Void, 
        onPrevious: @escaping () -> Void, 
        onSkip: @escaping () -> Void,
        primaryColor: Color = .blue,
        secondaryColor: Color = .gray,
        titleFont: Font = .title2,
        descriptionFont: Font = .body,
        buttonFont: Font = .headline,
        nextButtonText: String = "Next",
        previousButtonText: String = "Back",
        skipButtonText: String = "Skip",
        getStartedButtonText: String = "Get Started",
        showSkipButton: Bool = true,
        showProgressIndicator: Bool = true,
        progressIndicatorStyle: OnboardingManagerConfig.ProgressIndicatorStyle = .dots,
        textOverlayStyle: OnboardingManagerConfig.TextOverlayStyle = .standard,
        enableSwipeNavigation: Bool = true
    ) {
        self.step = step
        self.isFirstStep = isFirstStep
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.onSkip = onSkip
        
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.titleFont = titleFont
        self.descriptionFont = descriptionFont
        self.buttonFont = buttonFont
        self.nextButtonText = nextButtonText
        self.previousButtonText = previousButtonText
        self.skipButtonText = skipButtonText
        self.getStartedButtonText = getStartedButtonText
        self.showSkipButton = showSkipButton
        self.showProgressIndicator = showProgressIndicator
        self.progressIndicatorStyle = progressIndicatorStyle
        self.textOverlayStyle = textOverlayStyle
        self.enableSwipeNavigation = enableSwipeNavigation
    }
    
    public var body: some View {
        ZStack {
            // Background is transparent to allow parent view to set the background
            Color.clear
                .ignoresSafeArea()
            
            VStack {
                
                
                HStack(alignment: .top) {
                    if textOverlayStyle == .minimal {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.title)
                                .font(titleFont.bold())
                            //                            .foregroundColor(.white)
//                                .multilineTextAlignment(.leading)
//                                .lineLimit(3)
                            
                            
                            Text(step.description)
                                .font(descriptionFont)
                            //                            .foregroundColor(.white.opacity(0.9))
//                                .multilineTextAlignment(.leading)
//                                                        .lineLimit(3)
                        }
//                        .padding(.horizontal, 5)
                    }
                    
                    Spacer()
                    
                    if showSkipButton {
                        Button(action: onSkip) {
                            Text(skipButtonText)
                                .font(buttonFont)
                                .fontWeight(.medium)
                                .foregroundColor(textOverlayStyle == .standard ? .white : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(textOverlayStyle == .minimal ? Color.black.opacity(0.3) : Color.clear)
                                .cornerRadius(16)
                        }
                    }
                    
                }
                .padding()
                
                
                PhoneFrameView {
                    switch step.mediaType {
                    case .image:
                        if let uiImage = UIImage(named: step.mediaSource) {
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
                        VideoPlayerView(videoName: step.mediaSource, looping: true)
                            .aspectRatio(contentMode: .fill)
                    }
                }
                
            }
            
//
//            // Use the MediaType.view method to display the appropriate media
//            step.mediaType.view(source: step.mediaSource)
//            
//            // Phone frame positioned to extend below text area
                
//                .offset(y: -UIScreen.main.bounds.height * 0.05) // Move phone frame up slightly
            
            // Gradient overlay for text area - only shown in standard style
            if textOverlayStyle == .standard {
                VStack {
                    Spacer()
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0), location: 0),
                            .init(color: Color.black.opacity(0.7), location: 0.3),
                            .init(color: Color.black.opacity(0.9), location: 0.6),
                            .init(color: Color.black.opacity(1), location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: UIScreen.main.bounds.height * 0.4) // Text area height
                }
                .ignoresSafeArea()
            }
            
            // Content overlay positioned absolutely
            VStack(spacing: 0) {
                
                Spacer()
                            
                // Bottom content area with text and controls
                VStack(spacing: 16) {
                    if textOverlayStyle == .standard {
                        Spacer()
                    }
                    
                    // Progress indicator
                    if showProgressIndicator {
                        Group {
                            switch progressIndicatorStyle {
                            case .dots:
                                // Dots style
                                HStack(spacing: 8) {
                                    ForEach(0..<step.totalSteps, id: \.self) { index in
                                        Circle()
                                            .fill(index == step.currentStepIndex ? Color.white : Color.white.opacity(0.4))
                                            .frame(width: 8, height: 8)
                                            .scaleEffect(index == step.currentStepIndex ? 1.2 : 1.0)
                                            .animation(.spring(), value: step.currentStepIndex)
                                    }
                                }
                            case .bar:
                                // Progress bar style
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(height: 4)
                                            .cornerRadius(2)
                                        
                                        Rectangle()
                                            .fill(Color.white)
                                            .frame(width: geometry.size.width * CGFloat(step.currentStepIndex + 1) / CGFloat(step.totalSteps), height: 4)
                                            .cornerRadius(2)
                                    }
                                }
                                .frame(height: 4)
                                .padding(.horizontal)
                            case .numbers:
                                // Numeric style
                                Text("\(step.currentStepIndex + 1)/\(step.totalSteps)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            case .none:
                                EmptyView()
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    
                    // Title and description - only shown in standard style
                    if textOverlayStyle == .standard {
                        VStack(spacing: 12) {
                            Text(step.title)
                                .font(titleFont)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                            
                            Text(step.description)
                                .font(descriptionFont)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 24)
                    }
                    
                    // Navigation buttons in a single row
                    HStack {
                        // Left side: Previous button (hidden on first step)
                        if !isFirstStep {
                            Button(action: onPrevious) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text(previousButtonText)
                                }
                                .font(buttonFont)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    textOverlayStyle == .minimal ? 
                                        Capsule().fill(Color.black.opacity(0.6)) : 
                                        Capsule().fill(Color.black.opacity(0.3))
                                )
                            }
                        }
                        
                        Spacer()
                        
                        // Right side: Next/Get Started button
                        Button(action: onNext) {
                            HStack(spacing: 8) {
                                Text(step.isLastStep ? getStartedButtonText : nextButtonText)
                                Image(systemName: step.isLastStep ? "arrow.right.circle.fill" : "chevron.right")
                                    .font(.system(size: 18))
                            }
                            .font(buttonFont)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, textOverlayStyle == .minimal ? 16 : 20)
                }
                .frame(maxWidth: .infinity)
                
            }
//            .padding(.vertical)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            enableSwipeNavigation ? 
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 0 && !isFirstStep {
                        // Right swipe - go back
                        onPrevious()
                    } else if value.translation.width < 0 {
                        // Left swipe - go forward
                        onNext()
                    }
                } : nil
        )
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        
        OnboardingStepView(
            step: OnboardingStep(
                id: "welcome",
                title: "Welcome to SuperTuber",
                description: "Your personal YouTube summary assistant that helps you get the most out of your videos.",
                mediaType: .image,
                mediaSource: "onboarding_welcome",
                isLastStep: false,
                currentStepIndex: 0,
                totalSteps: 4
            ),
            isFirstStep: true,
            onNext: {},
            onPrevious: {},
            onSkip: {},
            primaryColor: .blue,
//            progressIndicatorStyle: .bar,
            textOverlayStyle: .minimal
        )
    }
}
