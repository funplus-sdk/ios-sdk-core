//
//  OCExposer.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 24/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - OCExposer

//
// The `OCExposer` class is used to expose Swift APIs to Objective-C layer.
//
@objc public class OCExposer : NSObject {
    
    // MARK: - FunPlusSDK
    
    // Deprecated
    @objc public class func install(appId: String, appKey: String, environment: String) {
        guard let env = SDKEnvironment(rawValue: environment) else {
            print("[FATAL] Cannot resolve the `environment` parameter")
            return
        }
        
        do {
            try FunPlusSDK.install(appId: appId, appKey: appKey, environment: env)
        } catch let e {
            print("[FATAL] Failed to install FunPlus SDK, error: \(e)")
        }
    }
    
    @objc public class func install(
        appId: String,
        appKey: String,
        rumTag: String,
        rumKey: String,
        environment: String)
    {
        guard let env = SDKEnvironment(rawValue: environment) else {
            print("[FATAL] Cannot resolve the `environment` parameter")
            return
        }
        
        FunPlusSDK.install(
            appId: appId,
            appKey: appKey,
            rumTag: rumTag,
            rumKey: rumKey,
            environment: env
        )
    }
    
    @objc public class func getFPID(
        externalID: String,
        externalIDTypeString: String,
        onSuccess: @escaping (_ fpid: String) -> Void,
        onFailure: @escaping (_ error: String) -> Void)
    {
        let externalIDType = ExternalIDType(rawValue: externalIDTypeString) ?? ExternalIDType.inAppUserID
        FunPlusSDK.getFunPlusID().get(externalID: externalID, externalIDType: externalIDType) { result in
            switch (result) {
            case .success(let fpid):
                onSuccess(fpid)
                return
            case .failure(let error):
                onFailure(error.localizedDescription)
                return
            }
        }
    }
    
    @objc public class func bindFPID(
        fpid: String,
        externalID: String,
        externalIDTypeString: String,
        onSuccess: @escaping (_ fpid: String) -> Void,
        onFailure: @escaping (_ error: String) -> Void)
    {
        let externalIDType = ExternalIDType(rawValue: externalIDTypeString) ?? ExternalIDType.inAppUserID
        FunPlusSDK.getFunPlusID().bind(fpid: fpid, externalID: externalID, externalIDType: externalIDType) { result in
            switch (result) {
            case .success(let fpid):
                onSuccess(fpid)
                return
            case .failure(let error):
                onFailure(error.localizedDescription)
                return
            }
        }
    }
    
    // MARK: - FunPlusRUM
    
    @objc public class func traceRUMServiceMonitoring(
        serviceName: String,
        httpUrl: String,
        httpStatus: String,
        requestSize: Int,
        responseSize: Int,
        httpLatency: Int64,
        requestTs: Int64,
        responseTs: Int64,
        requestId: String,
        targetUserId: String,
        gameServerId: String)
    {
        FunPlusSDK.getFunPlusRUM().traceServiceMonitoring(
            serviceName: serviceName,
            httpUrl: httpUrl,
            httpStatus: httpStatus,
            requestSize: requestSize,
            responseSize: responseSize,
            httpLatency: httpLatency,
            requestTs: requestTs,
            responseTs: responseTs,
            requestId: requestId,
            targetUserId: targetUserId,
            gameServerId: gameServerId
        )
    }
    
    @objc public class func setRUMExtraProperty(key: String, value: String) {
        FunPlusSDK.getFunPlusRUM().setExtraProperty(key: key, value: value)
    }
    
    @objc public class func eraseRUMExtraProperty(key: String) {
        FunPlusSDK.getFunPlusRUM().eraseExtraProperty(key: key)
    }
    
    // MARK: - FunPlusData
    
    @objc public class func traceDataCustom(eventString: String) {
        guard let data = eventString.data(using: String.Encoding.utf8) else {
            print("Invalid custom event string")
            return
        }
        
        do {
            let serializedEvent = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            guard let event = serializedEvent else {
                print("Invalid custom event string")
                return
            }
            
            FunPlusSDK.getFunPlusData().traceCustom(event: event)
        } catch let e {
            print("Invalid custom event string, error: \(e)")
        }
    }
    
    @objc public class func traceDataPayment(
        amount: Double,
        currency: String,
        productId: String,
        productName: String?,
        productType: String?,
        transactionId: String,
        paymentProcessor: String,
        itemsReceived: String,
        currencyReceived: String,
        currencyReceivedType: String)
    {
        FunPlusSDK.getFunPlusData().tracePayment(
            amount: amount,
            currency: currency,
            productId: productId,
            productName: productName,
            productType: productType,
            transactionId: transactionId,
            paymentProcessor: paymentProcessor,
            itemsReceived: itemsReceived,
            currencyReceived: currencyReceived,
            currencyReceivedType: currencyReceivedType
        )
    }
    
    @objc public class func setDataExtraProperty(key: String, value: String) {
        FunPlusSDK.getFunPlusData().setExtraProperty(key: key, value: value)
    }
    
    @objc public class func eraseDataExtraProperty(key: String) {
        FunPlusSDK.getFunPlusData().eraseExtraProperty(key: key)
    }
}
