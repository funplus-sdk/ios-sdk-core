//
//  Logger.swift
//  FunPlusCore
//
//  Created by Yuankun Zhang on 5/31/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - Logger

///
/// The `Logger` class is used to collect SDK internal logs.
///
/// There're four log levels:
///
/// - INFO
/// - WARN
/// - DEBUG
/// - FATAL
///
class Logger {
    
    // MARK: - Properties
    
    let funPlusConfig: FunPlusConfig
    let logLevel: LogLevel
    var logs = [String]()
    
    init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        logLevel = funPlusConfig.logLevel
    }
 
    // MARK: - Trace
    
    func consumeLogs() -> [String] {
        let l = logs.map { $0.copy() as! String }
        logs.removeAll()
        return l
    }
    
    func i(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        if logLevel.rawValue <= LogLevel.info.rawValue {
            trace(message, logLevelString: "INFO", function: function, file: file, line: line)
        }
    }
    
    func w(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        if logLevel.rawValue <= LogLevel.warn.rawValue {
            trace(message, logLevelString: "WARN", function: function, file: file, line: line)
        }
    }
    
    func e(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        if logLevel.rawValue <= LogLevel.error.rawValue {
            trace(message, logLevelString: "ERROR", function: function, file: file, line: line)
        }
    }

    func wtf(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        if logLevel.rawValue <= LogLevel.fatal.rawValue {
            trace(message, logLevelString: "FATAL", function: function, file: file, line: line)
        }
    }
    
    func trace(
        _ message: String,
        logLevelString: String,
        function: String,
        file: String,
        line: Int,
        callStackSymbols: String? = nil)
    {
        let filename = file.components(separatedBy: "/").last ?? "unknown"
        let log = "[\(logLevelString) \(function) \(filename):\(line)] \(message)"
        var callStackSymbols = ""
        
        if logLevelString == "ERROR" || logLevelString == "FATAL" {
            callStackSymbols = Thread.callStackSymbols.joined(separator: "\n")
        }
        
        print(log)
        
        let entry = buildLogEntry(logLevelString: logLevelString, log: log, callStackSymbols: callStackSymbols)
        objc_sync_enter(self)
        logs.append(entry.description)
        objc_sync_exit(self)
    }
    
    fileprivate func buildLogEntry(logLevelString: String, log: String, callStackSymbols: String) -> [String: Any] {
        let sessionManager = FunPlusFactory.getSessionManager(funPlusConfig: funPlusConfig)
        
        let dict: [String: Any] = [
            "event": "log_entry",
            "ts": "\(Int64(Date().timeIntervalSince1970 * 1000))",
            "app_id": funPlusConfig.appId,
            "app_version": DeviceInfo.appVersion,
            "user_id": sessionManager.userId,
            "session_id": sessionManager.sessionId,
            "rum_id": DeviceInfo.identifierForVendor ?? "",
            "data_version": "1.0",
            
            "properties": [
                "app_version": DeviceInfo.appVersion,
                "sdk_version": FunPlusSDK.VERSION,
                "config_etag": funPlusConfig.configEtag,
                "device": DeviceInfo.modelName,
                "os": DeviceInfo.systemName,
                "os_version": DeviceInfo.systemVersion,
                "log": log,
                "log_level": logLevelString,
                "call_stack_symbols": callStackSymbols
            ]
        ]
        return dict
    }
}
