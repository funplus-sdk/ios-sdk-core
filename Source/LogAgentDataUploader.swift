//
//  LogAgentDataUploader.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 3/29/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - LogAgentDataUploader

/// See http://wiki.ifunplus.cn/display/core/http+log+agent+API
class LogAgentDataUploader {
    
    // MARK: - Properties
    
    /// Max size of an upload batch.
    let MAX_BATCH_SIZE = 100
    
    let funPlusConfig: FunPlusConfig
    
    /// The endpoint where to upload data to.
    let endpoint: String
    
    /// The FunPlus Log Agent tag.
    let tag: String
    
    /// The FunPlus Log Agent key.
    let key: String
    
    // MARK: - Init
    
    init(funPlusConfig: FunPlusConfig, endpoint: String, tag: String, key: String) {
        self.funPlusConfig = funPlusConfig
        self.endpoint = endpoint
        self.tag = tag
        self.key = key
    }
    
    // MARK: - Upload
    
    /**
        Upload a given set of data to endpoint. When the uploading progress completes
        (either succeeds or fails), a completion callback will be called.
     
        - parameter data:       The data set to be uploaded.
        - parameter completion: The completion callback.
     */
    func upload(data: [String], completion: @escaping (Int) -> Void) {
        let total = data.count
        
        guard total > 0 else {
            completion(0)
            return
        }
        
        // Batch size must not exceed MAX_BATCH_SIZE.
        let batchSize = min(total, self.MAX_BATCH_SIZE)
        let batch = Array(data[0..<batchSize])
        
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let sig = "\(self.tag):\(timestamp):\(self.key)".md5()
        let url = "\(self.endpoint)?tag=\(self.tag)&timestamp=\(timestamp)&num=\(batchSize)&signature=\(sig)"
        let requestBody = batch.joined(separator: "\n").data(using: String.Encoding.utf8)
        
        RequestSessionManager.default.upload(requestBody!, to: url).responseString { res in
            guard res.response?.statusCode == 200 && res.result.value == "OK" else {
                print("[FunPlusSDK] Upload failed")
                completion(0)
                
                // Break.
                return
            }
            
            print("[FunPlusSDK] Upload success, uploaded: \(batchSize)")
            completion(batchSize)
        }
    }
    
    /**
     Upload a given set of data to endpoint. When the uploading progress completes
     (either succeeds or fails), a completion callback will be called.
     
     - parameter data:       The data set to be uploaded.
     - parameter completion: The completion callback.
     */
    func upload(data: [[String: Any]], completion: @escaping (Int) -> Void) {
        let total = data.count
        
        guard total > 0 else {
            completion(0)
            return
        }
        
        // Batch size must not exceed MAX_BATCH_SIZE.
        let batchSize = min(total, self.MAX_BATCH_SIZE)
        let batch = Array(data[0..<batchSize])
        
        print(batch)
        
//        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
//        let sig = "\(self.tag):\(timestamp):\(self.key)".md5()
//        let url = "\(self.endpoint)?tag=\(self.tag)&timestamp=\(timestamp)&num=\(batchSize)&signature=\(sig)"
//        let requestBody = batch.joined(separator: "\n").data(using: String.Encoding.utf8)
//        
//        RequestSessionManager.default.upload(requestBody!, to: url).responseString { res in
//            guard res.response?.statusCode == 200 && res.result.value == "OK" else {
//                print("[FunPlusSDK] Upload failed")
//                completion(0)
//                
//                // Break.
//                return
//            }
//            
//            print("[FunPlusSDK] Upload success, uploaded: \(batchSize)")
//            completion(batchSize)
//        }
    }
}
