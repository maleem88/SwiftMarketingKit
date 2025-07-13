//
//  VideoPlayerView.swift
//  SwiftMarketingKit
//
//  Created by Cascade on 07/04/2025.
//

import SwiftUI
import AVKit
import Combine

/// A SwiftUI view that plays video content from the app bundle
public struct VideoPlayerView: UIViewControllerRepresentable {
    /// Name of the video file in the app bundle (without extension)
    public let videoName: String
    /// Whether the video should loop continuously
    public let looping: Bool
    /// The aspect ratio of the video content (width / height)
    @Binding public var videoAspectRatio: CGFloat
    
    /// Creates a new video player view
    public init(videoName: String, looping: Bool = true, videoAspectRatio: Binding<CGFloat> = .constant(0)) {
        self.videoName = videoName
        self.looping = looping
        self._videoAspectRatio = videoAspectRatio
    }
    
    // Coordinator to track state between updates
    public class Coordinator: NSObject {
        var lastVideoName: String = ""
        weak var currentPlayer: AVPlayer?
        var videoAspectRatioBinding: Binding<CGFloat>?
        var cancellables = Set<AnyCancellable>()
        
        @objc func playerItemDidReachEnd(_ notification: Notification) {
            // Simply seek back to the beginning and play again
            currentPlayer?.seek(to: .zero)
            currentPlayer?.play()
        }
        
        deinit {
            // Clean up notification observers when coordinator is deallocated
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.videoAspectRatioBinding = $videoAspectRatio
        return coordinator
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        // Add observer for when onboarding view is dismissed
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("OnboardingViewDismissed"),
            object: nil,
            queue: .main
        ) { [weak controller] _ in
            // Clean up resources when onboarding view is dismissed
            guard let controller = controller else { return }
            if let player = controller.player {
                player.pause()
                player.replaceCurrentItem(with: nil)
            }
        }
        
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
        controller.videoGravity = .resizeAspect // Use resizeAspect to maintain the correct aspect ratio
        
        // Get the video's natural size when the item is ready to play
        player.currentItem?.publisher(for: \.status)
            .filter { $0 == .readyToPlay }
            .sink { _ in
                if let item = player.currentItem, let track = item.asset.tracks(withMediaType: .video).first {
                    let size = track.naturalSize.applying(track.preferredTransform)
                    let aspectRatio = abs(size.width / size.height)
                    DispatchQueue.main.async {
                        context.coordinator.videoAspectRatioBinding?.wrappedValue = aspectRatio
                    }
                }
            }
            .store(in: &context.coordinator.cancellables)
        
        // Store the player in the coordinator for looping
        context.coordinator.currentPlayer = player
        
        // Set up looping if needed
        if looping {
            NotificationCenter.default.addObserver(
                context.coordinator,
                selector: #selector(Coordinator.playerItemDidReachEnd(_:)),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        }
        
        // Start playback
        player.play()
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Check if the video name has changed (stored in context)
        let previousVideoName = context.coordinator.lastVideoName
        
        // If the video name changed, we need to update the player with the new video
        if previousVideoName != videoName {
            // Clean up previous player resources
            if let oldPlayer = uiViewController.player {
                // Pause and remove current item
                oldPlayer.pause()
                oldPlayer.replaceCurrentItem(with: nil)
                
                // Remove existing notification observers
                NotificationCenter.default.removeObserver(context.coordinator)
            }
            
            // Find the video in the app bundle
            guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
                print("Error: Could not find video file named \(videoName)")
                return
            }
            
            // Create a new player with the new video
            let url = URL(fileURLWithPath: path)
            let player = AVPlayer(url: url)
            
            // Configure player
            uiViewController.player = player
            uiViewController.showsPlaybackControls = false
            uiViewController.videoGravity = .resizeAspect // Use resizeAspect to maintain the correct aspect ratio
            
            // Get the video's natural size when the item is ready to play
            if let currentItem = player.currentItem {
                // First check if the item is already ready to play
                if currentItem.status == .readyToPlay, let track = currentItem.asset.tracks(withMediaType: .video).first {
                    let size = track.naturalSize.applying(track.preferredTransform)
                    let aspectRatio = abs(size.width / size.height)
                    DispatchQueue.main.async {
                        context.coordinator.videoAspectRatioBinding?.wrappedValue = aspectRatio
                    }
                } else {
                    // Otherwise set up the publisher to listen for status changes
                    currentItem.publisher(for: \.status)
                        .filter { $0 == .readyToPlay }
                        .sink { [weak player] _ in
                            guard let player = player, let item = player.currentItem else { return }
                            if let track = item.asset.tracks(withMediaType: .video).first {
                                let size = track.naturalSize.applying(track.preferredTransform)
                                let aspectRatio = abs(size.width / size.height)
                                DispatchQueue.main.async {
                                    context.coordinator.videoAspectRatioBinding?.wrappedValue = aspectRatio
                                }
                            }
                        }
                        .store(in: &context.coordinator.cancellables)
                }
            }
            
            // Store the player in the coordinator for looping
            context.coordinator.currentPlayer = player
            
            // Set up looping if needed
            if looping {
                NotificationCenter.default.addObserver(
                    context.coordinator,
                    selector: #selector(Coordinator.playerItemDidReachEnd(_:)),
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem
                )
            }
            
            // Start playback
            player.play()
            
            // Update the stored video name
            context.coordinator.lastVideoName = videoName
        } else if let player = uiViewController.player, player.rate == 0 {
            // If it's the same video but not playing, restart it
            player.seek(to: .zero)
            player.play()
        }
    }
    
    public func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        // Clean up resources when view is dismantled
        if let player = uiViewController.player {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
        
        // Remove notification observers
        NotificationCenter.default.removeObserver(coordinator)
        
        // Cancel all subscriptions
        coordinator.cancellables.removeAll()
    }
}
