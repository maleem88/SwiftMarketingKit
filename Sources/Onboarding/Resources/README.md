# Onboarding Resources

Place your onboarding images and videos in this directory. The resources should be referenced in your OnboardingStep instances using the `mediaSource` parameter.

## Recommended Image Sizes

- Onboarding images: 1080x1920px (9:16 ratio)
- Icons: 256x256px

## Example Usage

```swift
OnboardingStep(
    id: "welcome",
    title: "Welcome to Your App",
    description: "Your amazing app description here.",
    mediaType: .image,
    mediaSource: "onboarding_welcome", // This should match your resource name
    isLastStep: false,
    currentStepIndex: 0,
    totalSteps: 3
)
```
