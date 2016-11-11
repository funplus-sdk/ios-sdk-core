//
//  PassportClientTests.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 11/11/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class PassportClientTests: XCTestCase {
    
    let TIMEOUT = 10.0
    let EXISTING_FPID = "13042";
    
    let funPlusConfig = FunPlusConfigFactory.defaultFunPlusConfig()
    
    func testMakeSignature() {
        // Given
        let passport = PassportClient(funPlusConfig: funPlusConfig)
        let params = ["game_id": "1007"]
        
        // When
        let sig = passport.makeSignature(params: params)
        
        // Then
        let correct = "NDA5MjgxYzk2YmI3YTQyMTUyNDcwNjUzZWRiMzBlYjlhYWZmY2YyZDEyZjRjOGE4Y2NjODg5OTMxNDllNDNjMg=="
        XCTAssertEqual(sig, correct, "sig should be \(correct)")
    }
    
    func testMakeSignatureWithEmptyParamsDictionary() {
        // Given
        let passport = PassportClient(funPlusConfig: funPlusConfig)
        let params: [String: String] = [:]
    
        // When
        let sig = passport.makeSignature(params: params)
    
        // Then
        let correct = "ZDRlNmEzN2FjODAyZjQ0NTM5NjQ1NGQzMDA0MWI3YTM1NTA5ODEyYTZkNzQ3MzUxNTg2ZGMyZmQ0NmExZTg5YQ=="
        XCTAssertEqual(sig, correct, "sig should be \(correct)")
    }
    
    func testGet() {
        // Given
        let passport = PassportClient(funPlusConfig: funPlusConfig)
        let externalID = "testuser"
        let externalIDType = ExternalIDType.inAppUserID
        let ex = expectation(description: "\(passport)")
        
        // When
        var fpid: String? = nil
        var error: FunPlusIDError? = nil
        
        passport.get(externalID: externalID, externalIDType: externalIDType) { res in
            switch (res) {
            case .success(let resFpid):
                fpid = resFpid
                ex.fulfill()
            case .failure(let resError):
                error = resError
                ex.fulfill()
            }
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertNotNil(fpid, "fpid should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testGetNonExistingExternalID() {
        // Given
        let passport = PassportClient(funPlusConfig: funPlusConfig)
        let externalID = UUID().uuidString
        let externalIDType = ExternalIDType.inAppUserID
        let ex = expectation(description: "\(passport)")
        
        // When
        var fpid: String? = nil
        var error: FunPlusIDError? = nil
        
        passport.get(externalID: externalID, externalIDType: externalIDType) { res in
            switch (res) {
            case .success(let resFpid):
                fpid = resFpid
                ex.fulfill()
            case .failure(let resError):
                error = resError
                ex.fulfill()
            }
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertNotNil(fpid, "fpid should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testBind() {
        // Given
        let passport = PassportClient(funPlusConfig: funPlusConfig)
        let bindToFpid = EXISTING_FPID
        let externalID = UUID().uuidString
        let externalIDType = ExternalIDType.inAppUserID
        let ex = expectation(description: "\(passport)")
        
        // When
        var fpid: String? = nil
        var error: FunPlusIDError? = nil
        
        passport.bind(fpid: bindToFpid, externalID: externalID, externalIDType: externalIDType) { res in
            switch (res) {
            case .success(let resFpid):
                fpid = resFpid
                ex.fulfill()
            case .failure(let resError):
                error = resError
                ex.fulfill()
            }
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertNotNil(fpid, "fpid should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testBindExternalIDToNonExistingFPID() {
        // Given
        let passport = PassportClient(funPlusConfig: funPlusConfig)
        let bindToFpid = "non-existing"
        let externalID = UUID().uuidString
        let externalIDType = ExternalIDType.inAppUserID
        let ex = expectation(description: "\(passport)")
        
        // When
        var fpid: String? = nil
        var error: FunPlusIDError? = nil
        
        passport.bind(fpid: bindToFpid, externalID: externalID, externalIDType: externalIDType) { res in
            switch (res) {
            case .success(let resFpid):
                fpid = resFpid
                ex.fulfill()
            case .failure(let resError):
                error = resError
                ex.fulfill()
            }
        }
        
        waitForExpectations(timeout: TIMEOUT, handler: nil)
        
        // Then
        XCTAssertNil(fpid, "fpid should be nil")
        XCTAssertNotNil(error, "error should not be nil")
    }
    
}
