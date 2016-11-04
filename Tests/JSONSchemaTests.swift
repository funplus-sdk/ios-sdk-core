//
//  JSONSchemaTests.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 22/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
@testable import FunPlusSDK

class JSONSchemaTests: XCTestCase {
    
    func testValid() {
        // Gievn
        let schema = Schema([
            "type": "object",
            "properties": [
                "name": ["type": "string"],
                "price": ["type": "number"],
            ],
            "required": ["name"],
            ]
        )
        
        // When
        let result = schema.validate(data: ["name": "Eggs", "price": 34.99])
        
        // Then
        XCTAssertTrue(result.valid, "result should be valid")
    }
    
    func testInvalid() {
        // Gievn
        let schema = Schema([
            "type": "object",
            "properties": [
                "name": ["type": "string"],
                "price": ["type": "number"],
            ],
            "required": ["name"],
            ]
        )
        
        // When
        let result = schema.validate(data: ["price": 34.99])
        
        // Then
        XCTAssertFalse(result.valid, "result should be invalid")
        XCTAssertEqual(result.errors?.count, 1, "errors.count should be 1")
        XCTAssertTrue(result.errors![0].contains("name"))
    }
    
}
