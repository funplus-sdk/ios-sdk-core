//
//  LogAgentClientTests.swift
//  FunPlusSDKTests
//
//  Created by Yuankun Zhang on 3/29/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class LogAgentClientTests: XCTestCase {
    
    let TIMEOUT = 30.0
    let LABEL = "test-logger"
    let ENDPOINT = "https://logagent.infra.funplus.net/log"
    let TAG = "test"
    let KEY = "funplus"
    
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()
    
    override func tearDown() {
        let tmp = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        NSKeyedArchiver.archiveRootObject([:], toFile: tmp.archiveFilePath)
    }
    
    func testTraceWithBadUploader() {
        // Given
        let testCount = 10
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: "badkey")
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.dataQueue.count, testCount, "dataQueue.count should be \(testCount)")
    }

    func testTraceWithUploader() {
        // Given
        let testCount = 512
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            logger.upload()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(10 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.dataQueue.count, 0, "dataQueue.count should be 0")
    }

    func testTimedUpload() {
        // Given
        let testCount = 512
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY, uploadInterval: 2.0)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(10 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.dataQueue.count, 0, "dataQueue.count should be 0")
    }
 
    func testTimedUploadWhileTracing() {
        // Given
        let testCount = 512
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY, uploadInterval: 2.0)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            for i in 1...testCount {
                logger.trace("message_\(i)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(20 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.dataQueue.count, 0, "dataQueue.count should be \(0)")
    }

    func testArchive() {
        // Given
        let testCount = 512
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }

        (logger.serialQueue).async {
            logger.archive()
        }
        
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.dataQueue.count, 2 * testCount, "dataQueue.count should be \(2 * testCount)")
        
        let archivedData = NSKeyedUnarchiver.unarchiveObject(withFile: logger.archiveFilePath) as? [String]
        XCTAssertNotNil(archivedData, "archivedData should not be nil")
        XCTAssertEqual(archivedData!.count, testCount, "archivedData.count should be \(testCount)")
    }

    func testUnarchived() {
        // Given
        let testCount = 512
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }
        
        (logger.serialQueue).async {
            logger.archive()
        }
        
        let logger2 = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        
        for i in 1...testCount {
            logger2.trace("message_\(i)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger2.dataQueue.count, testCount, "dataQueue.count should be \(testCount)")
    }
 
    func testStopTimer() {
        // Given, When
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        let ex = expectation(description: "\(logger)")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            logger.stopTimer()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                ex.fulfill()
            }
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertNil(logger.timer, "timer should be nil")
    }

    func testAppDidBecomeActive() {
        // Given
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        let ex = expectation(description: "\(logger)")
        
        // When
        logger.appWillResignActive()
        logger.appDidBecomeActive()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertNotNil(logger.timer, "timer should not be nil")
    }
    
    func testAppWillResignActive() {
        // Given
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        let ex = expectation(description: "\(logger)")
        
        // When
        logger.appWillResignActive()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertNil(logger.timer, "timer should be nil")
    }
    
    func testAppDidEnterBackground() {
        // Given
        let testCount = 512
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY, uploadInterval: 0.0)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }
        
        logger.appDidEnterBackground()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(10 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.dataQueue.count, 0, "dataQueue.count should be 0")
    }

    func testAppWillEnterForeground() {
        // Given
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY, uploadInterval: 0.0)
        let ex = expectation(description: "\(logger)")
        
        // When
        logger.appDidEnterBackground()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            logger.appWillEnterForeground()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(10 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                ex.fulfill()
            }
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.backgroundTaskId, UIBackgroundTaskInvalid, "backgroundTaskId should be `UIBackgroundTaskInvalid`")
    }

    func testAppWillTerminate() {
        // Given
        let testCount = 512
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY, uploadInterval: 0.0)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }
        
        (logger.serialQueue).async {
            logger.appWillTerminate()
        }
        
        for i in 1...testCount {
            logger.trace("message_\(i)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(logger.dataQueue.count, 2 * testCount, "dataQueue.count should be \(2 * testCount)")
        
        let archivedData = NSKeyedUnarchiver.unarchiveObject(withFile: logger.archiveFilePath) as? [String]
        XCTAssertNotNil(archivedData, "archivedData should not be nil")
        XCTAssertEqual(archivedData!.count, testCount, "archivedData.count should be \(testCount)")
    }
    
}
