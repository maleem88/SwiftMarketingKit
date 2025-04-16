//
//  Examples.swift
//  SwiftMarketingKit
//
//  Created by mohamed abd elaleem on 15/04/2025.
//

import SwiftUI

/// Examples of how to use the CreditsManager module in different scenarios
public struct CreditsExamples {
    
    /// Example 1: Basic Credit Status View
    public struct BasicCreditStatusExample: View {
        @StateObject private var viewModel = CreditViewModel()
        
        public init() {}
        
        public var body: some View {
            VStack(spacing: 20) {
                Text("Basic Credit Status")
                    .font(.title)
                    .fontWeight(.bold)
                
                CreditStatusView(viewModel: viewModel)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }
            .padding()
        }
    }
    
    /// Example 2: Full Credit View with Navigation
    public struct FullCreditViewExample: View {
        @StateObject private var viewModel = CreditViewModel()
        
        public init() {}
        
        public var body: some View {
            NavigationView {
                CreditView(viewModel: viewModel)
            }
        }
    }
    
    /// Example 3: Credit Demo with Navigation and Animations
    public struct CreditDemoExample: View {
        @StateObject private var viewModel = CreditDemoViewModel()
        @State private var isAnimating = false
        @State private var showConfetti = false
        
        public init() {}
        
        public var body: some View {
            NavigationView {
                ZStack {
                    // Background with animated gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                        startPoint: isAnimating ? .topLeading : .bottomTrailing,
                        endPoint: isAnimating ? .bottomTrailing : .topLeading
                    )
                    .ignoresSafeArea()
                    .animation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // Confetti effect when credits are reset
                    if showConfetti {
                        ConfettiView()
                            .ignoresSafeArea()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showConfetti = false
                                }
                            }
                    }
                    
                    // Main content with animations
                    VStack {
                        CreditDemoView(viewModel: viewModel)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(), value: isAnimating)
                    }
                }
                .onAppear {
                    isAnimating = true
                }
                .onReceive(viewModel.creditViewModel.$remainingCredits) { newValue in
                    // Store previous value to compare
                    if let oldValue = UserDefaults.standard.value(forKey: "previousCreditsCount") as? Int,
                       oldValue < newValue {
                        // Credits were reset or increased
                        showConfetti = true
                    }
                    // Save current value for next comparison
                    UserDefaults.standard.set(newValue, forKey: "previousCreditsCount")
                }
            }
        }
        
        // Confetti animation view
        private struct ConfettiView: View {
            @State private var particles = (0..<100).map { _ in ConfettiParticle() }
            
            var body: some View {
                ZStack {
                    ForEach(particles.indices, id: \.self) { index in
                        Circle()
                            .fill(particles[index].color)
                            .frame(width: particles[index].size, height: particles[index].size)
                            .position(particles[index].position)
                            .opacity(particles[index].opacity)
                    }
                }
                .onAppear {
                    for i in particles.indices {
                        withAnimation(Animation.linear(duration: Double.random(in: 1...3)).repeatForever(autoreverses: false)) {
                            particles[i].position.y = UIScreen.main.bounds.height + 50
                            particles[i].opacity = 0
                        }
                    }
                }
            }
            
            struct ConfettiParticle {
                var position = CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: -50...0)
                )
                var color = [Color.red, Color.blue, Color.green, Color.yellow, Color.purple, Color.orange].randomElement()!
                var size = CGFloat.random(in: 5...10)
                var opacity: Double = 1.0
            }
        }
    }
    
    /// Example 4: Credit Status in a Tab View
    public struct CreditTabViewExample: View {
        @StateObject private var viewModel = CreditViewModel()
        
        public init() {}
        
        public var body: some View {
            TabView {
                CreditStatusView(viewModel: viewModel)
                    .tabItem {
                        Label("Credits", systemImage: "creditcard")
                    }
                
                Text("Other Tab Content")
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
            }
        }
    }
    
    /// Example 5: Credit Status in a List
    public struct CreditListExample: View {
        @StateObject private var viewModel = CreditViewModel()
        
        public init() {}
        
        public var body: some View {
            List {
                Section(header: Text("Credit Status")) {
                    CreditStatusView(viewModel: viewModel)
                }
                
                Section(header: Text("Other Settings")) {
                    ForEach(1...5, id: \.self) { index in
                        Text("Setting \(index)")
                    }
                }
            }
        }
    }
    
    /// Example 6: Programmatic Credit Consumption
    public struct ProgrammaticCreditExample: View {
        @StateObject private var viewModel = CreditViewModel()
        
        public init() {}
        
        public var body: some View {
            VStack(spacing: 20) {
                CreditStatusView(viewModel: viewModel)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                
                Button("Consume 5 Credits") {
                    viewModel.consumeCredits(5, description: "API Call")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Consume 20 Credits") {
                    viewModel.consumeCredits(20, description: "Generate Content")
                }
                .buttonStyle(.bordered)
                
                Button("Reset Credits") {
                    viewModel.resetCredits()
                }
                .foregroundColor(.red)
            }
            .padding()
        }
    }
}

/// A view that showcases all the CreditsManager examples
public struct CreditsExamplesListView: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                NavigationLink("Basic Credit Status") {
                    CreditsExamples.BasicCreditStatusExample()
                }
                
                NavigationLink("Full Credit View") {
                    CreditsExamples.FullCreditViewExample()
                }
                
                NavigationLink("Credit Demo") {
                    CreditsExamples.CreditDemoExample()
                }
                
                NavigationLink("Credit in Tab View") {
                    CreditsExamples.CreditTabViewExample()
                }
                
                NavigationLink("Credit in List") {
                    CreditsExamples.CreditListExample()
                }
                
                NavigationLink("Programmatic Credit Consumption") {
                    CreditsExamples.ProgrammaticCreditExample()
                }
            }
            .navigationTitle("Credits Examples")
        }
    }
}

// MARK: - SwiftUI Previews
struct CreditsExamples_Previews: PreviewProvider {
    static var previews: some View {
        CreditsExamplesListView()
    }
}
