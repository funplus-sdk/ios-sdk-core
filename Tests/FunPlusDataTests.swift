//
//  FunPlusDataTests.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 23/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class FunPlusDataTests: XCTestCase {
    
    let TIMEOUT = 10.0
    
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()
    
    func testTrace() {
        // Given, When
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        tracer.traceSessionStart()
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(tracer.kpiTraceHistory[0].eventString.contains("session_start"), "event should be session_start")
    }
    
    func testTraceSessionStart() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceSessionStart()
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(tracer.kpiTraceHistory[0].eventString.contains("session_start"), "event should be session_start")
    }
    
    func testTraceSessionEnd() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceSessionEnd(sessionLength: 100)
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(tracer.kpiTraceHistory[0].eventString.contains("session_end"), "event should be session_end")
    }
    
    func testTraceNewUser() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceNewUser()
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(tracer.kpiTraceHistory[0].eventString.contains("new_user"), "event should be new_user")
    }
    
    func testTracePayment() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        let amount = 399.0
        let currency = "USD"
        let productId = "com.funplus.barnvoyage.jewelBox.270"
        let productName = "Jewel Box 270"
        let productType = "rc"
        let transactionId = "23533353"
        let paymentProcessor = "appleiap"
        let itemsReceived = [
            [
                "d_item_id": "4312",
                "d_item_name": "booster_butterfly",
                "d_item_type":"booster",
                "m_item_amount":"1",
                "d_item_class":"consumable"
            ]
        ]
        let currencyReceived = [
            [
                "d_currency_type": "rc",
                "m_currency_amount": "20"
            ],
            [
                "d_currency_type": "coins",
                "m_currency_amount": "2000"
            ]
        ]
        let currencyReceivedType = "gold"
        
        // When
        tracer.tracePayment(
            amount: amount,
            currency: currency,
            productId: productId,
            productName: productName,
            productType: productType,
            transactionId: transactionId,
            paymentProcessor: paymentProcessor,
            itemsReceived: itemsReceived.description,
            currencyReceived: currencyReceived.description,
            currencyReceivedType: currencyReceivedType
        )
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(tracer.kpiTraceHistory[0].eventString.contains("payment"), "event should be payment")
    }
    
    func testTraceCustom() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        let event: [String: Any] = [
            "event":        "level_up",
            "target_level": 10
        ]
        
        // When
        tracer.traceCustom(event: event)
        
        // Then
        XCTAssertEqual(tracer.customTraceHistory.count, 1, "traceHistory.count should be 1")
        XCTAssertTrue(tracer.customTraceHistory[0].eventString.contains("level_up"), "event should be level_up")
    }
}
