//
//  FunPlusData.swift
//  FunPlusData
//
//  Created by Yuankun Zhang on 4/3/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

/// Extension to convert a given string to a BI tag.
private extension String {
    var core: String { return "\(self).core" }
    var custom: String { return "\(self).custom" }
    
    func toJsonObject() -> Any? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            return nil
        }
    }
}

// MARK: - DataEventTracedListener

public protocol DataEventTracedListener {
    func kpiEventTraced(event: [String: Any])
    func customEventTraced(event: [String: Any])
}

// MARK: - DataEventType

public enum DataEventType {
    case kpi
    case custom
}

// MARK: - FunPlusData

///
/// See http://wiki.ifunplus.cn/display/BI/Business+Intelligence+Specification+v2.0
///
public class FunPlusData: SessionStatusChangeListener {
    
    // MARK: - Properties
    
    static let EXTRA_PROPERTIES_SAVED_KEY = "com.funplus.sdk.ExtraDataProperties"
    
    let label = "com.funplus.sdk.FunPlusData"
    let funPlusConfig: FunPlusConfig
    let kpiLogAgentClient: LogAgentClient
    let customLogAgentClient: LogAgentClient
    
    var listeners = [DataEventTracedListener]()
    
    var extraProperties: [String: String]
    
    var kpiTraceHistory = [(eventString: String, traceTime: Date)]()
    var customTraceHistory = [(eventString: String, traceTime: Date)]()
    
    // MARK: - Init
    
    init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        
        let endpoint = funPlusConfig.dataEndpoint
        let tag = funPlusConfig.dataTag
        let key = funPlusConfig.dataKey
        let uploadInterval = TimeInterval(funPlusConfig.dataUploadInterval)
        
        kpiLogAgentClient = LogAgentClient(
            funPlusConfig: funPlusConfig,
            label: label,
            endpoint: endpoint,
            tag: tag.core,
            key: key,
            uploadInterval: uploadInterval
        )
        customLogAgentClient = LogAgentClient(
            funPlusConfig: funPlusConfig,
            label: label,
            endpoint: endpoint,
            tag: tag.custom,
            key: key,
            uploadInterval: uploadInterval
        )
        
        extraProperties = UserDefaults.standard.dictionary(forKey: FunPlusData.EXTRA_PROPERTIES_SAVED_KEY) as? [String : String] ?? [:]
        
        FunPlusFactory.getSessionManager(funPlusConfig: funPlusConfig).registerListener(listener: self)
        
        getLogger().i("FunPlusData ready to work")
    }
    
    public func registerEventTracedListener(listener: DataEventTracedListener) {
        listeners.append(listener)
    }
    
    // MARK: - Trace
    
    func trace(eventType: DataEventType, event: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: event, options: []) else {
            return
        }
        
        guard let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        
        switch eventType {
        case .kpi:
            kpiLogAgentClient.trace(jsonString)
            
            #if DEBUG
            kpiTraceHistory.append(eventString: jsonString, traceTime: Date())
            #endif
            
            for listener in listeners {
                listener.kpiEventTraced(event: event)
            }
        case .custom:
            customLogAgentClient.trace(jsonString)
            
            #if DEBUG
            customTraceHistory.append(eventString: jsonString, traceTime: Date())
            #endif
            
            for listener in listeners {
                listener.customEventTraced(event: event)
            }
        }
        
        getLogger().i("Trace Data event: \(jsonString)")
    }
    
    public func traceCustom(event: [String: Any]) {
        guard let _ = event["event"] as? String else {
            return
        }
        
        trace(eventType: .custom, event: event)
    }
    
    public func traceSessionStart() {
        trace(eventType: .kpi, event: buildDataEvent(eventName: "session_start"))
    }
    
    public func traceSessionEnd(sessionLength: Int64) {
        let event = buildDataEvent(
            eventName: "session_end",
            customProperties: [
                "session_length": sessionLength
            ]
        )
        trace(eventType: .kpi, event: event)
    }
    
    public func traceNewUser() {
        trace(eventType: .kpi, event: buildDataEvent(eventName: "new_user"))
    }
    
    /**
        Shall be called when user purchase some product.
     
        - parameter amount:             Numeric value which corresponds to the cost of the purchase
                                        in the monetary unit multiplied by 100.
        - parameter currency:           The 3-letter ISO 4217 resource Code.
                                        [ISO4217](http://www.xe.com/iso4217.php)
        - parameter productId:          The ID of the product purchased.
        - parameter productName:        The name of the product purchased (optional).
        - parameter productType:        The type of the product purchased (optional).
        - parameter transactionId:      The unique transaction ID sent back by the payment processor.
        - parameter paymentProcessor:   The payment processor.
        - parameter itemsReceived:      An array string consisting of one or more items received.
        - parameter currencyReceived:   An array string consisting of one or more types of currency received.
     */
    public func tracePayment(
        amount: Double,
        currency: String,
        productId: String,
        productName: String?,
        productType: String?,
        transactionId: String,
        paymentProcessor: String,
        itemsReceived: String,
        currencyReceived: String,
        currencyReceivedType: String)
    {
        let event = buildDataEvent(
            eventName: "payment",
            customProperties: [
                "amount":                   String(amount),
                "currency":                 currency,
                "iap_product_id":           productId,
                "iap_product_name":         productName ?? "",
                "iab_product_type":         productType ?? "",
                "transaction_id":           transactionId,
                "payment_processor":        paymentProcessor,
                "c_items_received":         itemsReceived.toJsonObject() ?? [],
                "c_currency_received":      currencyReceived.toJsonObject() ?? [],
                "d_currency_received_type": currencyReceivedType
            ]
        )
        
        trace(eventType: .kpi, event: event)
    }
    
    public func setExtraProperty(key: String, value: String) {
        extraProperties[key] = value
        UserDefaults.standard.set(extraProperties, forKey: FunPlusData.EXTRA_PROPERTIES_SAVED_KEY)
    }
    
    public func eraseExtraProperty(key: String) {
        extraProperties[key] = nil
        UserDefaults.standard.set(extraProperties, forKey: FunPlusData.EXTRA_PROPERTIES_SAVED_KEY)
    }
    
    func buildDataEvent(eventName: String, customProperties: [String: Any]? = nil) -> [String: Any] {
        let sessionManager = FunPlusFactory.getSessionManager(funPlusConfig: funPlusConfig)
        
        var properties: [String: Any] = [
            "app_version":  DeviceInfo.appVersion,
            "device":       DeviceInfo.modelName,
            "os":           DeviceInfo.systemName,
            "os_version":   DeviceInfo.systemVersion,
            "lang":         DeviceInfo.appLanguage,
            "install_ts":   "\(Int64(FunPlusSDK.getInstallDate().timeIntervalSince1970) * 1000)"
        ]
        
        if let customProperties = customProperties {
            for (key, value) in customProperties {
                properties[key] = value
            }
        }

        return [
            "event":        eventName,
            "data_version": "2.0",
            "ts":           "\(Int64(Date().timeIntervalSince1970) * 1000)",
            "app_id":       funPlusConfig.dataTag,
            "user_id":      sessionManager.userId,
            "session_id":   sessionManager.sessionId,
            
            "properties":   properties
        ]
    }
    
    func getLogger() -> Logger {
        return FunPlusFactory.getLogger(funPlusConfig: funPlusConfig)
    }
    
    // MARK: - SessionStatusChangeListener Implementation
    
    func sessionStarted(userId: String, sessionId: String, sessionStartTs: Int64) {
        traceSessionStart()
    }
    
    func sessionEnded(userId: String, sessionId: String, sessionStartTs: Int64, sessionLength: Int64) {
        traceSessionEnd(sessionLength: sessionLength)
    }
}
