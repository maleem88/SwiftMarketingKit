import Foundation
import SwiftUI

/// Configuration class for customizing the Onboarding experience
public class OnboardingManagerConfig {
    // MARK: - Singleton
    public static let shared = OnboardingManagerConfig()
    
    // MARK: - Properties
    
    // UserDefaults keys
    private var hasCompletedOnboardingKey: String = "com.onboarding.hasCompletedOnboarding"
    private var alwaysShowOnboardingKey: String = "com.onboarding.alwaysShowOnboarding"
    
    // Visual customization
    private var backgroundColor: Color = Color(UIColor.systemBackground)
    private var primaryColor: Color = .blue
    private var secondaryColor: Color = .gray
    private var titleFont: Font = .title
    private var descriptionFont: Font = .headline
    private var buttonFont: Font = .headline
    private var progressIndicatorStyle: ProgressIndicatorStyle = .dots
    private var phoneFrameEnabled: Bool = true
    
    // Button text
    private var nextButtonText: String = "Next"
    private var previousButtonText: String = "Back"
    private var skipButtonText: String = "Skip"
    private var getStartedButtonText: String = "Get Started"
    
    // Behavioral options
    private var showSkipButton: Bool = true
    private var showProgressIndicator: Bool = true
    private var enableSwipeNavigation: Bool = true
    private var autoPlayVideos: Bool = true
    private var textOverlayStyle: TextOverlayStyle = .minimal
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Progress Indicator Style
    public enum ProgressIndicatorStyle {
        case dots
        case bar
        case numbers
        case none
    }
    
    // MARK: - Text Overlay Style
    public enum TextOverlayStyle {
        case standard
        case minimal
        case cropped
    }
    
    // MARK: - Public Configuration Methods
    
    /// Set custom UserDefaults keys for onboarding persistence
    /// - Parameters:
    ///   - completedKey: Key for storing completion status
    ///   - alwaysShowKey: Key for storing always show setting
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setUserDefaultsKeys(completedKey: String, alwaysShowKey: String) -> Self {
        self.hasCompletedOnboardingKey = completedKey
        self.alwaysShowOnboardingKey = alwaysShowKey
        return self
    }
    
    /// Set the background color for onboarding screens
    /// - Parameter color: The background color
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setBackgroundColor(_ color: Color) -> Self {
        self.backgroundColor = color
        return self
    }
    
    @discardableResult
    public func setTextOverlayStyle(_ style: TextOverlayStyle) -> Self {
        self.textOverlayStyle = style
        return self
    }
    
    /// Set the primary color for buttons and highlights
    /// - Parameter color: The primary color
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setPrimaryColor(_ color: Color) -> Self {
        self.primaryColor = color
        return self
    }
    
    /// Set the secondary color for inactive elements
    /// - Parameter color: The secondary color
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setSecondaryColor(_ color: Color) -> Self {
        self.secondaryColor = color
        return self
    }
    
    /// Set the font for titles
    /// - Parameter font: The title font
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setTitleFont(_ font: Font) -> Self {
        self.titleFont = font
        return self
    }
    
    /// Set the font for descriptions
    /// - Parameter font: The description font
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setDescriptionFont(_ font: Font) -> Self {
        self.descriptionFont = font
        return self
    }
    
    /// Set the font for buttons
    /// - Parameter font: The button font
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setButtonFont(_ font: Font) -> Self {
        self.buttonFont = font
        return self
    }
    
    /// Set the progress indicator style
    /// - Parameter style: The progress indicator style
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setProgressIndicatorStyle(_ style: ProgressIndicatorStyle) -> Self {
        self.progressIndicatorStyle = style
        return self
    }
    
    /// Set whether to show the phone frame around media
    /// - Parameter enabled: Whether to show the phone frame
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setPhoneFrameEnabled(_ enabled: Bool) -> Self {
        self.phoneFrameEnabled = enabled
        return self
    }
    
    /// Set the text for navigation buttons
    /// - Parameters:
    ///   - next: Text for the next button
    ///   - previous: Text for the previous button
    ///   - skip: Text for the skip button
    ///   - getStarted: Text for the get started button (on last step)
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setButtonText(next: String, previous: String, skip: String, getStarted: String) -> Self {
        self.nextButtonText = next
        self.previousButtonText = previous
        self.skipButtonText = skip
        self.getStartedButtonText = getStarted
        return self
    }
    
    /// Set whether to show the skip button
    /// - Parameter show: Whether to show the skip button
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setShowSkipButton(_ show: Bool) -> Self {
        self.showSkipButton = show
        return self
    }
    
    /// Set whether to show the progress indicator
    /// - Parameter show: Whether to show the progress indicator
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setShowProgressIndicator(_ show: Bool) -> Self {
        self.showProgressIndicator = show
        return self
    }
    
    /// Set whether to enable swipe navigation
    /// - Parameter enable: Whether to enable swipe navigation
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setEnableSwipeNavigation(_ enable: Bool) -> Self {
        self.enableSwipeNavigation = enable
        return self
    }
    
    /// Set whether to auto-play videos
    /// - Parameter autoPlay: Whether to auto-play videos
    /// - Returns: The config instance for chaining
    @discardableResult
    public func setAutoPlayVideos(_ autoPlay: Bool) -> Self {
        self.autoPlayVideos = autoPlay
        return self
    }
    
    // MARK: - Helper Methods for Creating Steps
    
    /// Create a custom onboarding step
    /// - Parameters:
    ///   - id: Unique identifier for the step
    ///   - title: Title for the step
    ///   - description: Description text for the step
    ///   - mediaType: Type of media (image or video)
    ///   - mediaSource: Source name for the media
    ///   - isLastStep: Whether this is the last step
    ///   - currentStepIndex: Current index of this step
    ///   - totalSteps: Total number of steps
    /// - Returns: A configured OnboardingStep
    public func createStep(
        id: String,
        title: String,
        description: String,
        mediaType: MediaType,
        mediaSource: String,
        isLastStep: Bool,
        currentStepIndex: Int,
        totalSteps: Int
    ) -> OnboardingStep {
        return OnboardingStep(
            id: id,
            title: title,
            description: description,
            mediaType: mediaType,
            mediaSource: mediaSource,
            isLastStep: isLastStep,
            currentStepIndex: currentStepIndex,
            totalSteps: totalSteps
        )
    }
    
    /// Create a series of onboarding steps
    /// - Parameter stepData: Array of tuples containing (id, title, description, mediaType, mediaSource)
    /// - Returns: Array of configured OnboardingStep objects
    public func createSteps(stepData: [(id: String, title: String, description: String, mediaType: MediaType, mediaSource: String)]) -> [OnboardingStep] {
        let totalSteps = stepData.count
        
        return stepData.enumerated().map { index, data in
            let isLastStep = index == totalSteps - 1
            return createStep(
                id: data.id,
                title: data.title,
                description: data.description,
                mediaType: data.mediaType,
                mediaSource: data.mediaSource,
                isLastStep: isLastStep,
                currentStepIndex: index,
                totalSteps: totalSteps
            )
        }
    }
    
    // MARK: - Internal Getters
    
    func getHasCompletedOnboardingKey() -> String {
        return hasCompletedOnboardingKey
    }
    
    func getAlwaysShowOnboardingKey() -> String {
        return alwaysShowOnboardingKey
    }
    
    func getBackgroundColor() -> Color {
        return backgroundColor
    }
    
    func getPrimaryColor() -> Color {
        return primaryColor
    }
    
    func getSecondaryColor() -> Color {
        return secondaryColor
    }
    
    func getTitleFont() -> Font {
        return titleFont
    }
    
    func getDescriptionFont() -> Font {
        return descriptionFont
    }
    
    func getButtonFont() -> Font {
        return buttonFont
    }
    
    func getProgressIndicatorStyle() -> ProgressIndicatorStyle {
        return progressIndicatorStyle
    }
    
    func getTextOverlayStyle() -> TextOverlayStyle {
        return textOverlayStyle
    }
    
    func isPhoneFrameEnabled() -> Bool {
        return phoneFrameEnabled
    }
    
    func getNextButtonText() -> String {
        return nextButtonText
    }
    
    func getPreviousButtonText() -> String {
        return previousButtonText
    }
    
    func getSkipButtonText() -> String {
        return skipButtonText
    }
    
    func getGetStartedButtonText() -> String {
        return getStartedButtonText
    }
    
    func shouldShowSkipButton() -> Bool {
        return showSkipButton
    }
    
    func shouldShowProgressIndicator() -> Bool {
        return showProgressIndicator
    }
    
    func isSwipeNavigationEnabled() -> Bool {
        return enableSwipeNavigation
    }
    
    func shouldAutoPlayVideos() -> Bool {
        return autoPlayVideos
    }
    
    // MARK: - Convenience Methods for Sample Steps
    
    /// Get a sample onboarding flow with video content
    /// - Returns: Array of onboarding steps with video content
    public func getVideoSampleSteps() -> [OnboardingStep] {
        return OnboardingStep.videoSampleSteps
    }
}
