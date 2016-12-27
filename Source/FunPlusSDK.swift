//
//  FunPlusSDK.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 08/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - FunPlusSDKError

public enum FunPlusSDKError: Error {
    case invalidConfig
}

// MARK: - FunPlusSDK

public class FunPlusSDK {
    
    // MARK: - Properties
    
    public static let VERSION = "4.1.0-alpha.0"
    
    /// The singleton instance.
    static var instance: FunPlusSDK?
    
    /// Shared instance of `FunPlusSDK`.
    /// Must be used after SDK is installed, otherwise will throw exception.
    static var shared = { return instance! }()
    
    /// Key used to save the installation date.
    static let INSTALL_DATE_SAVED_KEY = "com.funplus.sdk.InstallDate"
    
    /// The configurations used by SDK.
    let funPlusConfig: FunPlusConfig
    
    /// Data events are interested in app's install date.
    let installDate: Date
    
    // MARK: - Install & Init
    
    public class func install(funPlusConfig: FunPlusConfig) {
        if instance == nil {
            print("[FunPlusSDK] Installing FunPlus SDK: {sdkVersion=\(FunPlusSDK.VERSION), appId=\(funPlusConfig.appId), env=\(funPlusConfig.environment)}")
            instance = FunPlusSDK(funPlusConfig: funPlusConfig)
        } else {
            duplicatedInstallWarn()
        }
    }
    
    // Deprecated
    public class func install(appId: String, appKey: String, environment: SDKEnvironment) throws {
        if instance == nil {
            let funPlusConfig = try ConfigManager(appId: appId, appKey: appKey, environment: environment).getFunPlusConfig()
            install(funPlusConfig: funPlusConfig)
        } else {
            duplicatedInstallWarn()
        }
    }
    
    /**
        Install the SDK.
     
        - parameter appId:          The FunPlus app ID.
        - parameter appKey:         The FunPlus app key.
        - parameter rumTag:         The RUM tag.
        - parameter rumKey:         The RUM key.
        - parameter environment:    The running environment.
     */
    public class func install(
        appId: String,
        appKey: String,
        rumTag: String,
        rumKey: String,
        environment: SDKEnvironment)
    {
        if (instance == nil) {
            let funPlusConfig = FunPlusConfig(
                appId: appId,
                appKey: appKey,
                rumTag: rumTag,
                rumKey: rumKey,
                environment: environment
            )
            instance = FunPlusSDK(funPlusConfig: funPlusConfig)
        } else {
            duplicatedInstallWarn()
        }
    }
    
    /**
        Initialize the SDK using given configurations.
     
        - parameter funPlusConfig:  Configurations used to initialize the SDK.
     
        - returns:  The created SDK isntance.
     */
    private init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        
        // Retrieve app's installation date. If not found, save currend date.
        installDate = UserDefaults.standard.object(forKey: FunPlusSDK.INSTALL_DATE_SAVED_KEY) as? Date ?? Date()
        UserDefaults.standard.set(installDate, forKey: FunPlusSDK.INSTALL_DATE_SAVED_KEY)
        
        // Trigger modules' initializations.
        let _ = FunPlusFactory.getLoggerDataConsumer(funPlusConfig: funPlusConfig)
        let _ = FunPlusFactory.getFunPlusID(funPlusConfig: funPlusConfig)
        let _ = FunPlusFactory.getFunPlusRUM(funPlusConfig: funPlusConfig)
        let _ = FunPlusFactory.getFunPlusData(funPlusConfig: funPlusConfig)
    }
    
    // MARK: - Methods
    
    /**
        Get app's installation date.
     
        - returns:  App's installation date.
     */
    public class func getInstallDate() -> Date {
        return instance?.installDate ?? Date()
    }
    
    /**
        Get the `SessionManager` instance. This method is not exposed to public.
     
        - returns:  The `SessionManager` instance.
     */
    class func getSessionManager() -> SessionManager {
        if instance == nil {
            notInstallWarn()
        }
        return FunPlusFactory.getSessionManager(funPlusConfig: shared.funPlusConfig)
    }
    
    /**
        Get the `FunPlusID` instance.
     
        - returns:  The `FunPlusID` instance.
     */
    public class func getFunPlusID() -> FunPlusID {
        if instance == nil {
            notInstallWarn()
        }
        return FunPlusFactory.getFunPlusID(funPlusConfig: shared.funPlusConfig)
    }
    
    /**
        Get the `FunPlusRUM` instance.
     
        - returns:  The `FunPlusRUM` instance.
     */
    public class func getFunPlusRUM() -> FunPlusRUM {
        if instance == nil {
            notInstallWarn()
        }
        return FunPlusFactory.getFunPlusRUM(funPlusConfig: shared.funPlusConfig)
    }
    
    /**
        Get the `FunPlusData` instance.
     
        - returns:  The `FunPlusData` instance.
     */
    public class func getFunPlusData() -> FunPlusData {
        if instance == nil {
            notInstallWarn()
        }
        return FunPlusFactory.getFunPlusData(funPlusConfig: shared.funPlusConfig)
    }
    
    // MARK: - Helpers
    
    /**
        Print a message on the console that SDK does not need to be installed a second time.
     */
    private class func duplicatedInstallWarn() {
        print("[FunPlusSDK] FunPlus SDK has been installed, there's no need to install it again")
    }
    
    /**
        Print a message on the console that SDK does not need to be installed before being used.
     */
    private class func notInstallWarn() {
        print("[FunPlusSDK] FunPlus SDK has not been installed yet.")
    }
    
}
