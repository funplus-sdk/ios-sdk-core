//
//  OCExposerTests.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 21/11/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class OCExposerTests: XCTestCase {
    
    let APP_ID = "test"
    let APP_KEY = "funpuls"
    let RUM_TAG = "test"
    let RUM_KEY = "funplus"
    let ENV = "sandbox"
    
    func testInstallWithConfigValues() {
        // Given
        let loggerUploadInterval: Int64 = 10
        let rumUploadInterval: Int64 = 5
        let rumSampleRate: Double = 0.8
        let rumEventWhitelistString = "[\"level_up\", \"money_gain\"]"
        let rumUserWhitelistString = "[\"user1\", \"user2\", \"user3\"]"
        let rumUserBlacklistString = "[\"user4\", \"user5\"]"
        let dataUploadInterval: Int64 = 6
        let dataAutoTraceSessionEvents = false
        
        // When
        OCExposer.install(
            appId: APP_ID,
            appKey: APP_KEY,
            rumTag: RUM_TAG,
            rumKey: RUM_KEY,
            environment: ENV,
            loggerUploadInterval: loggerUploadInterval,
            rumUploadInterval: rumUploadInterval,
            rumSampleRate: rumSampleRate,
            rumEventWhitelistString: rumEventWhitelistString,
            rumUserWhitelistString: rumUserWhitelistString,
            rumUserBlacklistString: rumUserBlacklistString,
            dataUploadInterval: dataUploadInterval,
            dataAutoTraceSessionEvents: dataAutoTraceSessionEvents)
        
        // Then
        let config = FunPlusSDK.shared.funPlusConfig
        
        XCTAssertEqual(config.appId, APP_ID, "appId should be \(APP_ID)")
        XCTAssertEqual(config.appKey, APP_KEY, "appKey should be \(APP_KEY)")
        XCTAssertEqual(config.environment, .sandbox, "environment should be sandbox")
        
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
        
        XCTAssertFalse(config.dataAutoTraceSessionEvents, "dataAutoTraceSessionEvents should be false")
    }
    
}
