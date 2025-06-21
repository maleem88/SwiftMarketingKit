//
//  PhoneFrameView.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 07/04/2025.
//

import SwiftUI

/// A view that wraps content in an iPhone-style frame for displaying app screenshots or videos
public struct PhoneFrameView<Content: View>: View {
    /// The content to display inside the phone frame
    private let content: Content
    
    // Standard iPhone aspect ratio is approximately 19.5:9
    private let phoneAspectRatio: CGFloat = 19.5/9.0
    
    /// Creates a new phone frame view with the given content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        // Calculate frame size based on screen width and proper iPhone aspect ratio
        let frameWidth = UIScreen.main.bounds.width * 0.85
        let frameHeight = frameWidth * phoneAspectRatio
        
//        ZStack {
            // Simple phone frame with proper iPhone proportions
//            RoundedRectangle(cornerRadius: 25)
//                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
//                .frame(width: frameWidth, height: frameHeight)
//                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
            
            // Content area
//        VStack {
            // Add a frame with fixed width and height to properly constrain content
            content
                .frame(width: frameWidth * 0.96)
                .clipShape(RoundedRectangle(cornerRadius: 45))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 35)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
//        }
            
//        }
//        .padding(.horizontal, 40)
    }
}

#Preview {
    PhoneFrameView {
        Image("onboarding_welcome")
            .resizable()
            .scaledToFit()
//            .frame(height: 650)
            
    }
}
