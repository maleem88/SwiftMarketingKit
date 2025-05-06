//import Foundation
//import SwiftUI
//
///// Configuration class for customizing the CreditsManager experience
//public class CreditsManagerConfig {
//    // MARK: - Singleton
////    public static let shared = CreditsManagerConfig()
//    
//    // MARK: - Credit Renewal Period
//    public enum RenewalPeriod {
//        case daily
//        case weekly(dayOfWeek: Int)  // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
//        case monthly(dayOfMonth: Int) // 1-28 (to handle February)
//        
//        var description: String {
//            switch self {
//            case .daily:
//                return "Daily"
//            case .weekly:
//                return "Weekly"
//            case .monthly:
//                return "Monthly"
//            }
//        }
//        
//        var calendarComponent: Calendar.Component {
//            switch self {
//            case .daily:
//                return .day
//            case .weekly:
//                return .weekOfYear
//            case .monthly:
//                return .month
//            }
//        }
//        
//        var defaultTitle: String {
//            return "\(description) Credits"
//        }
//    }
//    
//    // MARK: - Properties
//    
//    // Credit configuration
//    private var renewalPeriod: RenewalPeriod = .monthly(dayOfMonth: 1)
//    private var creditAmount: Int = 100
//    
//    // UserDefaults keys
//    private var totalCreditsKey: String = "com.credits.totalCredits"
//    private var consumedCreditsKey: String = "com.credits.consumedCredits"
//    private var nextRenewalDateKey: String = "com.credits.nextRenewalDate"
//    private var creditHistoryKey: String = "com.credits.creditHistory"
//    
//    // UI customization
//    private var daysUntilRenew: String = "Days until renewal"
//    private var creditsTitleText: String = "Monthly Credits"
//    private var historyTitleText: String = "Recent Activity"
//    private var insufficientCreditsAlertTitle: String = "Insufficient Credits"
//    private var insufficientCreditsAlertMessage: String = "You need %@ credits but only have %@ remaining. Your credits will renew in %@ days."
//    
//    // Color thresholds
//    private var highCreditThreshold: Double = 0.6  // Above this percentage is green
//    private var mediumCreditThreshold: Double = 0.3 // Above this percentage is orange, below is red
//    
//    // Colors
//    private var highCreditColor: Color = .green
//    private var mediumCreditColor: Color = .orange
//    private var lowCreditColor: Color = .red
//    
//    // Display options
//    private var showHistorySection: Bool = true
//    private var maxHistoryItems: Int = 5
//    
//    // MARK: - Initialization
//    public init() {}
//    
//    // MARK: - Public Configuration Methods
//    
//    /// Set the renewal period for credits
//    /// - Parameter period: The renewal period (daily, weekly, or monthly)
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setRenewalPeriod(_ period: RenewalPeriod) -> Self {
//        self.renewalPeriod = period
//        
//        // Update title text based on period if it's still the default
//        if creditsTitleText == "Monthly Credits" || 
//           creditsTitleText == "Weekly Credits" || 
//           creditsTitleText == "Daily Credits" {
//            creditsTitleText = period.defaultTitle
//        }
//        
//        return self
//    }
//    
//    /// Set the amount of credits allocated each renewal period
//    /// - Parameter amount: The number of credits
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setCreditAmount(_ amount: Int) -> Self {
//        self.creditAmount = amount
//        return self
//    }
//    
//    /// Set custom UserDefaults keys for the credit system
//    /// - Parameters:
//    ///   - totalKey: Key for storing total credits
//    ///   - consumedKey: Key for storing consumed credits
//    ///   - renewalDateKey: Key for storing next renewal date
//    ///   - historyKey: Key for storing credit history
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setUserDefaultsKeys(totalKey: String, consumedKey: String, renewalDateKey: String, historyKey: String) -> Self {
//        self.totalCreditsKey = totalKey
//        self.consumedCreditsKey = consumedKey
//        self.nextRenewalDateKey = renewalDateKey
//        self.creditHistoryKey = historyKey
//        return self
//    }
//    
//    /// Set the title text for the credits display
//    /// - Parameter title: The title text
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setCreditsTitleText(_ title: String) -> Self {
//        self.creditsTitleText = title
//        return self
//    }
//    
//    /// Set the title text for the credits display
//    /// - Parameter title: The title text
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setDaysUntilRenewalText(_ title: String) -> Self {
//        self.daysUntilRenew = title
//        return self
//    }
//    
//    /// Set the title text for the history section
//    /// - Parameter title: The title text
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setHistoryTitleText(_ title: String) -> Self {
//        self.historyTitleText = title
//        return self
//    }
//    
//    /// Set the insufficient credits alert text
//    /// - Parameters:
//    ///   - title: Alert title
//    ///   - message: Alert message. Use %@ placeholders for needed, remaining, and days values
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setInsufficientCreditsAlertText(title: String, message: String) -> Self {
//        self.insufficientCreditsAlertTitle = title
//        self.insufficientCreditsAlertMessage = message
//        return self
//    }
//    
//    /// Set the color thresholds for credit display
//    /// - Parameters:
//    ///   - highThreshold: Percentage threshold for high credits (default: 0.6)
//    ///   - mediumThreshold: Percentage threshold for medium credits (default: 0.3)
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setCreditThresholds(highThreshold: Double, mediumThreshold: Double) -> Self {
//        self.highCreditThreshold = highThreshold
//        self.mediumCreditThreshold = mediumThreshold
//        return self
//    }
//    
//    /// Set the colors for credit display
//    /// - Parameters:
//    ///   - highColor: Color for high credit level
//    ///   - mediumColor: Color for medium credit level
//    ///   - lowColor: Color for low credit level
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func setCreditColors(highColor: Color, mediumColor: Color, lowColor: Color) -> Self {
//        self.highCreditColor = highColor
//        self.mediumCreditColor = mediumColor
//        self.lowCreditColor = lowColor
//        return self
//    }
//    
//    /// Configure the history section display
//    /// - Parameters:
//    ///   - show: Whether to show the history section
//    ///   - maxItems: Maximum number of history items to display
//    /// - Returns: The config instance for chaining
//    @discardableResult
//    public func configureHistoryDisplay(show: Bool, maxItems: Int = 5) -> Self {
//        self.showHistorySection = show
//        self.maxHistoryItems = maxItems
//        return self
//    }
//    
//    // MARK: - Internal Getters
//    
//    func getRenewalPeriod() -> RenewalPeriod {
//        return renewalPeriod
//    }
//    
//    
//    func getTotalCreditsKey() -> String {
//        return totalCreditsKey
//    }
//    
//    func getConsumedCreditsKey() -> String {
//        return consumedCreditsKey
//    }
//    
//    func getNextRenewalDateKey() -> String {
//        return nextRenewalDateKey
//    }
//    
//    func getCreditHistoryKey() -> String {
//        return creditHistoryKey
//    }
//    
//    func getCreditsTitleText() -> String {
//        return creditsTitleText
//    }
//    
//    func getDaysUntilRenew() -> String {
//        return daysUntilRenew
//    }
//    
//    
//    func getHistoryTitleText() -> String {
//        return historyTitleText
//    }
//    
//    func getInsufficientCreditsAlertTitle() -> String {
//        return insufficientCreditsAlertTitle
//    }
//    
//    func getInsufficientCreditsAlertMessage() -> String {
//        return insufficientCreditsAlertMessage
//    }
//    
//    func getHighCreditThreshold() -> Double {
//        return highCreditThreshold
//    }
//    
//    func getMediumCreditThreshold() -> Double {
//        return mediumCreditThreshold
//    }
//    
//    func getHighCreditColor() -> Color {
//        return highCreditColor
//    }
//    
//    func getMediumCreditColor() -> Color {
//        return mediumCreditColor
//    }
//    
//    func getLowCreditColor() -> Color {
//        return lowCreditColor
//    }
//    
//    func shouldShowHistorySection() -> Bool {
//        return showHistorySection
//    }
//    
//    func getMaxHistoryItems() -> Int {
//        return maxHistoryItems
//    }
//    
//    /// Get the configured credit amount
//    /// - Returns: The number of credits allocated each renewal period
//    func getCreditAmount() -> Int {
//        return creditAmount
//    }
//    
//    /// Get the appropriate color for a given credit percentage
//    /// - Parameter percentage: The percentage of credits remaining (0.0 - 1.0)
//    /// - Returns: The appropriate color based on thresholds
//    func getCreditColor(for percentage: Double) -> Color {
//        if percentage > highCreditThreshold {
//            return highCreditColor
//        } else if percentage > mediumCreditThreshold {
//            return mediumCreditColor
//        } else {
//            return lowCreditColor
//        }
//    }
//    
//    /// Get the formatted renewal period description
//    /// - Returns: A string describing the renewal period (e.g., "Daily", "Weekly", "Monthly")
//    func getRenewalPeriodDescription() -> String {
//        return renewalPeriod.description
//    }
//    
//    /// Calculate the next renewal date based on the current date and renewal period
//    /// - Parameter from: The date to calculate from (defaults to current date)
//    /// - Returns: The next renewal date
//    func calculateNextRenewalDate(from: Date = Date()) -> Date {
//        let calendar = Calendar.current
//        var components = DateComponents()
//        
//        switch renewalPeriod {
//        case .daily:
//            components.day = 1
//            
//        case .weekly(let dayOfWeek):
//            // Calculate days until the next specified day of week
//            let currentDayOfWeek = calendar.component(.weekday, from: from)
//            var daysToAdd = dayOfWeek - currentDayOfWeek
//            if daysToAdd <= 0 {
//                daysToAdd += 7 // Move to next week if today is the specified day or later
//            }
//            components.day = daysToAdd
//            
//        case .monthly(let dayOfMonth):
//            // Move to the specified day of the next month
//            var nextMonthComponents = calendar.dateComponents([.year, .month], from: from)
//            nextMonthComponents.month = (nextMonthComponents.month ?? 1) + 1
//            nextMonthComponents.day = min(dayOfMonth, 28) // Cap at 28 to handle February
//            
//            // If we're before the renewal day this month, set to this month
//            let currentDay = calendar.component(.day, from: from)
//            if currentDay < dayOfMonth {
//                nextMonthComponents.month = nextMonthComponents.month! - 1
//            }
//            
//            if let nextDate = calendar.date(from: nextMonthComponents) {
//                return nextDate
//            }
//        }
//        
//        // Apply the components to get the next date
//        if let nextDate = calendar.date(byAdding: components, to: from) {
//            return nextDate
//        }
//        
//        // Fallback
//        var fallbackComponents = DateComponents()
//        switch renewalPeriod.calendarComponent {
//        case .day:
//            fallbackComponents.day = 1
//        case .weekOfYear:
//            fallbackComponents.day = 7
//        case .month:
//            fallbackComponents.month = 1
//        default:
//            fallbackComponents.day = 1
//        }
//        return calendar.date(byAdding: fallbackComponents, to: from) ?? Date().addingTimeInterval(86400)
//    }
//}
