//
//  LoggerDataConsumerTests.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 17/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class LoggerDataConsumerTests: XCTestCase {

    let TIMEOUT = 30.0
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()
    
    override func setUp() {
        let consumer = LoggerDataConsumer(funPlusConfig: funPlusConfig)
        consumer.logAgentClient.dataQueue.removeAll()
    }
    
    func testConsume() {
        // Given
        let consumer = LoggerDataConsumer(funPlusConfig: funPlusConfig)
        let ex = expectation(description: "\(consumer)")
        
        // When
        getLogger().i("info message");
        getLogger().w("warn message");
        getLogger().e("error message");
        getLogger().wtf("fatal message");
        
        consumer.consume()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
//        XCTAssertEqual(consumer.logAgentClient.dataQueue.count, 4, "dataQueue.count should be 4")
    }
    
    func getLogger() -> Logger {
        return FunPlusFactory.getLogger(funPlusConfig: funPlusConfig)
    }

}
