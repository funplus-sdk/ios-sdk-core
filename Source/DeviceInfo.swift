//
//  DeviceInfo.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 8/30/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import UIKit
import AdSupport
import CoreTelephony

// MARK: - DeviceInfo

class DeviceInfo {
    
    /// Device's identifier for vendor or `nil`.
    static let identifierForVendor: String? = {
        return UIDevice.current.identifierForVendor?.uuidString
    }()
    
    /// Device's advertising identifier or `nil`.
    static let advertisingIdentifier: String? = {
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil;
        }
        
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }()
    
    /// Device's operating system name.
    static let systemName: String = {
        return UIDevice.current.systemName;
    }()

    /// Device's operating system version.
    static let systemVersion: String = {
        return UIDevice.current.systemVersion
    }()
    
    /// Device's model name.
    static let modelName: String = {
        return UIDevice.current.model;
    }()
    
    /// App name or "Unknown".
    static let appName: String = {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown"
    }()
    
    /// App version or "1.0.0".
    static let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(version) build \(build)"
    }()
    
    /// App language. It might be different from the device's default language.
    static let appLanguage: String = {
        return (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String ?? "en"
    }()
    
    /// Name of network carrier or "Unknown".
    static let networkCarrierName: String = {
        return CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? "Unknown"
    }()
    
}
