//
//  FunPlusID.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 9/15/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - FunPlusIDError

public enum FunPlusIDError : Error {
    case unknownError
    case networkError
    case serverError(code: Int)
}

// MARK: - FunPlusIDResult

public enum FunPlusIDResult {
    case success(fpid: String, sessionKey: String, expireIn: Int64)
    case failure(error: FunPlusIDError)
}

// MARK: - ExternalIDType

public enum ExternalIDType : String {
    case guid           = "guid"
    case inAppUserID    = "inapp_user_id"
    case email          = "email"
    case facebookID     = "facebook_id"
}


// MARK: - FunPlusID

public class FunPlusID {
    
    let passportClient: PassportClient
    
    init(funPlusConfig: FunPlusConfig) {
        passportClient = PassportClient(funPlusConfig: funPlusConfig)
        
        print("[FunPlusSDK] FunPlusID ready to work")
    }
    
    /**
        Get (retrieve or create) the FPID associated with given external user ID.
     
        - parameter externalID:     The external uesr ID.
        - parameter externalIDType: Type of the external user ID.
        - parameter completion:     The completion callback.
     */
    public func get(externalID: String,
                    externalIDType: ExternalIDType,
                    completion: @escaping (_ response: FunPlusIDResult) -> Void)
    {
        passportClient.get(externalID: externalID, externalIDType: externalIDType, completion: completion)
    }
    
    /**
        Bind the given external user ID to given FPID.
     
        - parameter fpid:           The FPID.
        - parameter externalID:     The external uesr ID.
        - parameter externalIDType: Type of the external user ID.
     */
    public func bind(fpid: String,
                     externalID: String,
                     externalIDType: ExternalIDType,
                     completion: @escaping (_ response: FunPlusIDResult) -> Void)
    {
        passportClient.bind(fpid: fpid, externalID: externalID, externalIDType: externalIDType, completion: completion)
    }
    
    /**
        Get the current FPID.
     
        - returns:  Current FPID.
     */
    public func getCurrentFPID() -> String {
        return passportClient.currentFPID
    }
}
