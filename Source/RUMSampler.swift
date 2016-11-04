//
//  RUMSampler.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 5/27/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import AdSupport

// MARK: - RUMSampler

/**
    The `RUMSampler` class suppress specific events by the pre-defined rules.
 
    Here is the ordered rules list:
 
    1. User blacklist:      Suppress events with given user ID.
    2. User whitelist:      Do not suppress events with given user ID.
    3. Event whitelist:     Do not suppress events with given event type.
    4. Eigenvalue:          Suppress all events if the eigenvalue is greater than the sample rate.
 */
class RUMSampler {
    
    /// This map shows the numbers of set bits for each hex letter.
    static let MAP: [Character: Int] = [
        "0": 0, "1": 1, "2": 1, "3": 2, "4": 1, "5": 2, "6": 2, "7": 3,
        "8": 1, "9": 2, "a": 2, "b": 3, "c": 2, "d": 3, "e": 3, "f": 4
    ]
    
    let sampleRate: Double
    let eventWhitelist: [String]
    let userBlacklist: [String]
    let userWhitelist: [String]
    
    let deviceUniqueValue: Double
    
    init(sampleRate: Double,
         eventWhitelist: [String],
         userWhitelist: [String],
         userBlacklist: [String])
    {
        self.sampleRate = sampleRate
        self.eventWhitelist = eventWhitelist
        self.userWhitelist = userWhitelist
        self.userBlacklist = userBlacklist
        
        let hash = ASIdentifierManager.shared().advertisingIdentifier?.uuidString.md5()
        self.deviceUniqueValue = RUMSampler.calcDeviceUniqueValue(hash: hash)
    }
    
    func shouldSendEvent(_ event: [String: Any]) -> Bool {
        guard let userId = event["user_id"] as? String, let eventName = event["event"] as? String else {
            return false
        }
        
        //==============================================
        //     Step 1: Check user blacklist
        //==============================================
        if !userBlacklist.isEmpty && userBlacklist.contains(userId) {
            return false
        }
        
        //==============================================
        //     Step 2: Check user whitelist
        //==============================================
        if !userWhitelist.isEmpty && userWhitelist.contains(userId) {
            return true
        }
        
        //==============================================
        //     Step 3: Check event whitelist
        //==============================================
        if !eventWhitelist.isEmpty && eventWhitelist.contains(eventName) {
            return true
        }
        
        //==============================================
        //     Step 4: Check eigenvalue
        //==============================================
        return deviceUniqueValue <= sampleRate
    }
    
    class func calcDeviceUniqueValue(hash: String?) -> Double {
        guard let hash = hash else {
            return 0
        }
        
        var sum: Int64 = 0
        
        for c in hash.characters {
            sum += MAP[c] ?? 0
        }
        
        return Double(sum) / 128.0
    }
}
