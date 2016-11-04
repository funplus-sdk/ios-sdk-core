//
//  RUMSamplerTests.swift
//  FunPlusSDKTests
//
//  Created by Yuankun Zhang on 5/30/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
import AdSupport
@testable import FunPlusSDK

class RUMSamplerTests: XCTestCase {
    
    func testSamplerInit() {
        // Given
        let sampleRate = 0.7
        let eventWhitelist = ["testevent1", "testevent2"]
        let userWhitelist = ["whiteuser1", "whiteuser2"]
        let userBlacklist = ["blackuser1"]
        
        // When
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: eventWhitelist,
            userWhitelist: userWhitelist,
            userBlacklist: userBlacklist
        )
        
        // Then
        XCTAssertEqual(sampler.sampleRate, 0.7, "sampleRate should be 0.7")
        XCTAssertEqual(sampler.eventWhitelist.count, 2, "eventWhitelist.count should be 2")
        XCTAssertEqual(sampler.userWhitelist.count, 2, "userWhitelist.count should be 2")
        XCTAssertEqual(sampler.userBlacklist.count, 1, "userBlacklist.count should be 1")
    }
    
    func testDeviceUniqueValue() {
        // Given
        let sampleRate = 0.7
        let eventWhitelist = ["testevent1", "testevent2"]
        let userWhitelist = ["whiteuser1", "whiteuser2"]
        let userBlacklist = ["blackuser1"]
        
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: eventWhitelist,
            userWhitelist: userWhitelist,
            userBlacklist: userBlacklist
        )
        
        // When
        let unique: String! = ASIdentifierManager.shared().advertisingIdentifier?.uuidString.md5()
        var countOfBitOne: Int64 = 0
        
        for c in unique.characters {
            var i = Int64(strtoul((String(c)), nil, 16))
            repeat {
                if i & 1 == 1 { countOfBitOne += 1 }
                i = i >> 1
            } while i != 0
        }
        
        let value = Double(countOfBitOne) / 128.0
        
        // Then
        XCTAssertEqual(sampler.deviceUniqueValue, value, "deviceUniqueValue should be \(value)")
    }

    func testShouldSendEventUserBlacklistTrue() {
        // Given
        let sampleRate = 1.0
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: [],
            userWhitelist: [],
            userBlacklist: ["block-this-user"]
        )
        
        let event: [String: Any] = [
            "event": "app_foreground" as Any,
            "user_id": "testuser" as Any
        ]
        
        // When
        let ret = sampler.shouldSendEvent(event)
        
        // Then
        XCTAssertTrue(ret, "ret should be true")
    }
    
    func testShouldSendEventUserBlacklistFalse() {
        // Given
        let sampleRate = 1.0
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: [],
            userWhitelist: [],
            userBlacklist: ["block-this-user"]
        )
        
        let event: [String: Any] = [
            "event": "app_foreground" as Any,
            "user_id": "block-this-user" as Any
        ]
        
        // When
        let ret = sampler.shouldSendEvent(event)
        
        // Then
        XCTAssertFalse(ret, "ret should be false")
    }
    
    func testShouldSendEventUserWhitelistTrue() {
        // Given
        let sampleRate = 1.0
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: [],
            userWhitelist: ["allow-this-user"],
            userBlacklist: ["block-this-user"]
        )
        
        let event: [String: Any] = [
            "event": "app_foreground" as Any,
            "user_id": "allow-this-user" as Any
        ]
        
        // When
        let ret = sampler.shouldSendEvent(event)
        
        // Then
        XCTAssertTrue(ret, "ret should be true")
    }
    
    func testShouldSendEventUserWhitelistFalse() {
        // Given
        let sampleRate = 0.0
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: [],
            userWhitelist: ["allow-this-user"],
            userBlacklist: []
        )
        
        let event: [String: Any] = [
            "event": "app_foreground" as Any,
            "user_id": "testuser" as Any
        ]
        
        // When
        let ret = sampler.shouldSendEvent(event)
        
        // Then
        XCTAssertFalse(ret, "ret should be false")
    }
    
    func testShouldSendEventEventWhitelistTrue() {
        // Given
        let sampleRate = 0.0
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: ["app_foreground"],
            userWhitelist: [],
            userBlacklist: []
        )
        
        let event: [String: Any] = [
            "event": "app_foreground" as Any,
            "user_id": "testuser" as Any
        ]
        
        // When
        let ret = sampler.shouldSendEvent(event)
        
        // Then
        XCTAssertTrue(ret, "ret should be true")
    }
    
    func testShouldSendEventEventWhitelistFalse() {
        // Given
        let sampleRate = 0.0
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: ["app_background"],
            userWhitelist: [],
            userBlacklist: []
        )
        
        let event: [String: Any] = [
            "event": "app_foreground" as Any,
            "user_id": "testuser" as Any
        ]
        
        // When
        let ret = sampler.shouldSendEvent(event)
        
        // Then
        XCTAssertFalse(ret, "ret should be false")
    }
    
    func testShouldSendEventSampleRateOne() {
        // Given
        let sampleRate = 1.0
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: [],
            userWhitelist: [],
            userBlacklist: []
        )
        
        let event: [String: Any] = [
            "event": "app_foreground" as Any,
            "user_id": "testuser" as Any
        ]
        
        // When
        let ret = sampler.shouldSendEvent(event)
        
        // Then
        XCTAssertTrue(ret, "ret should be true")
    }
    
    func testShouldSendEventSampleRateZero() {
        // Given
        let sampleRate = 0.0
        let sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: [],
            userWhitelist: [],
            userBlacklist: []
        )
        
        let event: [String: Any] = [
            "event": "app_foreground" as Any,
            "user_id": "testuser" as Any
        ]
        
        // When
        let ret = sampler.shouldSendEvent(event)
        
        // Then
        XCTAssertFalse(ret, "ret should be false")
    }

}
