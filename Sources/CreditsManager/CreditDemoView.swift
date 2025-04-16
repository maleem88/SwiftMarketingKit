//
//  CreditDemoView.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 07/04/2025.
//

import SwiftUI

public struct CreditDemoView: View {
    @ObservedObject var viewModel: CreditDemoViewModel
    @State private var isButtonAnimating = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var showResetAnimation = false
    @State private var pulseEffect = false
    @State private var selectedButton: String? = nil
    
    public init(viewModel: CreditDemoViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Credit Status Card
            CreditStatusView(viewModel: viewModel.creditViewModel)
                .scaleEffect(scale)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: scale)
            
            Divider()
            
            // Demo Actions
            VStack(spacing: 16) {
                Text("try_credit_system")
                    .font(.headline)
                
                Button {
                    withAnimation(.spring()) {
                        selectedButton = "summarize"
                        scale = 0.95
                        viewModel.summarizeVideo()
                        
                        // Reset scale after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                scale = 1.0
                                selectedButton = nil
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "text.bubble")
//                            .symbolEffect(.bounce, options: .repeating, value: selectedButton == "summarize")
                        Text("Summarize Video (20 Credits)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedButton == "summarize" ? Color.blue.opacity(0.7) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .scaleEffect(selectedButton == "summarize" ? 0.98 : 1.0)
                    .shadow(color: selectedButton == "summarize" ? Color.blue.opacity(0.5) : Color.clear, radius: 5)
                }
                .disabled(viewModel.creditViewModel.remainingCredits < 20)
                
                Button {
                    withAnimation(.spring()) {
                        selectedButton = "transcript"
                        scale = 0.95
                        viewModel.generateTranscript()
                        
                        // Reset scale after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                scale = 1.0
                                selectedButton = nil
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
//                            .symbolEffect(.bounce, options: .repeating, value: selectedButton == "transcript")
                        Text("Generate Transcript (10 Credits)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedButton == "transcript" ? Color.purple.opacity(0.7) : Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .scaleEffect(selectedButton == "transcript" ? 0.98 : 1.0)
                    .shadow(color: selectedButton == "transcript" ? Color.purple.opacity(0.5) : Color.clear, radius: 5)
                }
                .disabled(viewModel.creditViewModel.remainingCredits < 10)
                
                Button {
                    withAnimation(.spring()) {
                        selectedButton = "refresh"
                        rotation += 360
                        viewModel.creditViewModel.refreshCreditStatus()
                        
                        // Reset after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                selectedButton = nil
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(selectedButton == "refresh" ? 360 : 0))
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: selectedButton == "refresh")
                        Text("Refresh Credit Status")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedButton == "refresh" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedButton == "refresh" ? Color.blue : Color.clear, lineWidth: 2)
                    )
                }
                
                Button {
                    withAnimation(.spring()) {
                        selectedButton = "reset"
                        showResetAnimation = true
                        pulseEffect = true
                        viewModel.creditViewModel.resetCredits()
                        
                        // Hide the animation after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation {
                                showResetAnimation = false
                                selectedButton = nil
                            }
                        }
                        
                        // Reset pulse effect
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            pulseEffect = false
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
//                            .symbolEffect(.bounce, options: .repeating, value: selectedButton == "reset")
                        Text("Reset Credits")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedButton == "reset" ? Color.red.opacity(0.3) : Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: selectedButton == "reset" ? 2 : 0)
                    )
                    .overlay(
                        Group {
                            if showResetAnimation {
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(.red)
                                    .scaleEffect(showResetAnimation ? 2 : 0.5)
                                    .opacity(showResetAnimation ? 0 : 1)
                                    .animation(.easeOut(duration: 1.0), value: showResetAnimation)
                            }
                        }
                    )
                }
            }
            
            Spacer()
            
            NavigationLink {
                CreditView(viewModel: viewModel.creditViewModel)
            } label: {
                Text("View Credit Details")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            .padding(.bottom)
            .scaleEffect(pulseEffect ? 1.05 : 1.0)
            .animation(pulseEffect ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: pulseEffect)
        }
        .padding()
        .navigationTitle("Credit System Demo")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            // Start animations when view appears
            withAnimation {
                isButtonAnimating = true
            }
        }
        .onAppear {
            viewModel.creditViewModel.onAppear()
        }
    }
}

#Preview {
    NavigationStack {
        CreditDemoView(viewModel: .init())
    }
}
