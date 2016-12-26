//
//  FunPlusRUMTests.swift
//  FunPlusSDKTests
//
//  Created by Yuankun Zhang on 5/19/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class RUMEventListener : RUMEventTracedListener {
    var traceHistory = [(eventString: String, traceTime: Date)]()
    var suppressHistory = [(eventString: String, traceTime: Date)]()
    
    func eventTraced(event: [String: Any]) {
        traceHistory.append(eventString: event.description, traceTime: Date())
    }
    
    func eventSuppressed(event: [String: Any]) {
        suppressHistory.append(eventString: event.description, traceTime: Date())
    }
}

class FunPlusRUMTests: XCTestCase {
    
    let TIMEOUT = 10.0
    
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()
    
    func testTrace() {
        // Given, When
        let tracer = FunPlusRUM(funPlusConfig: funPlusConfig)
        let listener = RUMEventListener()
        tracer.registerEventTracedListener(listener: listener)
        
        tracer.traceAppBackground()
        
        // Then
        XCTAssertEqual(listener.traceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(listener.traceHistory[0].eventString.contains("app_background"), "event should be app_background")
    }
    
    func testTraceNetworkSwtich() {
        // Given
        let tracer = FunPlusRUM(funPlusConfig: funPlusConfig)
        let listener = RUMEventListener()
        tracer.registerEventTracedListener(listener: listener)
        
        let sourceState = "3G"
        let currentState = "Wifi"
        
        // When
        tracer.traceNetworkSwitch(sourceState: sourceState, currentState: currentState)
        
        // Then
        XCTAssertEqual(listener.traceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(listener.traceHistory[0].eventString.contains("network_switch"), "event should be network_switch")
    }
    
    func testTraceServiceMonitoring() {
        // Given
        let tracer = FunPlusRUM(funPlusConfig: funPlusConfig)
        let listener = RUMEventListener()
        tracer.registerEventTracedListener(listener: listener)
        
        let serviceName = "testservice"
        let httpUrl = "http://url.com"
        let httpStatus = "200"
        let requestSize = 120
        let responseSize = 130
        let httpLatency: Int64 = 100
        let requestTs: Int64 = 0
        let responseTs: Int64 = 0
        let requestId = "id1234"
        let userId = "testuser"
        let serverId = "testserver"
        
        // When
        tracer.traceServiceMonitoring(
            serviceName: serviceName,
            httpUrl: httpUrl,
            httpStatus: httpStatus,
            requestSize: requestSize,
            responseSize: responseSize,
            httpLatency: httpLatency,
            requestTs: requestTs,
            responseTs: responseTs,
            requestId: requestId,
            targetUserId: userId,
            gameServerId: serverId
        )
        
        // Then
        XCTAssertEqual(listener.traceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(listener.traceHistory[0].eventString.contains("service_monitoring"), "event should be service_monitoring")
    }
    
    func testAppDidBecomeActive() {
        // Given
        let tracer = FunPlusRUM(funPlusConfig: funPlusConfig)
        let listener = RUMEventListener()
        tracer.registerEventTracedListener(listener: listener)
        
        let ex = expectation(description: "\(tracer)")
        
        // When
        tracer.appDidBacomeActive()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(listener.traceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(listener.traceHistory[0].eventString.contains("app_foreground"), "event should be app_foreground")
    }
    
    func testAppDidEnterBackground() {
        // Given
        let tracer = FunPlusRUM(funPlusConfig: funPlusConfig)
        let listener = RUMEventListener()
        tracer.registerEventTracedListener(listener: listener)
        
        let ex = expectation(description: "\(tracer)")
        
        // When
        tracer.appDidBacomeActive()
        tracer.appDidEnterBackground()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(listener.traceHistory.count, 2, "traceHistory.count should be 2")
        XCTAssertTrue(listener.traceHistory[0].eventString.contains("app_foreground"), "app_foreground should be app_foreground")
        XCTAssertTrue(listener.traceHistory[1].eventString.contains("app_background"), "app_foreground should be app_background")
    }
    
    func testSuppressHistory() {
        // Given
        let tracer = FunPlusRUM(funPlusConfig: FunPlusConfigFactory.rumSampleRateZeroConfig())
        let listener = RUMEventListener()
        tracer.registerEventTracedListener(listener: listener)
        
        // When
        tracer.traceAppBackground()
        
        // Then
        XCTAssertEqual(listener.suppressHistory.count, 1, "suppressHistory.count should be 1")
        XCTAssertTrue(listener.suppressHistory[0].eventString.contains("app_background"), "event should be app_background")
    }
}
