import SwiftUI

public struct LifetimeOfferTimerView: View {
    @ObservedObject var viewModel: LifetimeOfferViewModel
    var onSubscribeAction: () -> Void
    
    public init(viewModel: LifetimeOfferViewModel, onSubscribeAction: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSubscribeAction = onSubscribeAction
    }
    
    public var body: some View {
        if viewModel.isOfferAvailable && viewModel.remainingSeconds > 0 {
            Button {
                // Open SubscribeView when clicked
                onSubscribeAction()
            } label: {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "timer")
                        
                        Text(viewModel.title)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.accentColor)
                    )
                    .padding(.top, 8)
                    
                    Text(viewModel.subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.top, 4)
                    
                    CountdownTimer(remainingSeconds: viewModel.remainingSeconds)
                        .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.tertiarySystemBackground))
                        .shadow(color: Color.accentColor.opacity(0.2), radius: 4, x: 0, y: 2)
                )
                .padding(.bottom, 12)
            }
            .buttonStyle(PlainButtonStyle()) // Use plain style to keep our custom styling
        } else {
            EmptyView()
        }
    }
}

// Preview provider for SwiftUI Canvas
struct LifetimeOfferTimerView_Previews: PreviewProvider {
    static var previews: some View {
        LifetimeOfferTimerView(
            viewModel: LifetimeOfferViewModel(
                isOfferAvailable: true,
                remainingSeconds: 3600,
                title: "Special Launch Offer",
                subtitle: "Lifetime access offer expires in:"
            ),
            onSubscribeAction: {}
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
