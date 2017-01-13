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
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            print("[FunPlusSDK] unable to convert string to JSON object")
            return nil
        }
    }
}

// MARK: - DataEventTracedListener

///
/// Classes adopted to the `DataEventTracedListener` will be notified
/// when some event is traced.
///
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
    
    /// Key used to save extra properties.
    static let EXTRA_PROPERTIES_SAVED_KEY = "com.funplus.sdk.ExtraDataProperties"
    
    /// The label for `LogAgentClient`, **should be globally unique**.
    let label = "com.funplus.sdk.FunPlusData"
    
    /// The configurations.
    let funPlusConfig: FunPlusConfig
    
    /// The `LogAgentClient` instance used to trace KPI events.
    let kpiLogAgentClient: LogAgentClient
    
    /// The `LogAgentClient` instance used to trace custom events.
    let customLogAgentClient: LogAgentClient
    
    /// Listeners for event tracing.
    var listeners = [DataEventTracedListener]()
    
    /// User-defined properties.
    var extraProperties: [String: String]
    
    // MARK: - Init
    
    /**
        Create a new `FunPlusData` instance.
     
        - parameter funPlusConfig:  The configurations.
     
        - returns:  The created instance.
     */
    init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        
        let endpoint = funPlusConfig.dataEndpoint
        let tag = funPlusConfig.dataTag
        let key = funPlusConfig.dataKey
        let uploadInterval = TimeInterval(funPlusConfig.dataUploadInterval)
        
        kpiLogAgentClient = LogAgentClient(
            funPlusConfig: funPlusConfig,
            label: "\(label).core",
            endpoint: endpoint,
            tag: tag.core,
            key: key,
            uploadInterval: uploadInterval,
            progress: { (remaining, uploaded) in
                print("Uploading Data KPI events: {uploaded=\(uploaded), remaining=\(remaining)}")
            }
        )
        customLogAgentClient = LogAgentClient(
            funPlusConfig: funPlusConfig,
            label: "\(label).custom",
            endpoint: endpoint,
            tag: tag.custom,
            key: key,
            uploadInterval: uploadInterval,
            progress: { (remaining, uploaded) in
                print("Uploading Data custom events: {uploaded=\(uploaded), remaining=\(remaining)}")
            }
        )
        
        extraProperties = UserDefaults.standard.dictionary(forKey: FunPlusData.EXTRA_PROPERTIES_SAVED_KEY) as? [String: String] ?? [:]
        
        if funPlusConfig.dataAutoTraceSessionEvents {
            FunPlusFactory.getSessionManager(funPlusConfig: funPlusConfig).registerListener(listener: self)
        }
        
        getLogger().i("FunPlusData ready to work")
    }
    
    // MARK: - Listener
    
    /**
        Register a listener for event tracing. Make sure not to register twice for one listner.
     
        - parameter listener:   The listener to be registered.
     */
    public func registerEventTracedListener(listener: DataEventTracedListener) {
        listeners.append(listener)
    }
    
    // MARK: - Trace
    
    /**
        Trace an event.
     
        - parameter eventType:  The event type.
        - parameter event:      The event dict.
     */
    func trace(eventType: DataEventType, event: [String: Any]) {
        switch eventType {
        case .kpi:
            kpiLogAgentClient.trace(entry: event)
            
            // Publish this event.
            for listener in listeners {
                listener.kpiEventTraced(event: event)
            }
        case .custom:
            customLogAgentClient.trace(entry: event)
            
            // Publish this event.
            for listener in listeners {
                listener.customEventTraced(event: event)
            }
        }

    }
    
    /**
        Trace a custom event.
     
        - parameter event:  The event dict.
     */
    public func traceCustom(event: [String: Any]) {
        guard let _ = event["event"] as? String else {
            return
        }
        
        trace(eventType: .custom, event: event)
    }
    
    /**
        Trace a custom event by name and properties.
     
        - parameter eventName:  The event's name.
        - parameter properties: The event's properties.
     */
    public func traceCustom(eventName: String, properties: [String: Any]) {
        trace(eventType: .custom, event: buildDataEvent(eventName: eventName, customProperties: properties))
    }
    
    /**
        Trace a `session_start` event.
     */
    public func traceSessionStart() {
        trace(eventType: .kpi, event: buildDataEvent(eventName: "session_start"))
    }
    
    /**
        Trace a `session_end` event.
     
        - parameter sessionLength:  Length of the ending session.
     */
    public func traceSessionEnd(sessionLength: Int64) {
        let event = buildDataEvent(
            eventName: "session_end",
            customProperties: [
                "session_length": sessionLength
            ]
        )
        trace(eventType: .kpi, event: event)
    }
    
    /**
        Trace a `new_user` event.
     */
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
        - parameter itemsReceived:      An array string consisting of one or more items received (optional).
        - parameter currencyReceived:   An array string consisting of one or more types of currency received (optional).
     */
    public func tracePayment(
        amount: Double,
        currency: String,
        productId: String,
        productName: String?,
        productType: String?,
        transactionId: String,
        paymentProcessor: String,
        itemsReceived: String?,
        currencyReceived: String?)
    {
        let event = buildDataEvent(
            eventName: "payment",
            customProperties: [
                "amount":               String(amount),
                "currency":             currency,
                "iap_product_id":       productId,
                "iap_product_name":     productName ?? "",
                "iap_product_type":     productType ?? "",
                "transaction_id":       transactionId,
                "payment_processor":    paymentProcessor,
                "c_items_received":     itemsReceived?.toJsonObject() ?? [],
                "c_currency_received":  currencyReceived?.toJsonObject() ?? []
            ]
        )
        
        trace(eventType: .kpi, event: event)
    }
    
    /**
        Build an event based on given parameters.
     
        - parameter eventName:          The event's name.
        - parameter customeProperties:  The event's custom properties.
     
        - returns:  The constructed event.
     */
    func buildDataEvent(eventName: String, customProperties: [String: Any]? = nil) -> [String: Any] {
        let sessionManager = FunPlusFactory.getSessionManager(funPlusConfig: funPlusConfig)
        
        var properties: [String: Any] = [
            "app_version":  DeviceInfo.appVersion,
            "device":       DeviceInfo.modelName,
            "os":           DeviceInfo.systemName,
            "os_version":   DeviceInfo.systemVersion,
            "lang":         DeviceInfo.appLanguage,
            "install_ts":   "\(Int64(FunPlusSDK.getInstallDate().timeIntervalSince1970 * 1000))"
        ]
        
        if let customProperties = customProperties {
            for (key, value) in customProperties {
                properties[key] = value
            }
        }

        return [
            "event":        eventName,
            "data_version": "2.0",
            "ts":           "\(Int64(Date().timeIntervalSince1970 * 1000))",
            "app_id":       funPlusConfig.dataTag,
            "user_id":      sessionManager.userId,
            "session_id":   sessionManager.sessionId,
            
            "properties":   properties
        ]
    }
    
    // MARK: Extra Properties
    
    /**
        Set or override an extra property.
     
        - parameter key:    Property key.
        - parameter value:  Property value.
     */
    public func setExtraProperty(key: String, value: String) {
        extraProperties[key] = value
        UserDefaults.standard.set(extraProperties, forKey: FunPlusData.EXTRA_PROPERTIES_SAVED_KEY)
    }
    
    /**
        Erase an existing property.
     
        - parameter key:    Property key.
     */
    public func eraseExtraProperty(key: String) {
        extraProperties[key] = nil
        UserDefaults.standard.set(extraProperties, forKey: FunPlusData.EXTRA_PROPERTIES_SAVED_KEY)
    }
    
    // MARK: - SessionStatusChangeListener
    
    /**
        Shall be called when a session is started.
     
        - parameter userId:         The user ID.
        - parameter sessionId:      The session ID.
        - parameter sessionStartTs: The session started timestamp.
     */
    func sessionStarted(userId: String, sessionId: String, sessionStartTs: Int64) {
        traceSessionStart()
    }
    
    /**
        Shall be called when a session is ended.
     
        - parameter userId:         The use ID.
        - parameter sessionId:      The session ID.
        - parameter sessionStartTs: The session started timestamp.
        - parameter sessionLength:  The session's length.
     */
    func sessionEnded(userId: String, sessionId: String, sessionStartTs: Int64, sessionLength: Int64) {
        traceSessionEnd(sessionLength: sessionLength)
    }
    
    // MARK: - Helpers
    
    /**
        Get the logger.
     
        - returns:  The `Logger` instance.
     */
    func getLogger() -> Logger {
        return FunPlusFactory.getLogger(funPlusConfig: funPlusConfig)
    }
}
