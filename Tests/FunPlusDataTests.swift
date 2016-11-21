//
//  FunPlusDataTests.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 23/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

private extension String {
    func toJsonObject() -> Any? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            print("[FunPlusSDK] unable to convert string to JSON object")
            return nil
        }
    }
}

class FunPlusDataTests: XCTestCase {
    
    let TIMEOUT = 10.0
    
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()
    
    func testTrace() {
        // Given, When
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        tracer.traceSessionStart()
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.kpiTraceHistory[0].eventString.toJsonObject() as! [String: Any]
        
        XCTAssertEqual(event["event"] as? String, "session_start", "event should be session_start")
        XCTAssertEqual(event["data_version"] as? String, "2.0", "data_version should be 2.0")
        XCTAssertNotNil(event["app_id"], "app_id should not be nil")
        XCTAssertNotNil(event["ts"], "ts should not be nil")
        XCTAssertNotNil(event["user_id"], "user_id should not be nil")
        XCTAssertNotNil(event["session_id"], "session_id should not be nil")
        XCTAssertNotNil(event["properties"] as? [String: Any], "properties should not be nil")
        
        let properties = event["properties"] as! [String: Any]
        
        XCTAssertNotNil(properties["app_version"], "app_version should not be nil")
        XCTAssertNotNil(properties["os"], "os should not be nil")
        XCTAssertNotNil(properties["os_version"], "os_version should not be nil")
        XCTAssertNotNil(properties["device"], "device should not be nil")
        XCTAssertNotNil(properties["lang"], "lang should not be nil")
        XCTAssertNotNil(properties["install_ts"], "install_ts should not be nil")
    }
    
    func testTraceSessionStart() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceSessionStart()
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.kpiTraceHistory[0].eventString.toJsonObject() as! [String: Any]
        
        XCTAssertEqual(event["event"] as? String, "session_start", "event should be session_start")
        XCTAssertEqual(event["data_version"] as? String, "2.0", "data_version should be 2.0")
        XCTAssertNotNil(event["app_id"], "app_id should not be nil")
        XCTAssertNotNil(event["ts"], "ts should not be nil")
        XCTAssertNotNil(event["user_id"], "user_id should not be nil")
        XCTAssertNotNil(event["session_id"], "session_id should not be nil")
        XCTAssertNotNil(event["properties"] as? [String: Any], "properties should not be nil")
        
        let properties = event["properties"] as! [String: Any]
        
        XCTAssertNotNil(properties["app_version"], "app_version should not be nil")
        XCTAssertNotNil(properties["os"], "os should not be nil")
        XCTAssertNotNil(properties["os_version"], "os_version should not be nil")
        XCTAssertNotNil(properties["device"], "device should not be nil")
        XCTAssertNotNil(properties["lang"], "lang should not be nil")
        XCTAssertNotNil(properties["install_ts"], "install_ts should not be nil")
    }
    
    func testTraceSessionEnd() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceSessionEnd(sessionLength: 100)
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.kpiTraceHistory[0].eventString.toJsonObject() as! [String: Any]
        
        XCTAssertEqual(event["event"] as? String, "session_end", "event should be session_end")
        XCTAssertEqual(event["data_version"] as? String, "2.0", "data_version should be 2.0")
        XCTAssertNotNil(event["app_id"], "app_id should not be nil")
        XCTAssertNotNil(event["ts"], "ts should not be nil")
        XCTAssertNotNil(event["user_id"], "user_id should not be nil")
        XCTAssertNotNil(event["session_id"], "session_id should not be nil")
        XCTAssertNotNil(event["properties"] as? [String: Any], "properties should not be nil")
        
        let properties = event["properties"] as! [String: Any]
        
        XCTAssertNotNil(properties["app_version"], "app_version should not be nil")
        XCTAssertNotNil(properties["os"], "os should not be nil")
        XCTAssertNotNil(properties["os_version"], "os_version should not be nil")
        XCTAssertNotNil(properties["device"], "device should not be nil")
        XCTAssertNotNil(properties["lang"], "lang should not be nil")
        XCTAssertNotNil(properties["install_ts"], "install_ts should not be nil")
    }
    
    func testTraceNewUser() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        
        // When
        tracer.traceNewUser()
        
        // Then
        XCTAssertEqual(tracer.kpiTraceHistory.count, 1, "traceHistory.count should be 1")
        let event = tracer.kpiTraceHistory[0].eventString.toJsonObject() as! [String: Any]
        
        XCTAssertEqual(event["event"] as? String, "new_user", "event should be new_user")
        XCTAssertEqual(event["data_version"] as? String, "2.0", "data_version should be 2.0")
        XCTAssertNotNil(event["app_id"], "app_id should not be nil")
        XCTAssertNotNil(event["ts"], "ts should not be nil")
        XCTAssertNotNil(event["user_id"], "user_id should not be nil")
        XCTAssertNotNil(event["session_id"], "session_id should not be nil")
        XCTAssertNotNil(event["properties"] as? [String: Any], "properties should not be nil")
        
        let properties = event["properties"] as! [String: Any]
        
        XCTAssertNotNil(properties["app_version"], "app_version should not be nil")
        XCTAssertNotNil(properties["os"], "os should not be nil")
        XCTAssertNotNil(properties["os_version"], "os_version should not be nil")
        XCTAssertNotNil(properties["device"], "device should not be nil")
        XCTAssertNotNil(properties["lang"], "lang should not be nil")
        XCTAssertNotNil(properties["install_ts"], "install_ts should not be nil")
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
        let event = tracer.kpiTraceHistory[0].eventString.toJsonObject() as! [String: Any]
        
        XCTAssertEqual(event["event"] as? String, "payment", "event should be payment")
        XCTAssertEqual(event["data_version"] as? String, "2.0", "data_version should be 2.0")
        XCTAssertNotNil(event["app_id"], "app_id should not be nil")
        XCTAssertNotNil(event["ts"], "ts should not be nil")
        XCTAssertNotNil(event["user_id"], "user_id should not be nil")
        XCTAssertNotNil(event["session_id"], "session_id should not be nil")
        XCTAssertNotNil(event["properties"] as? [String: Any], "properties should not be nil")
        
        let properties = event["properties"] as! [String: Any]
        
        XCTAssertNotNil(properties["app_version"], "app_version should not be nil")
        XCTAssertNotNil(properties["os"], "os should not be nil")
        XCTAssertNotNil(properties["os_version"], "os_version should not be nil")
        XCTAssertNotNil(properties["device"], "device should not be nil")
        XCTAssertNotNil(properties["lang"], "lang should not be nil")
        XCTAssertNotNil(properties["install_ts"], "install_ts should not be nil")
        XCTAssertNotNil(properties["amount"], "amount should not be nil")
        XCTAssertNotNil(properties["currency"], "currency should not be nil")
        XCTAssertNotNil(properties["iap_product_id"], "product_id should not be nil")
        XCTAssertNotNil(properties["iap_product_name"], "product_name should not be nil")
        XCTAssertNotNil(properties["iap_product_type"], "product_type should not be nil")
        XCTAssertNotNil(properties["transaction_id"], "transaction_id should not be nil")
        XCTAssertNotNil(properties["payment_processor"], "payment_processor should not be nil")
        XCTAssertNotNil(properties["c_items_received"], "c_items_received should not be nil")
        XCTAssertNotNil(properties["c_currency_received"], "c_currency_received should not be nil")
    }
    
    func testTraceCustom() {
        // Given
        let tracer = FunPlusData(funPlusConfig: funPlusConfig)
        let event: [String: Any] = [
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
        tracer.traceCustom(event: event)
        
        // Then
        XCTAssertEqual(tracer.customTraceHistory.count, 1, "traceHistory.count should be 1")
        let evt = tracer.customTraceHistory[0].eventString.toJsonObject() as! [String: Any]
        
        XCTAssertEqual(evt["event"] as? String, "plant", "event should be plant")
        XCTAssertEqual(evt["data_version"] as? String, "2.0", "data_version should be 2.0")
        XCTAssertNotNil(evt["app_id"], "app_id should not be nil")
        XCTAssertNotNil(evt["ts"], "ts should not be nil")
        XCTAssertNotNil(evt["user_id"], "user_id should not be nil")
        XCTAssertNotNil(evt["session_id"], "session_id should not be nil")
        XCTAssertNotNil(evt["properties"] as? [String: Any], "properties should not be nil")
        
        let properties = evt["properties"] as! [String: Any]
        
        XCTAssertNotNil(properties["app_version"], "app_version should not be nil")
        XCTAssertNotNil(properties["os"], "os should not be nil")
        XCTAssertNotNil(properties["os_version"], "os_version should not be nil")
        XCTAssertNotNil(properties["device"], "device should not be nil")
        XCTAssertNotNil(properties["lang"], "lang should not be nil")
        XCTAssertNotNil(properties["install_ts"], "install_ts should not be nil")
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
        let evt = tracer.customTraceHistory[0].eventString.toJsonObject() as! [String: Any]
        
        XCTAssertEqual(evt["event"] as? String, "plant", "event should be plant")
        XCTAssertEqual(evt["data_version"] as? String, "2.0", "data_version should be 2.0")
        XCTAssertNotNil(evt["app_id"], "app_id should not be nil")
        XCTAssertNotNil(evt["ts"], "ts should not be nil")
        XCTAssertNotNil(evt["user_id"], "user_id should not be nil")
        XCTAssertNotNil(evt["session_id"], "session_id should not be nil")
        XCTAssertNotNil(evt["properties"] as? [String: Any], "properties should not be nil")
        
        let props = evt["properties"] as! [String: Any]
        
        XCTAssertNotNil(props["app_version"], "app_version should not be nil")
        XCTAssertNotNil(props["os"], "os should not be nil")
        XCTAssertNotNil(props["os_version"], "os_version should not be nil")
        XCTAssertNotNil(props["device"], "device should not be nil")
        XCTAssertNotNil(props["lang"], "lang should not be nil")
        XCTAssertNotNil(props["install_ts"], "install_ts should not be nil")
    }
}
