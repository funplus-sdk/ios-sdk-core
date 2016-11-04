//
//  FunPlusConfigTests.swift
//  FunPlusSDKTests
//
//  Created by Yuankun Zhang on 11/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class FunPlusConfigTests: XCTestCase {
    
    let APP_ID = "test"
    let APP_KEY = "funpuls"
    let CONFIG_ETAG = ""
    let ENV = SDKEnvironment.sandbox
    
    func testInit() {
        // Given
        let configDict: [String: Any] = [
            "logger_endpoint": "https://logagent.infra.funplus.net/log",
            "logger_tag": "test",
            "logger_key": "funplus",
            "logger_level": "info",
            "rum_endpoint": "https://logagent.infra.funplus.net/log",
            "rum_tag": "test",
            "rum_key": "funplus",
            "data_endpoint": "https://logagent.infra.funplus.net/log",
            "data_tag": "test",
            "data_key": "funplus",
            "adjust_app_token": "cchqrhzyr4zu",
            "adjust_app_open_event_token": "st1hu7"
        ]
        var funPlusConfig: FunPlusConfig?
        var err: FunPlusSDKError? = nil
        
        // When
        do {
            funPlusConfig = try FunPlusConfig(appId: APP_ID, appKey: APP_KEY, environment: ENV, configEtag: CONFIG_ETAG, configDict: configDict)
        } catch {
            err = FunPlusSDKError.invalidConfig
        }
        
        // Then
        XCTAssertNotNil(funPlusConfig)
        XCTAssertNil(err)
    }
    
    func testBadInit() {
        // Given
        let configDict = [String: Any]()
        var funPlusConfig: FunPlusConfig?
        var err: FunPlusSDKError? = nil
        
        // When
        do {
            funPlusConfig = try FunPlusConfig(appId: APP_ID, appKey: APP_KEY, environment: ENV, configEtag: CONFIG_ETAG, configDict: configDict)
        } catch {
            err = FunPlusSDKError.invalidConfig
        }
        
        // Then
        XCTAssertNil(funPlusConfig)
        XCTAssertNotNil(err)
    }

}
