//
//  FunPlusConfigFactory.swift
//  FunPlusSDKTests
//
//  Created by Yuankun Zhang on 11/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class FunPlusConfigFactory {
    
    static let APP_ID = "test"
    static let APP_KEY = "funplus"
    static let CONFIG_ETAG = ""
    static let ENV = SDKEnvironment.sandbox

    class func defaultFunPlusConfig() -> FunPlusConfig {
        return try! FunPlusConfig(
            appId: APP_ID,
            appKey: APP_KEY,
            environment: ENV,
            configEtag: CONFIG_ETAG,
            configDict: [
                "logger_endpoint":              "https://logagent.infra.funplus.net/log",
                "logger_tag":                   "test",
                "logger_key":                   "funplus",
                "logger_level":                 "info",
                "rum_endpoint":                 "https://logagent.infra.funplus.net/log",
                "rum_tag":                      "test",
                "rum_key":                      "funplus",
                "data_endpoint":                "https://logagent.infra.funplus.net/log",
                "data_tag":                     "test",
                "data_key":                     "funplus",
                "adjust_app_token":             "cchqrhzyr4zu",
                "adjust_app_open_event_token":  "st1hu7"
            ]
        )
    }

    class func rumSampleRateZeroConfig() -> FunPlusConfig {
        return try! FunPlusConfig(
            appId: APP_ID,
            appKey: APP_KEY,
            environment: ENV,
            configEtag: CONFIG_ETAG,
            configDict: [
                "logger_endpoint":              "https://logagent.infra.funplus.net/log",
                "logger_tag":                   "test",
                "logger_key":                   "funplus",
                "logger_level":                 "info",
                "rum_endpoint":                 "https://logagent.infra.funplus.net/log",
                "rum_tag":                      "test",
                "rum_key":                      "funplus",
                "rum_sample_rate":              0.0,
                "data_endpoint":                "https://logagent.infra.funplus.net/log",
                "data_tag":                     "test",
                "data_key":                     "funplus",
                "adjust_app_token":             "cchqrhzyr4zu",
                "adjust_app_open_event_token":  "st1hu7"
            ]
        )
    }
}
