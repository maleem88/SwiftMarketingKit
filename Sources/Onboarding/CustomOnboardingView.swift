//
//  CustomOnboardingView.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 09/07/2025.
//

import SwiftUI

/// Protocol that custom views must conform to in order to be used in the onboarding flow
public protocol CustomOnboardingView: View {
    /// Called when the view appears in the onboarding flow
    func onAppear()
    
    /// Called when the view disappears from the onboarding flow
    func onDisappear()
    
    /// Indicates if the view is ready to proceed to the next step
    /// This could be used for views that need to complete an animation or interaction
    /// before allowing navigation
    var isReadyForNavigation: Bool { get }
}

/// Default implementations for the CustomOnboardingView protocol
public extension CustomOnboardingView {
    func onAppear() {}
    func onDisappear() {}
    var isReadyForNavigation: Bool { true }
}
