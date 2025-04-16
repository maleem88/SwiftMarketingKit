import Foundation
import SwiftUI
import ComposableArchitecture

// UserDefaults keys
private enum UserDefaultsKeys {
    static let ratingFirstLaunchDate = "com.supertuber.ratingfirstLaunchDate"
    static let lifetimeOfferfirstLaunchDate = "com.supertuber.lifetimeOfferfirstLaunchDate"
}

@Reducer
public struct LifetimeOfferReducer {
    
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var isOfferAvailable: Bool = false
        var remainingSeconds: Double = 0
        var title: String = "special_launch_offer".localized
        var subtitle: String = "lifetime_access_offer_expires".localized
        var showSubscribeView = false
        var didInit = false
        public init(
            isOfferAvailable: Bool = false,
            remainingSeconds: Double = 0,
            title: String = "special_launch_offer".localized,
            subtitle: String = "lifetime_access_offer_expires".localized
        ) {
            self.isOfferAvailable = isOfferAvailable
            self.remainingSeconds = remainingSeconds
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case checkOfferAvailability
        case updateTimer
        case setShowSubscribeView(Bool)
    }
    
    // Helper for managing first launch date
    public enum AppFirstLaunch {
        static func registerFirstLaunchIfNeeded() {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: UserDefaultsKeys.lifetimeOfferfirstLaunchDate) == nil {
                defaults.set(Date(), forKey: UserDefaultsKeys.lifetimeOfferfirstLaunchDate)
                
            }
        }
        
        static func getFirstLaunchDate() -> Date? {
            
            return UserDefaults.standard.object(forKey: UserDefaultsKeys.lifetimeOfferfirstLaunchDate) as? Date
        }
        
        static func isLifetimeOfferAvailable() -> Bool {
            guard let firstLaunchDate = getFirstLaunchDate() else {
                // If no first launch date is recorded, register it now and return true
                registerFirstLaunchIfNeeded()
                return true
            }
            
            // Check if less than 24 hours have passed since first launch
            let timeInterval = Date().timeIntervalSince(firstLaunchDate)
            let hoursElapsed = timeInterval / 3600 // Convert seconds to hours
            return hoursElapsed < 24
        }
        
        static func getRemainingSecondsForLifetimeOffer() -> Double {
            guard let firstLaunchDate = getFirstLaunchDate() else { return 0 }
            
            // Calculate time remaining until 24 hours after first launch
            let expirationDate = firstLaunchDate.addingTimeInterval(24 * 3600) // 24 hours in seconds
            let timeRemaining = expirationDate.timeIntervalSince(Date())
            
            // If time remaining is negative, offer has expired
            if timeRemaining <= 0 {
                return 0
            }
            
            return timeRemaining
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.didInit else {return .none}
                
                state.didInit = true
                // Register first launch date if not already set
                AppFirstLaunch.registerFirstLaunchIfNeeded()
                
                return .run { send in
                    await send(.checkOfferAvailability)
                }
                
            case .checkOfferAvailability:
                // Check if lifetime offer is available based on first launch date
                state.isOfferAvailable = AppFirstLaunch.isLifetimeOfferAvailable()
                state.remainingSeconds = AppFirstLaunch.getRemainingSecondsForLifetimeOffer()
                
                // If lifetime offer is available, start a timer to update the countdown
                if state.isOfferAvailable && state.remainingSeconds > 0 {
                    return .run { send in
                        // Update the timer every second
                        while true {
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                            await send(.updateTimer)
                        }
                    }
                }
                return .none
                
            case .updateTimer:
                // Update the remaining time for the lifetime offer
                state.remainingSeconds = AppFirstLaunch.getRemainingSecondsForLifetimeOffer()
                
                // If the offer has expired, update the availability
                if state.remainingSeconds <= 0 {
                    state.isOfferAvailable = false
                }
                return .none
                
            case .setShowSubscribeView(let value):
                state.showSubscribeView = value
                // This will be handled by the parent reducer to navigate to SubscribeView
                return .none
            }
        }
    }
}

public struct LifetimeOfferTimerView: View {
    @Bindable var store: StoreOf<LifetimeOfferReducer>
    
    public init(store: StoreOf<LifetimeOfferReducer>) {
        self.store = store
    }
    
    public var body: some View {
        if store.isOfferAvailable && store.remainingSeconds > 0 {
            Button {
//                store.send(.binding(.set(\.showSubscribeView, true)))
                // Open SubscribeView when clicked
                store.send(.setShowSubscribeView(true))
            } label: {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "timer")
                        
                        Text(store.title)
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
                    
                    Text(store.subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.top, 4)
                    
                    CountdownTimer(remainingSeconds: store.remainingSeconds)
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
            .sheet(
                isPresented: $store.showSubscribeView.sending(\.setShowSubscribeView)) {
                    SubscribeView()
                }
        } else {
            EmptyView()
        }
            
    }
}

// Preview provider for SwiftUI Canvas
struct LifetimeOfferTimerView_Previews: PreviewProvider {
    static var previews: some View {
        LifetimeOfferTimerView(
            store: Store(initialState: LifetimeOfferReducer.State(
                isOfferAvailable: true,
                remainingSeconds: 3661 // 1 hour, 1 minute, 1 second
            )) {
                LifetimeOfferReducer()
            }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
