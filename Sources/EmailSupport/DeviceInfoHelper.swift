//
//  DeviceInfoHelper.swift
//  YoutubeSummarizer
//
//  Created by mohamed abd elaleem on 06/04/2025.
//

import Foundation
import UIKit

// MARK: - Device Info Helper

/// Utility functions for gathering device information for support and feedback
public enum DeviceInfoHelper {
    
    /// Returns formatted device information for support emails
    public static func getDeviceInfo() -> String {
        let device = UIDevice.current
        let model = device.model
        let systemName = device.systemName
        let systemVersion = device.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let storageInfo = getStorageInfo()

        return """
        App Version: \(appVersion) (\(buildNumber))
        Device: \(model)
        iOS Version: \(systemName) \(systemVersion)
        Free Storage: \(storageInfo)
        """
    }
    
    /// Returns available storage information
    public static func getStorageInfo() -> String {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSize = attrs[.systemFreeSize] as? NSNumber {
            let freeMB = freeSize.int64Value / (1024 * 1024)
            return "\(freeMB) MB"
        }
        return "Unavailable"
    }
}
