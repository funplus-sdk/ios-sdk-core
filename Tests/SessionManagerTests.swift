//
//  SessionManagerTests.swift
//  FunPlusSDKTests
//
//  Created by Yuankun Zhang on 12/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class SessionManagerTests: XCTestCase {
    
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()
    
    class Listener: SessionStatusChangeListener {
        
        var userId: String?
        
        func sessionStarted(userId: String, sessionId: String, sessionStartTs: Int64) {
            self.userId = userId
        }
        
        func sessionEnded(userId: String, sessionId: String, sessionStartTs: Int64, sessionLength: Int64) {
            self.userId = nil
        }
    }
    
    func testInit() {
        // Given, When
        let sessionManager = SessionManager(funPlusConfig: funPlusConfig)
        
        // Then
        XCTAssertFalse(sessionManager.userId.isEmpty, "userId should not be empty")
        XCTAssertFalse(sessionManager.sessionId.isEmpty, "sessionId should not be empty")
    }
    
    func testRegisterListener() {
        // Given
        let sessionManager = SessionManager(funPlusConfig: funPlusConfig)
        let listener = Listener()
        
        // When
        sessionManager.registerListener(listener: listener)
        
        // Then
        XCTAssertEqual(sessionManager.listeners.count, 1, "listeners count should be 1")
    }
    
    func testStartSession() {
        // Given
        let sessionManager = SessionManager(funPlusConfig: funPlusConfig)
        let listener = Listener()
        sessionManager.registerListener(listener: listener)
        let userId = "testuser"
        
        // When
        sessionManager.startSession(userId: userId)
        
        // Then
        XCTAssertEqual(listener.userId, userId, "userId should be \(userId)")
    }
    
    func testEndSession() {
        // Given
        let sessionManager = SessionManager(funPlusConfig: funPlusConfig)
        let listener = Listener()
        sessionManager.registerListener(listener: listener)
        let userId = "testuser"
        sessionManager.startSession(userId: userId)
        
        // When
        sessionManager.endSession()
        
        // Then
        XCTAssertNil(listener.userId, "userId should be nil")
    }
    
    func testUserIdChanged() {
        // Given
        let sessionManager = SessionManager(funPlusConfig: funPlusConfig)
        let listener = Listener()
        sessionManager.registerListener(listener: listener)
        let userId = "testuser"
        
        sessionManager.startSession(userId: userId)
        let newUserId = "newuser"
        
        // When
        sessionManager.userIdChanged(newUserId: newUserId)
        
        // Then
        XCTAssertEqual(listener.userId, newUserId, "userId should be \(newUserId)")
    }
}
