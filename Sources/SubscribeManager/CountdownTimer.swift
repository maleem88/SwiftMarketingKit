import SwiftUI

// View for displaying countdown timer units
struct CountdownUnit: View {
    let value: Double
    let unit: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Int(value))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(minWidth: 30)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

// A complete countdown timer that displays hours, minutes, and seconds
public struct CountdownTimer: View {
    
    public init(remainingSeconds: Double) {
        self.remainingSeconds = remainingSeconds
    }
    
    public let remainingSeconds: Double
    
    public var body: some View {
        HStack(spacing: 4) {
            CountdownUnit(value: floor(remainingSeconds / 3600), unit: "hours".localized)
            Text(":")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            CountdownUnit(value: floor(Double(Int(remainingSeconds) % 3600) / 60), unit: "min".localized)
            Text(":")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            CountdownUnit(value: Double(Int(remainingSeconds) % 60), unit: "sec".localized)
        }
    }
}

// The LifetimeOfferTimerWidget has been moved to LifetimeOfferFeature.swift
// and converted to use The Composable Architecture (TCA)

// Preview provider for SwiftUI Canvas
struct CountdownTimer_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CountdownUnit(value: 12, unit: "hours".localized)
            
            CountdownTimer(remainingSeconds: 3661) // 1 hour, 1 minute, 1 second
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
