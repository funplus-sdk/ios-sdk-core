//
//  DataEventValidator.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 22/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

class DataEventValidator {
    
    class func validate(event: [String: Any]) -> Bool {
        guard let eventName = event["event"] as? String else {
            return false
        }
        
        switch eventName {
        case "session_start":
            return validateCommon(event: event) && validateSessionStart(event: event)
        case "session_end":
            return validateCommon(event: event) && validateSessionEnd(event: event)
        case "new_user":
            return validateCommon(event: event) && validateNewUser(event: event)
        case "payment":
            return validateCommon(event: event) && validatePayment(event: event)
        default:
            return validateCommon(event: event)
        }
    }
    
    class func validateSessionStart(event: [String: Any]) -> Bool {
        return true
    }
    
    class func validateSessionEnd(event: [String: Any]) -> Bool {
        return true
    }
    
    class func validateNewUser(event: [String: Any]) -> Bool {
        return true
    }
    
    class func validatePayment(event: [String: Any]) -> Bool {
        return true
    }
    
    class func validateCommon(event: [String: Any]) -> Bool {
        let schema = Schema([
            "type": "object",
            "properties": [
                "data_version": ["type": "string"],
                "app_id":       ["type": "string"],
                "ts":           ["type": "string"],
                "event":        ["type": "string"],
                "user_id":      ["type": "string"],
                "session_id":   ["type": "string"],
            ],
            "required": ["name"],
        ])
        return schema.validate(data: event).valid
    }
}
