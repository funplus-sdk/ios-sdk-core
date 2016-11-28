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
    
    static let EXTRA_PROPERTIES_SAVED_KEY = "com.funplus.sdk.ExtraRUMProperties"
    
    let label = "com.funplus.sdk.FunPlusRUM"
    let funPlusConfig: FunPlusConfig
    let logAgentClient: LogAgentClient
    let sampler: RUMSampler
    
    var networkReachabilityManager: NetworkReachabilityManager?
    var currentNetworkStatus: NetworkReachabilityManager.NetworkReachabilityStatus?
    var previousNetworkStatus: NetworkReachabilityManager.NetworkReachabilityStatus?
    
    var extraProperties: [String: String]

    // MARK: - Init & Deinit
    
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
            progress: { (_, total, uploaded) in
                print("Uploading RUM events in progress: {total=\(total), uploaded=\(uploaded)}")
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
    
    func trace(_ event: [String: Any]) {
        guard !logAgentClient.isBusy() else {
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: event, options: [])
            
            guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                return
            }
        
            if sampler.shouldSendEvent(event) {
                logAgentClient.trace(jsonString)
            }
        } catch {
            // TODO
        }
    }
    
    public func traceAppBackground() {
        trace(buildRUMEvent(eventName: "app_background"))
    }
    
    public func traceAppForeground() {
        trace(buildRUMEvent(eventName: "app_foreground"))
    }
    
    public func traceNetworkSwitch(sourceState: String, currentState: String) {
        let event = buildRUMEvent(
            eventName: "network_switch",
            customProperties: [
                "source_state":     sourceState,
                "current_state":    currentState
            ]
        )
        
        trace(event)
    }
    
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
        
        trace(event)
    }
    
    public func setExtraProperty(key: String, value: String) {
        extraProperties[key] = value
        UserDefaults.standard.set(extraProperties, forKey: FunPlusRUM.EXTRA_PROPERTIES_SAVED_KEY)
    }
    
    public func eraseExtraProperty(key: String) {
        extraProperties[key] = nil
        UserDefaults.standard.set(extraProperties, forKey: FunPlusRUM.EXTRA_PROPERTIES_SAVED_KEY)
    }
    
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
    
    fileprivate func unregisterNetworkListener() {
        networkReachabilityManager?.stopListening()
        networkReachabilityManager = nil
    }
}
