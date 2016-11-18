//
//  SessionManager.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 8/30/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - SessionStatusChangeListener

protocol SessionStatusChangeListener {
    func sessionStarted(userId: String, sessionId: String, sessionStartTs: Int64)
    func sessionEnded(userId: String, sessionId: String, sessionStartTs: Int64, sessionLength: Int64)
}

// MARK: - SessionManager

class SessionManager {
    
    // MARK: - Properties
    
    let funPlusConfig: FunPlusConfig
    var userId: String = ""
    var sessionId: String = ""
    var sessionStartTs: Int64?
    
    var listeners = [SessionStatusChangeListener]()
    
    // MARK: - Init & Deinit
    
    init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        startSession(userId: FunPlusFactory.getFunPlusID(funPlusConfig: funPlusConfig).getCurrentFPID())
        
        registerNotificationObservers()
        
        print("[FunPlusSDK] SessionManager ready to work")
    }
    
    deinit {
        unregisterNotificationObservers()
    }
    
    // MARK: - APIs
    
    func registerListener(listener: SessionStatusChangeListener) {
        listeners.append(listener)
    }
    
    func userIdChanged(newUserId: String) {
        endSession()
        startSession(userId: newUserId)
    }
    
    func startSession(userId: String) {
        self.userId = userId
        self.sessionStartTs = Int64(Date().timeIntervalSince1970)
        
        let appIdJoinUserId = "\(funPlusConfig.appId)-\(userId)"
        let appIdJoinUserIdPadding = appIdJoinUserId.padding(toLength: 23, withPad: "0", startingAt: 0)
        self.sessionId = "i\(appIdJoinUserIdPadding)\(sessionStartTs!)"
        
        for listener in listeners {
            listener.sessionStarted(userId: userId, sessionId: sessionId, sessionStartTs: sessionStartTs!)
        }
    }
    
    func endSession() {
        if sessionStartTs == nil {
            print("[FunPlusSDK] Unable to end session: there's no active session")
            return
        }
        
        let sessionLength = Int64(Date().timeIntervalSince1970) - sessionStartTs!
        
        for listener in listeners {
            listener.sessionEnded(userId: userId, sessionId: sessionId, sessionStartTs: sessionStartTs!, sessionLength: sessionLength)
        }
        
        sessionStartTs = nil
    }
    
    // MARK: - App Life Cycle
    
    @objc public func appDidBecomeActive() {
        startSession(userId: FunPlusFactory.getFunPlusID(funPlusConfig: funPlusConfig).getCurrentFPID())
    }
    
    @objc public func appDidEnterBackground() {
        endSession()
    }
    
    fileprivate func registerNotificationObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        nc.addObserver(self, selector: #selector(self.appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    fileprivate func unregisterNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
