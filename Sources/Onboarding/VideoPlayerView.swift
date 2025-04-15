//
//  VideoPlayerView.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 07/04/2025.
//

import SwiftUI
import AVKit

/// A SwiftUI view that plays video content from the app bundle
public struct VideoPlayerView: UIViewControllerRepresentable {
    /// Name of the video file in the app bundle (without extension)
    public let videoName: String
    /// Whether the video should loop continuously
    public let looping: Bool
    
    /// Creates a new video player view
    public init(videoName: String, looping: Bool = true) {
        self.videoName = videoName
        self.looping = looping
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        // Find the video in the app bundle
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("Error: Could not find video file named \(videoName)")
            return controller
        }
        
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        
        // Configure player
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect // Changed to resizeAspect to maintain aspect ratio
        
        // Set up looping if needed
        if looping {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }
        
        // Start playback
        player.play()
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Restart playback when view is updated
        if let player = uiViewController.player, player.rate == 0 {
            player.seek(to: .zero)
            player.play()
        }
    }
    
    public static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        uiViewController.player?.pause()
    }
}
