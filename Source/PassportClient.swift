//
//  PassportClient.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 9/15/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - PassportEndpoint

enum PassportEndpoint: String {
    case sandbox = "http://passport-dev.funplusgame.com/client_api.php"
    case production = "http://passport.funplusgame.com/client_api.php"
}

// MARK: - PassportClient

/**
    The `PassportClient` class communicates with the Passport Server. It is responsible
    for sending request to the Passport Server and validate and parse the response.
 */
class PassportClient {
    
    // MARK: - Structs
    
    struct PropertyKeys {
        static let CurrentFPID          = "com.funplus.sdk.CurrentFPID"
    }
    
    // MARK: - Properties
    
    static let API_VERSION = 4
    
    let funPlusConfig: FunPlusConfig
    var currentFPID: String
    
    init(funPlusConfig: FunPlusConfig) {
        self.funPlusConfig = funPlusConfig
        self.currentFPID = UserDefaults.standard.string(forKey: PropertyKeys.CurrentFPID) ?? DeviceInfo.identifierForVendor ?? NSUUID().uuidString
    }
    
    // MARK: - APIs
    
    /**
        Get (retrieve or create) the FPID associated with given external user ID.
     
        - parameter externalID:     The external uesr ID.
        - parameter externalIDType: Type of the external user ID.
     */
    func get(externalID: String, externalIDType: ExternalIDType, completion: @escaping (FunPlusIDResult) -> Void) {
        let params = [
            "method":               "get",
            "app_id":               funPlusConfig.appId,
            "external_id":          externalID,
            "external_id_type":     externalIDType.rawValue
        ]
        
        request(params: params, completion: completion)
    }
    
    /**
        Bind the given external user ID to given FPID.
     
        - parameter fpid:           The FPID.
        - parameter externalID:     The external uesr ID.
        - parameter externalIDType: Type of the external user ID.
     */
    func bind(fpid: String, externalID: String, externalIDType: ExternalIDType, completion: @escaping (FunPlusIDResult) -> Void) {
        let params = [
            "method":               "bind",
            "app_id":               funPlusConfig.appId,
            "fpid":                 fpid,
            "external_id":          externalID,
            "external_id_type":     externalIDType.rawValue
        ]
        
        request(params: params, completion: completion)
    }
    
    // MARK: - Helper Methods
    
    /**
        Send request to the Passport Server.
     
        - parameter params:     The dictionary of parameters.
        - parameter complete:   The completion callback.
     */
    func request(params: [String: String], completion: @escaping (FunPlusIDResult) -> Void) {
        let appId = funPlusConfig.appId
        let endpoint = funPlusConfig.environment == .sandbox ? PassportEndpoint.sandbox.rawValue : PassportEndpoint.production.rawValue
        let url = "\(endpoint)?ver=\(PassportClient.API_VERSION)"
        let sig = makeSignature(params: params)
        
        RequestSessionManager.default.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["authorization": "FP \(appId):\(sig)"])
            .validate()
            .responseJSON { res in
                //==============================================
                //     Step 1: Check response
                //==============================================
                guard let json = res.result.value as? [String: AnyObject] else {
                    self.getLogger().e("Network failure")
                    completion(.failure(error: .networkError))
                    return
                }
                
                //==============================================
                //     Step 2: Check status
                //==============================================
                guard let status = json["status"] as? Int else {
                    self.getLogger().e("Invalid response")
                    completion(.failure(error: .unknownError))
                    return
                }
                
                //==============================================
                //     Step 3: Check if status is ok
                //==============================================
                guard status == 1 else {
                    if let errCode = json["error"] as? Int {
                        completion(.failure(error: .serverError(code: errCode)))
                    } else {
                        completion(.failure(error: .unknownError))
                    }
                    return
                }
                
                //==============================================
                //     Step 4: Check data
                //==============================================
                guard
                    let data = json["data"] as? [String: AnyObject],
                    let fpid = data["fpid"] as? String
                else {
                    // Should never reach here.
                    self.getLogger().e("Invalid response")
                    completion(.failure(error: .unknownError))
                    return
                }
                
                //==============================================
                //     Okay
                //==============================================
                self.getLogger().i("Passport response OK")
                completion(.success(fpid: fpid))
        }
    }
    
    /**
        Generate the signature for the given parameters.
     
        This method should work normally even if the `params` dictionary is empty.
     
        1. Sort the `params` dictionary by its keys.
        2. Join every values of the sorted `params` dictionary.
        3. Calculate the HMAC hex string of the joined string.
        4. Generate the final Base64 encoded string.
     
        - parameter params:     The given parameters dictionary.
     
        - returns: The generated signature.
     */
    func makeSignature(params: [String: String]) -> String {
        if params.isEmpty {
            getLogger().w("params is empty")
        }
        
        var arr = [String]()
        let sortedKeys = params.keys.sorted()
        
        for key in sortedKeys {
            arr.append("\(key)=\(params[key]!)")
        }
        
        let s = arr.joined(separator: "&")
        let hex = try! HMAC(key: [UInt8](funPlusConfig.appKey.utf8), variant: .sha256).authenticate([UInt8](s.utf8)).toHexString()
        return hex.data(using: String.Encoding.utf8)!.base64EncodedString()
    }
    
    func getLogger() -> Logger {
        return FunPlusFactory.getLogger(funPlusConfig: funPlusConfig)
    }
}
