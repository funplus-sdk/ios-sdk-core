//
//  FunPlusRUM.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 5/19/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

/// Extension to convert networt status to a string format that required by the RUM spec.
extension NetworkReachabilityManager.NetworkReachabilityStatus {
    
    var string: String {
        switch self {
        case .unknown: return "Unknown"
        case .notReachable: return "NotReachable"
        case .reachable(.ethernetOrWiFi): return "Wifi"
        case .reachable(.wwan): return "Cellular"
        }
    }
}

// MARK: - FunPlusRUM

///
/// See http://wiki.ifunplus.cn/display/ops/Rum+Crumb+Event
///
public class FunPlusRUM {
    
    // MARK: - Properties
    
    /// Key used to save extra properties.
    static let EXTRA_PROPERTIES_SAVED_KEY = "com.funplus.sdk.ExtraRUMProperties"
    
    /// The label for `LogAgentClient`, **should be globally unique**.
    let label = "com.funplus.sdk.FunPlusRUM"
    
    /// The configurations.
    let funPlusConfig: FunPlusConfig
    
    /// The `LogAgentClient` instance used to trace RUM events.
    let logAgentClient: LogAgentClient
    
    /// The sampler used to filter out events.
    let sampler: RUMSampler
    
    /// Manager to indicate network reachability.
    var networkReachabilityManager: NetworkReachabilityManager?
    
    /// Current network status. Might be `nil`.
    var currentNetworkStatus: NetworkReachabilityManager.NetworkReachabilityStatus?
    
    /// Previous network status. Might be `nil`.
    var previousNetworkStatus: NetworkReachabilityManager.NetworkReachabilityStatus?
    
    /// User-defined properties.
    var extraProperties: [String: String]
    
    #if DEBUG
    /// History of traced RUM events.
    var traceHistory = [(eventString: String, traceTime: Date)]()
    
    /// History of suppressed RUM events.
    var suppressHistory = [(eventString: String, traceTime: Date)]()
    #endif

    // MARK: - Init & Deinit
    
    /**
        Create a new `FunPlusRUM` instance.
     
        - parameter funPlusConfig:  The configurations.
     
        - returns:  The created instance.
     */
    init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        
        let endpoint = funPlusConfig.rumEndpoint
        let tag = funPlusConfig.rumTag
        let key = funPlusConfig.rumKey
        let uploadInterval = TimeInterval(funPlusConfig.rumUploadInterval)
        
        logAgentClient = LogAgentClient(
            funPlusConfig: funPlusConfig,
            label: label,
            endpoint: endpoint,
            tag: tag,
            key: key,
            uploadInterval: uploadInterval,
            progress: { (_, _, uploaded) in
                if uploaded != 0 {
                    print("Uploading RUM events in progress: {uploaded=\(uploaded)}")
                }
            }
        )
        
        let sampleRate = funPlusConfig.rumSampleRate
        let eventWhitelist = funPlusConfig.rumEventWhitelist
        let userWhietlist = funPlusConfig.rumUserWhitelist
        let userBlacklist = funPlusConfig.rumUserBlacklist
        
        sampler = RUMSampler(
            sampleRate: sampleRate,
            eventWhitelist: eventWhitelist,
            userWhitelist: userWhietlist,
            userBlacklist: userBlacklist
        )
        
        extraProperties = UserDefaults.standard.dictionary(forKey: FunPlusRUM.EXTRA_PROPERTIES_SAVED_KEY) as? [String : String] ?? [:]
        
        registerNetworkListener()
        registerNotificationObservers()
        
        getLogger().i("FunPlusRUM ready to work")
    }
    
    deinit {
        unregisterNetworkListener()
        unregisterNotificationObservers()
    }
    
    // MARK: - Trace
    
    /**
        Trace a RUM event.
     
        - parameter event:  The event dict to be traced.
     */
    func trace(event: [String: Any]) {
        if sampler.shouldSendEvent(event) {
            logAgentClient.trace(entry: event)
            
            #if DEBUG
            traceHistory.append((eventString: event.description, traceTime: Date()))
            #endif
        } else {
            
            #if DEBUG
            suppressHistory.append((eventString: event.description, traceTime: Date()))
            #endif
        }
    }
    
    /**
        Trace an `app_background` event.
     */
    public func traceAppBackground() {
        trace(event: buildRUMEvent(eventName: "app_background"))
    }
    
    /**
        Trace an `app_foreground` event.
     */
    public func traceAppForeground() {
        trace(event: buildRUMEvent(eventName: "app_foreground"))
    }
    
    /**
        Trace a `network_switch` event.
     
        - parameter sourceState:    The previous state being transfered from.
        - parameter currentState:   The current state being transfered to.
     */
    public func traceNetworkSwitch(sourceState: String, currentState: String) {
        let event = buildRUMEvent(
            eventName: "network_switch",
            customProperties: [
                "source_state":     sourceState,
                "current_state":    currentState
            ]
        )
        
        trace(event: event)
    }
    
    /**
        Trace a `service_monitoring` event.
     
        - parameter serviceName:    The service name.
        - parameter httpUrl:        The service's URL.
        - parameter httpStatus:     Response status of the request.
        - parameter requestSize:    Request size.
        - parameter responseSize;   Response size.
        - parameter httpLatency:    Request latency.
        - parameter requestTs:      Timestamp when the request is being posted.
        - parameter responseTs:     Timestamp when the response begins to be received.
        - parameter targetUserId:   The target user ID.
        - parameter gameServerId:   The game server ID.
     */
    public func traceServiceMonitoring(
        serviceName: String,
        httpUrl: String,
        httpStatus: String,
        requestSize: Int,
        responseSize: Int,
        httpLatency: Int64,
        requestTs: Int64,
        responseTs: Int64,
        requestId: String,
        targetUserId: String,
        gameServerId: String? = nil)
    {
        let event = buildRUMEvent(
            eventName: "service_monitoring",
            customProperties: [
                "service_name":     serviceName,
                "http_url":         httpUrl,
                "request_size":     requestSize,
                "response_size":    responseSize,
                "http_latency":     httpLatency,
                "request_ts":       requestTs,
                "response_ts":      responseTs,
                "req_id":           requestId,
                "target_user_id":   targetUserId,
                "game_server_id":   gameServerId ?? "Unknown",
                "current_state":    self.currentNetworkStatus?.string ?? "Unknown"
            ]
        )
        
        trace(event: event)
    }
    
    /**
        Build an event based on given parameters.
     
        - parameter eventName:          The event's name.
        - parameter customeProperties:  The event's custom properties.
     
        - returns:  The constructed event.
     */
    func buildRUMEvent(eventName: String, customProperties: [String: Any]? = nil) -> [String: Any] {
        let sessionManager = FunPlusFactory.getSessionManager(funPlusConfig: funPlusConfig)
        
        var properties: [String: Any] = [
            "app_version":  DeviceInfo.appVersion,
            "device":       DeviceInfo.modelName,
            "os":           DeviceInfo.systemName,
            "os_version":   DeviceInfo.systemVersion,
            "carrier":      DeviceInfo.networkCarrierName
        ]
        
        if let customProperties = customProperties {
            for (key, value) in customProperties {
                properties[key] = value
            }
        }
        
        return [
            "event":        eventName,
            "data_version": "1.0",
            "ts":           "\(Int64(Date().timeIntervalSince1970) * 1000)",
            "app_id":       funPlusConfig.appId,
            "user_id":      sessionManager.userId,
            "session_id":   sessionManager.sessionId,
            "rum_id":       DeviceInfo.advertisingIdentifier ?? UUID().uuidString,
            
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
        UserDefaults.standard.set(extraProperties, forKey: FunPlusRUM.EXTRA_PROPERTIES_SAVED_KEY)
    }
    
    /**
        Erase an existing property.
     
        - parameter key:    Property key.
     */
    public func eraseExtraProperty(key: String) {
        extraProperties[key] = nil
        UserDefaults.standard.set(extraProperties, forKey: FunPlusRUM.EXTRA_PROPERTIES_SAVED_KEY)
    }
    
    // MARK: - Helpers
    
    /**
        Get the logger.
     
        - returns:  The `Logger` instance.
     */
    func getLogger() -> Logger {
        return FunPlusFactory.getLogger(funPlusConfig: funPlusConfig)
    }
    
    // MARK: - App Life Cycle
    
    @objc public func appDidEnterBackground() {
        traceAppBackground()
    }
    
    @objc public func appDidBacomeActive() {
        traceAppForeground()
    }
    
    // MARK: - Notification Observers
    
    fileprivate func registerNotificationObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        nc.addObserver(self, selector: #selector(appDidBacomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    fileprivate func unregisterNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Network Listener
    
    /**
        Register a network listener.
     */
    fileprivate func registerNetworkListener() {
        networkReachabilityManager = NetworkReachabilityManager()
        currentNetworkStatus = networkReachabilityManager?.networkReachabilityStatus
        previousNetworkStatus = currentNetworkStatus
        
        networkReachabilityManager?.listener = { status in
            self.previousNetworkStatus = self.currentNetworkStatus
            self.currentNetworkStatus = status

            let sourceState = self.previousNetworkStatus?.string ?? "Unknown"
            let currentState = self.currentNetworkStatus?.string ?? "Unknown"
            
            if sourceState != currentState {
                self.traceNetworkSwitch(sourceState: sourceState, currentState: currentState)
            }
        }
        
        networkReachabilityManager?.startListening()
    }
    
    /**
        Unregister the network listener.
     */
    fileprivate func unregisterNetworkListener() {
        networkReachabilityManager?.stopListening()
        networkReachabilityManager = nil
    }
}
