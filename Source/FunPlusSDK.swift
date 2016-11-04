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
    
    public static let VERSION = "4.0.1-alpha.0"
    
    static var instance: FunPlusSDK?
    static var shared = { return instance! }()
    
    let funPlusConfig: FunPlusConfig
    
    public class func install(funPlusConfig: FunPlusConfig) {
        if instance == nil {
            print("[FunPlusSDK] Installing FunPlus SDK: {sdkVersion=\(FunPlusSDK.VERSION), appId=\(funPlusConfig.appId), env=\(funPlusConfig.environment)}")
            instance = FunPlusSDK(funPlusConfig: funPlusConfig)
        } else {
            print("[FunPlusSDK] FunPlus SDK has been installed, there's no need to install it again")
        }
    }
    
    public class func install(appId: String, appKey: String, environment: SDKEnvironment) throws {
        if instance == nil {
            let funPlusConfig = try ConfigManager(appId: appId, appKey: appKey, environment: environment).getFunPlusConfig()
            install(funPlusConfig: funPlusConfig)
        } else {
            print("[FunPlusSDK] FunPlus SDK has been installed, there's no need to install it again")
        }
    }
    
    private init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        let _ = FunPlusFactory.getLoggerDataConsumer(funPlusConfig: funPlusConfig)
        let _ = FunPlusFactory.getFunPlusID(funPlusConfig: funPlusConfig)
        let _ = FunPlusFactory.getFunPlusRUM(funPlusConfig: funPlusConfig)
        let _ = FunPlusFactory.getFunPlusData(funPlusConfig: funPlusConfig)
    }
    
    public class func getFunPlusID() -> FunPlusID {
        if instance == nil {
            print("[FunPlusSDK] FunPlus SDK has not been installed yet.")
        }
        return FunPlusFactory.getFunPlusID(funPlusConfig: shared.funPlusConfig)
    }
    
    public class func getFunPlusRUM() -> FunPlusRUM {
        if instance == nil {
            print("[FunPlusSDK] FunPlus SDK has not been installed yet.")
        }
        return FunPlusFactory.getFunPlusRUM(funPlusConfig: shared.funPlusConfig)
    }
    
    public class func getFunPlusData() -> FunPlusData {
        if instance == nil {
            print("[FunPlusSDK] FunPlus SDK has not been installed yet.")
        }
        return FunPlusFactory.getFunPlusData(funPlusConfig: shared.funPlusConfig)
    }
}
