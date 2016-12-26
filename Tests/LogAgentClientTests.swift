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
            logger.trace(entry: ["message": "\(i)"])
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
        let testCount = 100
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace(entry: ["message": "\(i)"])
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
        let testCount = 100
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY, uploadInterval: 2.0)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace(entry: ["message": "\(i)"])
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
        let testCount = 100
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY, uploadInterval: 2.0)
        let ex = expectation(description: "\(logger)")
        
        // When
        for i in 1...testCount {
            logger.trace(entry: ["message": "\(i)"])
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            for i in 1...testCount {
                logger.trace(entry: ["message": "\(i)"])
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
            logger.trace(entry: ["message": "\(i)"])
        }

        logger.archive()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }

        waitForExpectations(timeout: TIMEOUT, handler: nil)

        // Then
        let archivedData = NSKeyedUnarchiver.unarchiveObject(withFile: logger.archiveFilePath) as? [[String: Any]]
        XCTAssertNotNil(archivedData, "archivedData should not be nil")
        XCTAssertEqual(archivedData!.count, testCount, "archivedData.count should be \(testCount)")
    }

    func testUnarchived() {
        // Given
        var array = [[String: Any]]()
        let testCount = 512
        let ex = expectation(description: "logger")

        // When
        for i in 1...testCount {
            array.append(["message": "\(i)"])
        }

        let archiveFilePath = { () -> String in 
            let filename = "logger-archive-test-logger.log"
            let libraryDirectory = FileManager().urls(for: .libraryDirectory, in: .userDomainMask).last!
            return libraryDirectory.appendingPathComponent(filename).path
        }()
        
        NSKeyedArchiver.archiveRootObject(array, toFile: archiveFilePath)

        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }

        waitForExpectations(timeout: TIMEOUT, handler: nil)

        // Then
        XCTAssertEqual(logger.dataQueue.count, testCount, "dataQueue.count should be \(testCount)")
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
    
    func testAppWillTerminate() {
        // Given
        let testCount = 512
        let logger = LogAgentClient(funPlusConfig: funPlusConfig, label: LABEL, endpoint: ENDPOINT, tag: TAG, key: KEY, uploadInterval: 0.0)
        let ex = expectation(description: "\(logger)")

        // When
        for i in 1...testCount {
            logger.trace(entry: ["message": "\(i)"])
        }

        logger.appWillTerminate()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }

        waitForExpectations(timeout: TIMEOUT, handler: nil)

        // Then
        let archivedData = NSKeyedUnarchiver.unarchiveObject(withFile: logger.archiveFilePath) as? [[String: Any]]
        XCTAssertNotNil(archivedData, "archivedData should not be nil")
        XCTAssertEqual(archivedData!.count, testCount, "archivedData.count should be \(testCount)")
    }
    
}
