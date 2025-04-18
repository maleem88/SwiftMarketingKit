import Foundation
import UIKit

/// Helper class to get device information for feedback emails
public struct DeviceInfoHelper {
    /// Get formatted device information string
    public static func getDeviceInfo() -> String {
        let device = UIDevice.current
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        return """
        Device: \(device.model)
        iOS Version: \(device.systemVersion)
        App Version: \(appVersion) (\(buildNumber))
        """
    }
}
