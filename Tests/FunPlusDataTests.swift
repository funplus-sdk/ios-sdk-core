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
        let event = tracer.kpiTraceHistory[0].eventString
        
        XCTAssertTrue(event.contains("event"), "event should be contained")
        XCTAssertTrue(event.contains("session_start"), "session_start should be contained")
        XCTAssertTrue(event.contains("data_version"), "data_version should be contained")
        XCTAssertTrue(event.contains("2.0"), "2.0 should be contained")
        XCTAssertTrue(event.contains("app_id"), "app_id should be contained")
        XCTAssertTrue(event.contains("ts"), "ts should be contained")
        XCTAssertTrue(event.contains("user_id"), "user_id should be contained")
        XCTAssertTrue(event.contains("session_id"), "session_id should be contained")
        XCTAssertTrue(event.contains("properties"), "properties should be contained")
        XCTAssertTrue(event.contains("app_version"), "app_version should be contained")
        XCTAssertTrue(event.contains("os"), "os should be contained")
        XCTAssertTrue(event.contains("os_version"), "os_version should be contained")
        XCTAssertTrue(event.contains("device"), "device should be contained")
        XCTAssertTrue(event.contains("lang"), "lang should be contained")
        XCTAssertTrue(event.contains("install_ts"), "install_ts should be contained")
    }
    
    func testTraceSessionStart() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceSessionStart()
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.kpiTraceHistory[0].eventString
        
        XCTAssertTrue(event.contains("event"), "event should be contained")
        XCTAssertTrue(event.contains("session_start"), "session_start should be contained")
        XCTAssertTrue(event.contains("data_version"), "data_version should be contained")
        XCTAssertTrue(event.contains("2.0"), "2.0 should be contained")
        XCTAssertTrue(event.contains("app_id"), "app_id should be contained")
        XCTAssertTrue(event.contains("ts"), "ts should be contained")
        XCTAssertTrue(event.contains("user_id"), "user_id should be contained")
        XCTAssertTrue(event.contains("session_id"), "session_id should be contained")
        XCTAssertTrue(event.contains("properties"), "properties should be contained")
        XCTAssertTrue(event.contains("app_version"), "app_version should be contained")
        XCTAssertTrue(event.contains("os"), "os should be contained")
        XCTAssertTrue(event.contains("os_version"), "os_version should be contained")
        XCTAssertTrue(event.contains("device"), "device should be contained")
        XCTAssertTrue(event.contains("lang"), "lang should be contained")
        XCTAssertTrue(event.contains("install_ts"), "install_ts should be contained")
    }
    
    func testTraceSessionEnd() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceSessionEnd(sessionLength: 100)
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.kpiTraceHistory[0].eventString
        
        XCTAssertTrue(event.contains("event"), "event should be contained")
        XCTAssertTrue(event.contains("session_end"), "session_end should be contained")
        XCTAssertTrue(event.contains("data_version"), "data_version should be contained")
        XCTAssertTrue(event.contains("2.0"), "2.0 should be contained")
        XCTAssertTrue(event.contains("app_id"), "app_id should be contained")
        XCTAssertTrue(event.contains("ts"), "ts should be contained")
        XCTAssertTrue(event.contains("user_id"), "user_id should be contained")
        XCTAssertTrue(event.contains("session_id"), "session_id should be contained")
        XCTAssertTrue(event.contains("properties"), "properties should be contained")
        XCTAssertTrue(event.contains("app_version"), "app_version should be contained")
        XCTAssertTrue(event.contains("os"), "os should be contained")
        XCTAssertTrue(event.contains("os_version"), "os_version should be contained")
        XCTAssertTrue(event.contains("device"), "device should be contained")
        XCTAssertTrue(event.contains("lang"), "lang should be contained")
        XCTAssertTrue(event.contains("install_ts"), "install_ts should be contained")
    }
    
    func testTraceNewUser() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceNewUser()
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.kpiTraceHistory[0].eventString
        
        XCTAssertTrue(event.contains("event"), "event should be contained")
        XCTAssertTrue(event.contains("new_user"), "new_user should be contained")
        XCTAssertTrue(event.contains("data_version"), "data_version should be contained")
        XCTAssertTrue(event.contains("2.0"), "2.0 should be contained")
        XCTAssertTrue(event.contains("app_id"), "app_id should be contained")
        XCTAssertTrue(event.contains("ts"), "ts should be contained")
        XCTAssertTrue(event.contains("user_id"), "user_id should be contained")
        XCTAssertTrue(event.contains("session_id"), "session_id should be contained")
        XCTAssertTrue(event.contains("properties"), "properties should be contained")
        XCTAssertTrue(event.contains("app_version"), "app_version should be contained")
        XCTAssertTrue(event.contains("os"), "os should be contained")
        XCTAssertTrue(event.contains("os_version"), "os_version should be contained")
        XCTAssertTrue(event.contains("device"), "device should be contained")
        XCTAssertTrue(event.contains("lang"), "lang should be contained")
        XCTAssertTrue(event.contains("install_ts"), "install_ts should be contained")
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
        let itemsReceived = "[{\"d_item_id\": \"4312\", \"d_item_name\": \"booster_butterfly\", \"d_item_name\": \"booster_butterfly\", \"d_item_type\":\"booster\",\"m_item_amount\":\"1\",\"d_item_class\":\"consumable\"}]"
        let currencyReceived = "[{\"d_currency_type\": \"rc\", \"m_currency_amount\": \"20\"}, {\"d_currency_type\": \"coins\", \"m_currency_amount\": \"2000\"}]"
        
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
            currencyReceived: currencyReceived.description
        )
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.kpiTraceHistory[0].eventString
        
        XCTAssertTrue(event.contains("event"), "event should be contained")
        XCTAssertTrue(event.contains("payment"), "payment should be contained")
        XCTAssertTrue(event.contains("data_version"), "data_version should be contained")
        XCTAssertTrue(event.contains("2.0"), "2.0 should be contained")
        XCTAssertTrue(event.contains("app_id"), "app_id should be contained")
        XCTAssertTrue(event.contains("ts"), "ts should be contained")
        XCTAssertTrue(event.contains("user_id"), "user_id should be contained")
        XCTAssertTrue(event.contains("session_id"), "session_id should be contained")
        XCTAssertTrue(event.contains("properties"), "properties should be contained")
        XCTAssertTrue(event.contains("app_version"), "app_version should be contained")
        XCTAssertTrue(event.contains("os"), "os should be contained")
        XCTAssertTrue(event.contains("os_version"), "os_version should be contained")
        XCTAssertTrue(event.contains("device"), "device should be contained")
        XCTAssertTrue(event.contains("lang"), "lang should be contained")
        XCTAssertTrue(event.contains("amount"), "amount should be contained")
        XCTAssertTrue(event.contains("currency"), "currency should be contained")
        XCTAssertTrue(event.contains("iap_product_id"), "iap_product_id should be contained")
        XCTAssertTrue(event.contains("iap_product_name"), "iap_product_name should be contained")
        XCTAssertTrue(event.contains("iap_product_type"), "iap_product_type should be contained")
        XCTAssertTrue(event.contains("transaction_id"), "transaction_id should be contained")
        XCTAssertTrue(event.contains("payment_processor"), "payment_processor should be contained")
        XCTAssertTrue(event.contains("c_items_received"), "c_items_received should be contained")
        XCTAssertTrue(event.contains("c_currency_received"), "c_currency_received should be contained")
    }
    
    func testTraceCustom() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        let customEvent: [String: Any] = [
            "event":        "plant",
            "data_version": "2.0",
            "app_id":       "sdk.global.prod",
            "user_id":      "822b3aaa877bcecfc99b28f34521d208",
            "session_id":   "591da20f1f7b5ec3f44cade9fea93516_1457663293",
            "ts":           "1457664466725",
            
            "properties": [
                "app_version":  "1.0.8",
                "os":           "ios",
                "os_version":   "10.1",
                "device":       "iPhone 7 Plus",
                "lang":         "en",
                "install_ts":   1456195734
            ]
        ]
        
        // When
        tracer.traceCustom(event: customEvent)
        
        // Then
        XCTAssertEqual(tracer.customTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.customTraceHistory[0].eventString
        
        XCTAssertTrue(event.contains("event"), "event should be contained")
        XCTAssertTrue(event.contains("plant"), "plant should be contained")
        XCTAssertTrue(event.contains("data_version"), "data_version should be contained")
        XCTAssertTrue(event.contains("2.0"), "2.0 should be contained")
        XCTAssertTrue(event.contains("app_id"), "app_id should be contained")
        XCTAssertTrue(event.contains("ts"), "ts should be contained")
        XCTAssertTrue(event.contains("user_id"), "user_id should be contained")
        XCTAssertTrue(event.contains("session_id"), "session_id should be contained")
        XCTAssertTrue(event.contains("properties"), "properties should be contained")
        XCTAssertTrue(event.contains("app_version"), "app_version should be contained")
        XCTAssertTrue(event.contains("os"), "os should be contained")
        XCTAssertTrue(event.contains("os_version"), "os_version should be contained")
        XCTAssertTrue(event.contains("device"), "device should be contained")
        XCTAssertTrue(event.contains("lang"), "lang should be contained")
        XCTAssertTrue(event.contains("install_ts"), "install_ts should be contained")
    }
    
    func testTraceCustomEventWithNameAndProperties() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        let eventName = "plant"
        let properties: [String: Any] = [
            "m1": [
                "key":      "amount",
                "value":    1
            ]
        ]
        
        // When
        tracer.traceCustom(eventName: eventName, properties: properties)
        
        // Then
        XCTAssertEqual(tracer.customTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.customTraceHistory[0].eventString
        
        XCTAssertTrue(event.contains("event"), "event should be contained")
        XCTAssertTrue(event.contains("plant"), "plant should be contained")
        XCTAssertTrue(event.contains("data_version"), "data_version should be contained")
        XCTAssertTrue(event.contains("2.0"), "2.0 should be contained")
        XCTAssertTrue(event.contains("app_id"), "app_id should be contained")
        XCTAssertTrue(event.contains("ts"), "ts should be contained")
        XCTAssertTrue(event.contains("user_id"), "user_id should be contained")
        XCTAssertTrue(event.contains("session_id"), "session_id should be contained")
        XCTAssertTrue(event.contains("properties"), "properties should be contained")
        XCTAssertTrue(event.contains("app_version"), "app_version should be contained")
        XCTAssertTrue(event.contains("os"), "os should be contained")
        XCTAssertTrue(event.contains("os_version"), "os_version should be contained")
        XCTAssertTrue(event.contains("device"), "device should be contained")
        XCTAssertTrue(event.contains("lang"), "lang should be contained")
        XCTAssertTrue(event.contains("install_ts"), "install_ts should be contained")
    }
}
