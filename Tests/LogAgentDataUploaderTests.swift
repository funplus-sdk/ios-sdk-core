//
//  LogAgentDataUploaderTests.swift
//  FunPlusSDKTests
//
//  Created by Yuankun Zhang on 4/5/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class LogAgentDataUploaderTests: XCTestCase {
    
    let TIMEOUT = 30.0
    let ENDPOINT = "https://logagent.infra.funplus.net/log"
    let TAG = "test"
    let KEY = "funplus"
    
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()
    
    func testUpload() {
        // Given
        let testCount = 1024
        let uploader = LogAgentDataUploader(funPlusConfig: funPlusConfig, endpoint: ENDPOINT, tag: TAG, key: KEY)
        
        var dataQueue = [String]()
        
        for i in 1...testCount {
            dataQueue.append("message_\(i)")
        }
        
        let ex = expectation(description: "\(uploader)")
        
        var resultStatus: Bool!
        var resultTotal: Int!
        var resultUploaded: Int!
        
        // When
        uploader.upload(dataQueue) { (status, total, uploaded) in
            resultStatus = status
            resultTotal = total
            resultUploaded = uploaded
            
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertTrue(resultStatus, "status should be true")
        XCTAssertEqual(resultTotal, testCount, "total should be \(testCount)")
        XCTAssertEqual(resultUploaded, testCount, "uploaded should be \(testCount)")
    }
    
    func testUploadWithBadLogAgentTag() {
        // Given
        let testCount = 1024
        let uploader = LogAgentDataUploader(funPlusConfig: funPlusConfig, endpoint: ENDPOINT, tag: "badtag", key: "badkey")
        
        var dataQueue = [String]()
        
        for i in 1...testCount {
            dataQueue.append("message_\(i)")
        }
        
        let ex = expectation(description: "\(uploader)")
        
        var resultStatus: Bool!
        var resultTotal: Int!
        var resultUploaded: Int!
        
        // When
        uploader.upload(dataQueue) { (status, total, uploaded) in
            resultStatus = status
            resultTotal = total
            resultUploaded = uploaded
            
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertFalse(resultStatus, "status should be false")
        XCTAssertEqual(resultTotal, testCount, "total should be \(testCount)")
        XCTAssertEqual(resultUploaded, 0, "uploaded should be 0")
    }

    func testNetworkOff() {
        // Given
        let testCount = 1024
        let uploader = LogAgentDataUploader(funPlusConfig: funPlusConfig, endpoint: "network.off", tag: TAG, key: KEY)
        
        var dataQueue = [String]()
        
        for i in 1...testCount {
            dataQueue.append("message_\(i)")
        }
        
        let ex = expectation(description: "\(uploader)")
        
        var resultStatus: Bool!
        var resultTotal: Int!
        var resultUploaded: Int!
        
        // When
        uploader.upload(dataQueue) { (status, total, uploaded) in
            resultStatus = status
            resultTotal = total
            resultUploaded = uploaded
            
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertFalse(resultStatus, "status should be false")
        XCTAssertEqual(resultTotal, testCount, "total should be \(testCount)")
        XCTAssertEqual(resultUploaded, 0, "uploaded should be 0")
    }
}
