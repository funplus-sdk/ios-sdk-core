//
//  FunPlusConfig.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 08/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - FunPlusConfig

public class FunPlusConfig {
    
    // MARK: - Properties
    
    static let LOG_SERVER = "https://logagent.infra.funplus.net/log"
    
    let appId: String
    let appKey: String
    let environment: SDKEnvironment
    let configEtag: String
    
    let loggerEndpoint: String
    let loggerTag: String
    let loggerKey: String
    let logLevel: LogLevel
    var loggerUploadInterval: Int64
    
    let rumEndpoint: String
    let rumTag: String
    let rumKey: String
    var rumUploadInterval: Int64
    
    var rumSampleRate: Double
    var rumEventWhitelist: [String]
    var rumUserWhitelist: [String]
    var rumUserBlacklist: [String]
    
    let dataEndpoint: String
    let dataTag: String
    let dataKey: String
    var dataUploadInterval: Int64

    var autoSessionStartAndEnd: Bool
    
    // MARK: - Init
    
    public init(appId: String, appKey: String, rumTag: String, rumKey: String, environment: SDKEnvironment) {
        self.appId = appId
        self.appKey = appKey
        self.environment = environment
        
        self.configEtag = "deprecated"
        
        self.loggerEndpoint = FunPlusConfig.LOG_SERVER
        self.loggerTag = rumTag
        self.loggerKey = rumKey
        self.logLevel = environment == .sandbox ? LogLevel.info : LogLevel.error
        self.loggerUploadInterval = 60  // 1 min
        
        self.rumEndpoint = FunPlusConfig.LOG_SERVER
        self.rumTag = rumTag
        self.rumKey = rumKey
        self.rumUploadInterval = 30     // 30 sec
        
        self.rumSampleRate = 1.0
        self.rumEventWhitelist = []
        self.rumUserWhitelist = []
        self.rumUserBlacklist = []
        
        self.dataEndpoint = FunPlusConfig.LOG_SERVER
        self.dataTag = appId
        self.dataKey = appKey
        self.dataUploadInterval = 30    // 30 sec
        
        self.autoSessionStartAndEnd = true
    }
    
    // Deprecated
    init(appId: String, appKey: String, environment: SDKEnvironment, configEtag: String, configDict: [String: Any]) throws {
        // General
        self.appId = appId
        self.appKey = appKey
        self.environment = environment
        self.configEtag = configEtag
        
        // Logger
        guard
            let loggerEndpoint = configDict["logger_endpoint"] as? String,
            let loggerTag = configDict["logger_tag"] as? String,
            let loggerKey = configDict["logger_key"] as? String,
            let logLevelString = configDict["logger_level"] as? String
        else {
            throw FunPlusSDKError.invalidConfig
        }
        
        self.loggerEndpoint = loggerEndpoint
        self.loggerTag = loggerTag
        self.loggerKey = loggerKey
        self.logLevel = LogLevel.factory(logLevelString: logLevelString)
        self.loggerUploadInterval = configDict["logger_upload_interval"] as? Int64 ?? 60
        
        // RUM
        guard
            let rumEndpoint = configDict["rum_endpoint"] as? String,
            let rumTag = configDict["rum_tag"] as? String,
            let rumKey = configDict["rum_key"] as? String
        else {
            throw FunPlusSDKError.invalidConfig
        }
        
        self.rumEndpoint = rumEndpoint
        self.rumTag = rumTag
        self.rumKey = rumKey
        self.rumUploadInterval = configDict["rum_upload_interval"] as? Int64 ?? 10
        
        rumSampleRate = configDict["rum_sample_rate"] as? Double ?? 1.0
        rumEventWhitelist = configDict["rum_event_whitelist"] as? [String] ?? []
        rumUserWhitelist = configDict["rum_user_whitelist"] as? [String] ?? []
        rumUserBlacklist = configDict["rum_user_blacklist"] as? [String] ?? []
        
        // Data
        guard
            let dataEndpoint = configDict["data_endpoint"] as? String,
            let dataTag = configDict["data_tag"] as? String,
            let dataKey = configDict["data_key"] as? String
        else {
            throw FunPlusSDKError.invalidConfig
        }
        
        self.dataEndpoint = dataEndpoint
        self.dataTag = dataTag
        self.dataKey = dataKey
        self.dataUploadInterval = configDict["data_upload_interval"] as? Int64 ?? 10
        
        self.autoSessionStartAndEnd = true
    }
    
    public func setLoggerUploadInterval(_ value: Int64) -> FunPlusConfig {
        loggerUploadInterval = value
        return self
    }
    
    public func setRumUploadInterval(_ value: Int64) -> FunPlusConfig {
        rumUploadInterval = value
        return self
    }
    
    public func setRumSampleRate(_ value: Double) -> FunPlusConfig {
        rumSampleRate = value
        return self
    }
    
    public func setRumEventWhitelist(_ value: [String]) -> FunPlusConfig {
        rumEventWhitelist = value
        return self
    }
    
    public func setRumUserWhitelist(_ value: [String]) -> FunPlusConfig {
        rumUserWhitelist = value
        return self
    }
    
    public func setRumUserBlacklist(_ value: [String]) -> FunPlusConfig {
        rumUserBlacklist = value
        return self
    }
    
    public func setDataUploadInterval(_ value: Int64) -> FunPlusConfig {
        dataUploadInterval = value
        return self
    }
    
    public func setAutoSessionStartAndEnd(_ value: Bool) -> FunPlusConfig {
        autoSessionStartAndEnd = value
        return self
    }
    
    ///
    /// This method should be called at the end of the settings chain,
    /// in order to avoid compiler's "unused returning value" warning.
    ///
    public func end() {
        // Do nothing
    }
}
