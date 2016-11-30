//
//  LoggerDataConsumer.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 09/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - LoggerDataConsumer

///
/// The `LoggerDataConsumer` class is used to upload SDK internal logs to Log Agent.
///
class LoggerDataConsumer {
    
    // MARK: - Properties
    
    let funPlusConfig: FunPlusConfig
    let logAgentClient: LogAgentClient
    
    var timer: Timer?
    let interval = 60.0
    let label = "com.funplus.sdk.Logger"
    
    // MARK: - Init & Deinit
    
    init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        
        let endpoint = funPlusConfig.loggerEndpoint
        let tag = funPlusConfig.loggerTag
        let key = funPlusConfig.loggerKey
        let uploadInterval = TimeInterval(funPlusConfig.loggerUploadInterval)
        
        logAgentClient = LogAgentClient(
            funPlusConfig: funPlusConfig,
            label: label,
            endpoint: endpoint,
            tag: tag,
            key: key,
            uploadInterval: uploadInterval
        )
        
        startTimer()
    }
    
    deinit {
        stopTimer()
    }
    
    @objc func consume() {
        logAgentClient.trace(entries: FunPlusFactory.getLogger(funPlusConfig: funPlusConfig).consumeLogs())
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(consume), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
}
