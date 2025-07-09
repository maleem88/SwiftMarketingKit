//
//  CustomViewWrapper.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 09/07/2025.
//

import SwiftUI

/// A wrapper that allows any SwiftUI view to be used in the onboarding flow
public struct CustomViewWrapper<Content: View>: CustomOnboardingView {
    /// The wrapped content
    private let content: Content
    
    /// Creates a new wrapper for a custom view
    public init(content: Content) {
        self.content = content
    }
    
    /// The body of the view
    public var body: some View {
        content
    }
}
