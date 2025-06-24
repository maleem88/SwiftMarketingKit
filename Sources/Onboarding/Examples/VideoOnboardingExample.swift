import SwiftUI

/// Example implementation of video-based onboarding
public struct VideoOnboardingExample: View {
    // State to track whether onboarding should be shown
    @State private var showOnboarding = true
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Main app content
            VStack {
                Text("Main App Content")
                    .font(.largeTitle)
                    .padding()
                
                Button("Show Onboarding Again") {
                    showOnboarding = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Show onboarding as a full-screen cover when needed
            .fullScreenCover(isPresented: $showOnboarding) {
                VideoOnboardingView(onDismiss: {
                    showOnboarding = false
                    // In a real app, you would also call:
                    // OnboardingManager.setOnboardingCompleted()
                })
            }
        }
    }
}

/// The actual onboarding view that displays video steps
struct VideoOnboardingView: View {
    // Callback for when onboarding is dismissed
    let onDismiss: () -> Void
    
    // Current step index
    @State private var currentIndex = 0
    
    // Get the video sample steps from the config
    private let steps = OnboardingManagerConfig.shared.getVideoSampleSteps()
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            // Current onboarding step view
            // Use an id modifier to force SwiftUI to recreate the view when the step changes
            OnboardingStepView(
                step: steps[currentIndex],
                isFirstStep: currentIndex == 0,
                onNext: {
                    if currentIndex < steps.count - 1 {
                        withAnimation {
                            currentIndex += 1
                        }
                    } else {
                        // Last step, dismiss onboarding
                        onDismiss()
                    }
                },
                onPrevious: {
                    withAnimation {
                        if currentIndex > 0 {
                            currentIndex -= 1
                        }
                    }
                },
                onSkip: {
                    // Skip the entire onboarding
                    onDismiss()
                },
                onDidFinish: {
                    onDismiss()
                },
                // Customize the appearance
                primaryColor: .blue,
                secondaryColor: .gray.opacity(0.7),
                titleFont: .title.bold(),
                descriptionFont: .body,
                buttonFont: .headline,
                progressIndicatorStyle: .bar
            )
            // This id modifier is crucial for forcing SwiftUI to recreate the view
            // when navigating between steps with videos
            .id("step_\(currentIndex)_\(steps[currentIndex].id)")
        }
    }
}

// Preview provider for SwiftUI canvas
struct VideoOnboardingExample_Previews: PreviewProvider {
    static var previews: some View {
        VideoOnboardingExample()
    }
}
