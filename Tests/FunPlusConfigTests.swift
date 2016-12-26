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
    let RUM_TAG = "test"
    let RUM_KEY = "funplus"
    let SANDBOX_ENV = SDKEnvironment.sandbox
    let PRODUCTION_ENV = SDKEnvironment.production
    
    let DEFAULT_LOGGER_UPLOAD_INTERVAL: Int64 = 60
    
    let SANDBOX_RUM_UPLOAD_INTERVAL: Int64 = 5
    let SANDBOX_DATA_UPLOAD_INTERVAL: Int64 = 5
    
    let PRODUCTION_RUM_UPLOAD_INTERVAL: Int64 = 10
    let PRODUCTION_DATA_UPLOAD_INTERVAL: Int64 = 10
    
    let SANDBOX_LOG_LEVEL = LogLevel.info
    let PRODUCTION_LOG_LEVEL = LogLevel.error
    
    let DEFAULT_RUM_SAMPLE_RATE = 1.0
    
    func testDefaultValuesForSandboxEnvironment() {
        // Given, When
        let config = FunPlusConfig(appId: APP_ID, appKey: APP_KEY, rumTag: RUM_TAG, rumKey: RUM_KEY, environment: SANDBOX_ENV)
        
        // Then
        XCTAssertEqual(config.appId, APP_ID, "appId should be \(APP_ID)")
        XCTAssertEqual(config.appKey, APP_KEY, "appKey should be \(APP_KEY)")
        XCTAssertEqual(config.environment, SANDBOX_ENV, "environment should be \(SANDBOX_ENV)")
        
        XCTAssertEqual(config.loggerEndpoint, FunPlusConfig.LOG_SERVER, "loggerEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.loggerTag, RUM_TAG, "loggerTag should be \(RUM_TAG)")
        XCTAssertEqual(config.loggerKey, RUM_KEY, "loggerKey should be \(RUM_KEY)")
        XCTAssertEqual(config.logLevel, SANDBOX_LOG_LEVEL, "logLevel should be \(SANDBOX_LOG_LEVEL)")
        XCTAssertEqual(config.loggerUploadInterval, DEFAULT_LOGGER_UPLOAD_INTERVAL, "loggerUploadInterval should be \(DEFAULT_LOGGER_UPLOAD_INTERVAL)")
        
        XCTAssertEqual(config.rumEndpoint, FunPlusConfig.LOG_SERVER, "rumEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.rumTag, RUM_TAG, "rumTag should be \(RUM_TAG)")
        XCTAssertEqual(config.rumKey, RUM_KEY, "rumKey should be \(RUM_KEY)")
        XCTAssertEqual(config.rumUploadInterval, SANDBOX_RUM_UPLOAD_INTERVAL, "rumUploadInterval should be \(SANDBOX_RUM_UPLOAD_INTERVAL)")
        
        XCTAssertEqual(config.rumSampleRate, DEFAULT_RUM_SAMPLE_RATE, "rumSampleRate should be \(DEFAULT_RUM_SAMPLE_RATE)")
        XCTAssertTrue(config.rumEventWhitelist.isEmpty, "rumEventWhitelist should be empty")
        XCTAssertTrue(config.rumUserWhitelist.isEmpty, "rumUserWhitelist should be empty")
        XCTAssertTrue(config.rumUserBlacklist.isEmpty, "rumUserBlacklist should be empty")
        
        XCTAssertEqual(config.dataEndpoint, FunPlusConfig.LOG_SERVER, "dataEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.dataTag, APP_ID, "dataTag should be \(APP_ID)")
        XCTAssertEqual(config.dataKey, APP_KEY, "dataKey should be \(APP_KEY)")
        XCTAssertEqual(config.dataUploadInterval, SANDBOX_DATA_UPLOAD_INTERVAL, "dataUploadInterval should be \(SANDBOX_DATA_UPLOAD_INTERVAL)")
        
        XCTAssertTrue(config.dataAutoTraceSessionEvents, "dataAutoTraceSessionEvents should be true")
    }
    
    func testDefaultValuesForProductionEnvironment() {
        // Given, When
        let config = FunPlusConfig(appId: APP_ID, appKey: APP_KEY, rumTag: RUM_TAG, rumKey: RUM_KEY, environment: PRODUCTION_ENV)
        
        // Then
        XCTAssertEqual(config.appId, APP_ID, "appId should be \(APP_ID)")
        XCTAssertEqual(config.appKey, APP_KEY, "appKey should be \(APP_KEY)")
        XCTAssertEqual(config.environment, PRODUCTION_ENV, "environment should be \(PRODUCTION_ENV)")
        
        XCTAssertEqual(config.loggerEndpoint, FunPlusConfig.LOG_SERVER, "loggerEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.loggerTag, RUM_TAG, "loggerTag should be \(RUM_TAG)")
        XCTAssertEqual(config.loggerKey, RUM_KEY, "loggerKey should be \(RUM_KEY)")
        XCTAssertEqual(config.logLevel, PRODUCTION_LOG_LEVEL, "logLevel should be \(PRODUCTION_LOG_LEVEL)")
        XCTAssertEqual(config.loggerUploadInterval, DEFAULT_LOGGER_UPLOAD_INTERVAL, "loggerUploadInterval should be \(DEFAULT_LOGGER_UPLOAD_INTERVAL)")
        
        XCTAssertEqual(config.rumEndpoint, FunPlusConfig.LOG_SERVER, "rumEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.rumTag, RUM_TAG, "rumTag should be \(RUM_TAG)")
        XCTAssertEqual(config.rumKey, RUM_KEY, "rumKey should be \(RUM_KEY)")
        XCTAssertEqual(config.rumUploadInterval, PRODUCTION_RUM_UPLOAD_INTERVAL, "rumUploadInterval should be \(PRODUCTION_RUM_UPLOAD_INTERVAL)")
        
        XCTAssertEqual(config.rumSampleRate, DEFAULT_RUM_SAMPLE_RATE, "rumSampleRate should be \(DEFAULT_RUM_SAMPLE_RATE)")
        XCTAssertTrue(config.rumEventWhitelist.isEmpty, "rumEventWhitelist should be empty")
        XCTAssertTrue(config.rumUserWhitelist.isEmpty, "rumUserWhitelist should be empty")
        XCTAssertTrue(config.rumUserBlacklist.isEmpty, "rumUserBlacklist should be empty")
        
        XCTAssertEqual(config.dataEndpoint, FunPlusConfig.LOG_SERVER, "dataEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.dataTag, APP_ID, "dataTag should be \(APP_ID)")
        XCTAssertEqual(config.dataKey, APP_KEY, "dataKey should be \(APP_KEY)")
        XCTAssertEqual(config.dataUploadInterval, PRODUCTION_DATA_UPLOAD_INTERVAL, "dataUploadInterval should be \(PRODUCTION_DATA_UPLOAD_INTERVAL)")
        
        XCTAssertTrue(config.dataAutoTraceSessionEvents, "dataAutoTraceSessionEvents should be true")
    }
    
    func testSettersChain() {
        // Given
        let loggerUploadInterval: Int64 = 10
        let rumUploadInterval: Int64 = 5
        let rumSampleRate = 0.8
        let rumEventWhitelist = ["level_up", "money_gain"]
        let rumUserWhitelist = ["user1", "user2", "user3"]
        let rumUserBlacklist = ["user4", "user5"]
        let dataUploadInterval: Int64 = 6
        let config = FunPlusConfig(appId: APP_ID, appKey: APP_KEY, rumTag: RUM_TAG, rumKey: RUM_KEY, environment: SANDBOX_ENV)
        
        // When
        config.setLoggerUploadInterval(loggerUploadInterval)
            .setRumUploadInterval(rumUploadInterval)
            .setRumSampleRate(rumSampleRate)
            .setRumEventWhitelist(rumEventWhitelist)
            .setRumUserWhitelist(rumUserWhitelist)
            .setRumUserBlacklist(rumUserBlacklist)
            .setDataUploadInterval(dataUploadInterval)
            .setDataAutoTraceSessionEvents(false)
            .end()
        
        // Then
        XCTAssertEqual(config.appId, APP_ID, "appId should be \(APP_ID)")
        XCTAssertEqual(config.appKey, APP_KEY, "appKey should be \(APP_KEY)")
        XCTAssertEqual(config.environment, SANDBOX_ENV, "environment should be \(SANDBOX_ENV)")
        
        XCTAssertEqual(config.loggerEndpoint, FunPlusConfig.LOG_SERVER, "loggerEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.loggerTag, RUM_TAG, "loggerTag should be \(RUM_TAG)")
        XCTAssertEqual(config.loggerKey, RUM_KEY, "loggerKey should be \(RUM_KEY)")
        XCTAssertEqual(config.logLevel, SANDBOX_LOG_LEVEL, "logLevel should be \(SANDBOX_LOG_LEVEL)")
        XCTAssertEqual(config.loggerUploadInterval, loggerUploadInterval, "loggerUploadInterval should be \(loggerUploadInterval)")
        
        XCTAssertEqual(config.rumEndpoint, FunPlusConfig.LOG_SERVER, "rumEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.rumTag, RUM_TAG, "rumTag should be \(RUM_TAG)")
        XCTAssertEqual(config.rumKey, RUM_KEY, "rumKey should be \(RUM_KEY)")
        XCTAssertEqual(config.rumUploadInterval, rumUploadInterval, "rumUploadInterval should be \(rumUploadInterval)")
        
        XCTAssertEqual(config.rumSampleRate, rumSampleRate, "rumSampleRate should be \(rumSampleRate)")
        XCTAssertEqual(config.rumEventWhitelist.count, 2, "rumEventWhitelist should contain 2 items")
        XCTAssertEqual(config.rumUserWhitelist.count, 3, "rumUserWhitelist should contain 3 items")
        XCTAssertEqual(config.rumUserBlacklist.count, 2, "rumUserBlacklist should contain 2 items")
        
        XCTAssertEqual(config.dataEndpoint, FunPlusConfig.LOG_SERVER, "dataEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.dataTag, APP_ID, "dataTag should be \(APP_ID)")
        XCTAssertEqual(config.dataKey, APP_KEY, "dataKey should be \(APP_KEY)")
        XCTAssertEqual(config.dataUploadInterval, dataUploadInterval, "dataUploadInterval should be \(dataUploadInterval)")
        
        XCTAssertFalse(config.dataAutoTraceSessionEvents, "dataAutoTraceSessionEvents should be false")
    }

}
