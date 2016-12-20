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
    let ENV = SDKEnvironment.sandbox
    
    let DEFAULT_LOGGER_UPLOAD_INTERVAL: Int64 = 60
    let DEFAULT_RUM_UPLOAD_INTERVAL: Int64 = 30
    let DEFAULT_DATA_UPLOAD_INTERVAL: Int64 = 30
    let DEFAULT_RUM_SAMPLE_RATE = 1.0
    
    func testDefaultValuesForSandboxEnvironment() {
        // Given, When
        let config = FunPlusConfig(appId: APP_ID, appKey: APP_KEY, rumTag: RUM_TAG, rumKey: RUM_KEY, environment: ENV)
        
        // Then
        XCTAssertEqual(config.appId, APP_ID, "appId should be \(APP_ID)")
        XCTAssertEqual(config.appKey, APP_KEY, "appKey should be \(APP_KEY)")
        XCTAssertEqual(config.environment, ENV, "environment should be \(ENV)")
        
        XCTAssertEqual(config.loggerEndpoint, FunPlusConfig.LOG_SERVER, "loggerEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.loggerTag, RUM_TAG, "loggerTag should be \(RUM_TAG)")
        XCTAssertEqual(config.loggerKey, RUM_KEY, "loggerKey should be \(RUM_KEY)")
        XCTAssertEqual(config.logLevel, LogLevel.info, "logLevel should be \(LogLevel.info)")
        XCTAssertEqual(config.loggerUploadInterval, DEFAULT_LOGGER_UPLOAD_INTERVAL, "loggerUploadInterval should be \(DEFAULT_LOGGER_UPLOAD_INTERVAL)")
        
        XCTAssertEqual(config.rumEndpoint, FunPlusConfig.LOG_SERVER, "rumEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.rumTag, RUM_TAG, "rumTag should be \(RUM_TAG)")
        XCTAssertEqual(config.rumKey, RUM_KEY, "rumKey should be \(RUM_KEY)")
        XCTAssertEqual(config.rumUploadInterval, DEFAULT_RUM_UPLOAD_INTERVAL, "rumUploadInterval should be \(DEFAULT_RUM_UPLOAD_INTERVAL)")
        
        XCTAssertEqual(config.rumSampleRate, DEFAULT_RUM_SAMPLE_RATE, "rumSampleRate should be \(DEFAULT_RUM_SAMPLE_RATE)")
        XCTAssertTrue(config.rumEventWhitelist.isEmpty, "rumEventWhitelist should be empty")
        XCTAssertTrue(config.rumUserWhitelist.isEmpty, "rumUserWhitelist should be empty")
        XCTAssertTrue(config.rumUserBlacklist.isEmpty, "rumUserBlacklist should be empty")
        
        XCTAssertEqual(config.dataEndpoint, FunPlusConfig.LOG_SERVER, "dataEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.dataTag, APP_ID, "dataTag should be \(APP_ID)")
        XCTAssertEqual(config.dataKey, APP_KEY, "dataKey should be \(APP_KEY)")
        XCTAssertEqual(config.dataUploadInterval, DEFAULT_DATA_UPLOAD_INTERVAL, "dataUploadInterval should be \(DEFAULT_DATA_UPLOAD_INTERVAL)")
        
        XCTAssertTrue(config.autoSessionStartAndEnd, "autoSessionStartAndEnd should be true")
    }
    
    func testDefaultValuesForProductionEnvironment() {
        // Given, When
        let config = FunPlusConfig(appId: APP_ID, appKey: APP_KEY, rumTag: RUM_TAG, rumKey: RUM_KEY, environment: ENV)
        
        // Then
        XCTAssertEqual(config.appId, APP_ID, "appId should be \(APP_ID)")
        XCTAssertEqual(config.appKey, APP_KEY, "appKey should be \(APP_KEY)")
        XCTAssertEqual(config.environment, ENV, "environment should be \(ENV)")
        
        XCTAssertEqual(config.loggerEndpoint, FunPlusConfig.LOG_SERVER, "loggerEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.loggerTag, RUM_TAG, "loggerTag should be \(RUM_TAG)")
        XCTAssertEqual(config.loggerKey, RUM_KEY, "loggerKey should be \(RUM_KEY)")
        XCTAssertEqual(config.logLevel, LogLevel.info, "logLevel should be \(LogLevel.error)")
        XCTAssertEqual(config.loggerUploadInterval, DEFAULT_LOGGER_UPLOAD_INTERVAL, "loggerUploadInterval should be \(DEFAULT_LOGGER_UPLOAD_INTERVAL)")
        
        XCTAssertEqual(config.rumEndpoint, FunPlusConfig.LOG_SERVER, "rumEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.rumTag, RUM_TAG, "rumTag should be \(RUM_TAG)")
        XCTAssertEqual(config.rumKey, RUM_KEY, "rumKey should be \(RUM_KEY)")
        XCTAssertEqual(config.rumUploadInterval, DEFAULT_RUM_UPLOAD_INTERVAL, "rumUploadInterval should be \(DEFAULT_RUM_UPLOAD_INTERVAL)")
        
        XCTAssertEqual(config.rumSampleRate, DEFAULT_RUM_SAMPLE_RATE, "rumSampleRate should be \(DEFAULT_RUM_SAMPLE_RATE)")
        XCTAssertTrue(config.rumEventWhitelist.isEmpty, "rumEventWhitelist should be empty")
        XCTAssertTrue(config.rumUserWhitelist.isEmpty, "rumUserWhitelist should be empty")
        XCTAssertTrue(config.rumUserBlacklist.isEmpty, "rumUserBlacklist should be empty")
        
        XCTAssertEqual(config.dataEndpoint, FunPlusConfig.LOG_SERVER, "dataEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.dataTag, APP_ID, "dataTag should be \(APP_ID)")
        XCTAssertEqual(config.dataKey, APP_KEY, "dataKey should be \(APP_KEY)")
        XCTAssertEqual(config.dataUploadInterval, DEFAULT_DATA_UPLOAD_INTERVAL, "dataUploadInterval should be \(DEFAULT_DATA_UPLOAD_INTERVAL)")
        
        XCTAssertTrue(config.autoSessionStartAndEnd, "autoSessionStartAndEnd should be true")
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
        let config = FunPlusConfig(appId: APP_ID, appKey: APP_KEY, rumTag: RUM_TAG, rumKey: RUM_KEY, environment: ENV)
        
        // When
        config.setLoggerUploadInterval(loggerUploadInterval)
            .setRumUploadInterval(rumUploadInterval)
            .setRumSampleRate(rumSampleRate)
            .setRumEventWhitelist(rumEventWhitelist)
            .setRumUserWhitelist(rumUserWhitelist)
            .setRumUserBlacklist(rumUserBlacklist)
            .setDataUploadInterval(dataUploadInterval)
            .setAutoSessionStartAndEnd(false)
            .end()
        
        // Then
        XCTAssertEqual(config.appId, APP_ID, "appId should be \(APP_ID)")
        XCTAssertEqual(config.appKey, APP_KEY, "appKey should be \(APP_KEY)")
        XCTAssertEqual(config.environment, ENV, "environment should be \(ENV)")
        
        XCTAssertEqual(config.loggerEndpoint, FunPlusConfig.LOG_SERVER, "loggerEndpoint should be \(FunPlusConfig.LOG_SERVER)")
        XCTAssertEqual(config.loggerTag, RUM_TAG, "loggerTag should be \(RUM_TAG)")
        XCTAssertEqual(config.loggerKey, RUM_KEY, "loggerKey should be \(RUM_KEY)")
        XCTAssertEqual(config.logLevel, LogLevel.info, "logLevel should be \(LogLevel.info)")
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
        
        XCTAssertFalse(config.autoSessionStartAndEnd, "autoSessionStartAndEnd should be false")
    }

}
