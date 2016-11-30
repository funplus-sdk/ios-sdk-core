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
        let testCount = 100
        let uploader = LogAgentDataUploader(funPlusConfig: funPlusConfig, endpoint: ENDPOINT, tag: TAG, key: KEY)
        
        var dataQueue = [[String: Any]]()
        
        for i in 1...testCount {
            dataQueue.append(["message": "\(i)"])
        }
        
        let ex = expectation(description: "\(uploader)")
        
        var resultUploaded: Int!
        
        // When
        uploader.upload(data: &dataQueue) { (uploaded) in
            resultUploaded = uploaded
            
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(resultUploaded, testCount, "uploaded should be \(testCount)")
    }
    
    func testUploadWithBadLogAgentTag() {
        // Given
        let testCount = 1024
        let uploader = LogAgentDataUploader(funPlusConfig: funPlusConfig, endpoint: ENDPOINT, tag: "badtag", key: "badkey")
        
        var dataQueue = [[String: Any]]()
        
        for i in 1...testCount {
            dataQueue.append(["message": "\(i)"])
        }
        
        let ex = expectation(description: "\(uploader)")
        
        var resultUploaded: Int!
        
        // When
        uploader.upload(data: &dataQueue) { (uploaded) in
            resultUploaded = uploaded
            
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(resultUploaded, 0, "uploaded should be 0")
    }

    func testNetworkOff() {
        // Given
        let testCount = 1024
        let uploader = LogAgentDataUploader(funPlusConfig: funPlusConfig, endpoint: "network.off", tag: TAG, key: KEY)
        
        var dataQueue = [[String: Any]]()
        
        for i in 1...testCount {
            dataQueue.append(["message": "\(i)"])
        }
        
        let ex = expectation(description: "\(uploader)")
        
        var resultUploaded: Int!
        
        // When
        uploader.upload(data: &dataQueue) { (uploaded) in
            resultUploaded = uploaded
            
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertEqual(resultUploaded, 0, "uploaded should be 0")
    }
}
