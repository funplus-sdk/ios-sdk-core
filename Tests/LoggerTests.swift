//
//  LoggerTests.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 12/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class LoggerTests: XCTestCase {
    
    let TIMEOUT = 30.0
    
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()

    func testTrace() {
        // Given
        let logger = Logger(funPlusConfig: funPlusConfig)
        let message = "yuankun.zhang"
        let logLevelString = "fatal"
        let function = "func"
        let file = "file"
        let line = 10
        let ex = expectation(description: "SDKLogger")
        
        // When
        logger.trace(message, logLevelString: logLevelString, function: function, file: file, line: line)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.logs.count, 1, "count should be 1")
        XCTAssertTrue(logger.logs.first?.contains(message) ?? false, "log should contain \(message)")
        XCTAssertTrue(logger.logs.first?.contains(logLevelString) ?? false, "log should contain \(logLevelString)")
    }

    func testTraceInfo() {
        // Given
        let logger = Logger(funPlusConfig: funPlusConfig)
        let message = "yuankun.zhang"
        let function = "func"
        let file = "file"
        let line = 10
        let ex = expectation(description: "SDKLogger")
        
        // When
        logger.i(message, function: function, file: file, line: line)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.logs.count, 1, "count should be 1")
        XCTAssertTrue(logger.logs.first?.contains(message) ?? false, "log should contain \(message)")
        XCTAssertTrue(logger.logs.first?.contains("INFO") ?? false, "log should contain INFO")
    }
    

    func testTraceWarn() {
        // Given
        let logger = Logger(funPlusConfig: funPlusConfig)
        let message = "yuankun.zhang"
        let function = "func"
        let file = "file"
        let line = 10
        let ex = expectation(description: "SDKLogger")
        
        // When
        logger.w(message, function: function, file: file, line: line)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.logs.count, 1, "count should be 1")
        XCTAssertTrue(logger.logs.first?.contains(message) ?? false, "log should contain \(message)")
        XCTAssertTrue(logger.logs.first?.contains("WARN") ?? false, "log should contain WARN")
    }

    func testTraceError() {
        // Given
        let logger = Logger(funPlusConfig: funPlusConfig)
        let message = "yuankun.zhang"
        let function = "func"
        let file = "file"
        let line = 10
        let ex = expectation(description: "SDKLogger")
        
        // When
        logger.e(message, function: function, file: file, line: line)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.logs.count, 1, "count should be 1")
        XCTAssertTrue(logger.logs.first?.contains(message) ?? false, "log should contain \(message)")
        XCTAssertTrue(logger.logs.first?.contains("ERROR") ?? false, "log should contain ERROR")
    }
    
    func testTraceWtf() {
        // Given
        let logger = Logger(funPlusConfig: funPlusConfig)
        let message = "yuankun.zhang"
        let function = "func"
        let file = "file"
        let line = 10
        let ex = expectation(description: "SDKLogger")
        
        // When
        logger.wtf(message, function: function, file: file, line: line)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.logs.count, 1, "count should be 1")
        XCTAssertTrue(logger.logs.first?.contains(message) ?? false, "log should contain \(message)")
        XCTAssertTrue(logger.logs.first?.contains("FATAL") ?? false, "log should contain FATAL")
    }


}
