//
//  FunPlusFactory.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 09/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - FunPlusFactory

class FunPlusFactory {
    
    // MARK: - Properties
    
    static var logger: Logger? = nil
    static var sessionManager: SessionManager? = nil
    static var funPlusID: FunPlusID? = nil
    static var funPlusRUM: FunPlusRUM? = nil
    static var funPlusData: FunPlusData? = nil
    static var loggerDataConsumer: LoggerDataConsumer? = nil
    
    // MARK: - Methods
    
    static func getLogger(funPlusConfig: FunPlusConfig) -> Logger {
        if logger == nil {
            logger = Logger(funPlusConfig: funPlusConfig)
        }
        return logger!
    }
    
    static func getSessionManager(funPlusConfig: FunPlusConfig) -> SessionManager {
        if sessionManager == nil {
            sessionManager = SessionManager(funPlusConfig: funPlusConfig)
        }
        return sessionManager!
    }
    
    static func getFunPlusID(funPlusConfig: FunPlusConfig) -> FunPlusID {
        if funPlusID == nil {
            funPlusID = FunPlusID(funPlusConfig: funPlusConfig)
        }
        return funPlusID!
    }
    
    static func getFunPlusRUM(funPlusConfig: FunPlusConfig) -> FunPlusRUM {
        if funPlusRUM == nil {
            funPlusRUM = FunPlusRUM(funPlusConfig: funPlusConfig)
        }
        return funPlusRUM!
    }
    
    static func getFunPlusData(funPlusConfig: FunPlusConfig) -> FunPlusData {
        if funPlusData == nil {
            funPlusData = FunPlusData(funPlusConfig: funPlusConfig)
        }
        return funPlusData!
    }
    
    static func getLoggerDataConsumer(funPlusConfig: FunPlusConfig) -> LoggerDataConsumer {
        if loggerDataConsumer == nil {
            loggerDataConsumer = LoggerDataConsumer(funPlusConfig: funPlusConfig)
        }
        return loggerDataConsumer!
    }
}
