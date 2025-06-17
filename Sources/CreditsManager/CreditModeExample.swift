import SwiftUI

/// Example view demonstrating how to use the different credit modes
public struct CreditModeExample: View {
    @StateObject private var viewModel = CreditViewModel()
    @State private var selectedMode: CreditMode = .renewal
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            // Credit mode picker
            Picker("Credit Mode", selection: $selectedMode) {
                Text("One-Time Credits").tag(CreditMode.oneTime)
                Text("Renewal Credits").tag(CreditMode.renewal)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedMode) { newValue in
                viewModel.setCreditMode(newValue)
            }
            
            // Credit status view
            CreditStatusView(viewModel: viewModel)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            
            // Example buttons
            HStack(spacing: 20) {
                Button("Use 10 Credits") {
                    viewModel.consumeCredits(10, description: "Feature usage")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Reset Credits") {
                    viewModel.resetCredits()
                }
                .buttonStyle(.bordered)
            }
            
            // Mode explanation
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Mode: \(selectedMode == .oneTime ? "One-Time" : "Renewal")")
                    .font(.headline)
                
                if selectedMode == .oneTime {
                    Text("One-time credits are allocated once and do not automatically renew.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Renewal credits are replenished periodically based on the configured schedule.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
        }
        .padding()
        .onAppear {
            // Initialize with the current mode from the client
            selectedMode = viewModel.creditMode
        }
    }
}

#Preview {
    CreditModeExample()
}
