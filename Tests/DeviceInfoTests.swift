//
//  DeviceInfoTests.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 16/01/2017.
//  Copyright © 2017 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class DeviceInfoTests: XCTestCase {
    
    func testIdentifierForVendor() {
        // Given, When
        let idfv = DeviceInfo.identifierForVendor
        
        // Then
        XCTAssertNotNil(idfv, "idfv should not be nil")
    }
    
    func testAdvertisingIdentifier() {
        // Given, When
        let idfa = DeviceInfo.advertisingIdentifier
        
        // Then
        XCTAssertNotNil(idfa, "idfa should not be nil")
    }
    
    func testSystemName() {
        // Given, When
        let expectedName = "iOS"
        let systemName = DeviceInfo.systemName
        
        // Then
        XCTAssertEqual(systemName, expectedName, "systemName should be \(expectedName)")
    }
    
    func testSystemVersion() {
//        print(DeviceInfo.systemVersion)
    }
    
    func testModelName() {
//        print(DeviceInfo.modelName)
    }
    
    func testAppName() {
//        print(DeviceInfo.appName)
    }
    
    func testAppVersion() {
//        print(DeviceInfo.appVersion)
    }
    
    func testAppLanguage() {
//        print(DeviceInfo.appLanguage)
    }
    
    func testNetworkCarrierName() {
//        print(DeviceInfo.networkCarrierName)
    }
    
}
