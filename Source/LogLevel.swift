//
//  LogLevel.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 08/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - LogLevel

enum LogLevel: Int {
    case info   = 1
    case warn   = 2
    case error  = 3
    case fatal  = 4
    
    static func factory(logLevelString: String) -> LogLevel {
        switch logLevelString {
        case "info":    return .info
        case "warn":    return .warn
        case "fatal":   return .fatal
        default:        return .error
        }
    }
}
