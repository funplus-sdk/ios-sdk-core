//
//  LogAgentDataUploader.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 3/29/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - CompletionHandler

/**
    The `CompletionHandler` is used as callback function when uploading finishes.
 
    - parameter status:     The status of this uploading process.
    - parameter total:      The total count of logs.
    - parameter uploaded:   The count of logs uploaded. If status is `true`, this value
                            should equal to the `total` value.
 */
typealias CompletionHandler = (_ status: Bool, _ total: Int, _ uploaded: Int) -> Void

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
    
    /// The uploading history.
    var uploadHistory = [
        (status: Bool, total: Int, uploaded: Int, batch: Int, start: Date, duration: TimeInterval)
    ]()
    
    /// The requests history.
    var requestHistory = [
        (status: Bool, request: URLRequest, response: URLResponse, timeline: Timeline)
    ]()
    
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
        (either succeeds or fails), an optional completion callback will be called.
     
        Data might not be ready at this moment, invoke `dataPreparationHandler()` to
        properly handle data before uploading.
     
        - parameter data:       The data set to be uploaded.
        - parameter completion: The completion callback. `nil` by default.
     */
    func upload(_ data: [String], completion: @escaping CompletionHandler) {
        var closure: ((Void) -> Void)!
        let total = data.count
        var uploaded = 0

        closure = {
            // Upload completes? Return.
            guard total > uploaded else {
                completion(total == uploaded, total, uploaded)
                return
            }
            
            // Batch size must not exceed MAX_BATCH_SIZE.
            let batchSize = min(total - uploaded, self.MAX_BATCH_SIZE)
            let batch = Array(data[0..<batchSize])
            
            let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
            let sig = "\(self.tag):\(timestamp):\(self.key)".md5()
            let url = "\(self.endpoint)?tag=\(self.tag)&timestamp=\(timestamp)&num=\(batchSize)&signature=\(sig)"
            let requestBody = batch.joined(separator: "\n").data(using: String.Encoding.utf8)
            
            let startTime = Date()
            
            RequestSessionManager.default.upload(requestBody!, to: url).responseString { res in
                if let request = res.request, let response = res.response {
                    self.requestHistory.append(
                        (res.response?.statusCode == 200, request, response, res.timeline)
                    )
                }
                
                guard res.response?.statusCode == 200 && res.result.value == "OK" else {
                    self.uploadHistory.append((
                        status: true,
                        total: total,
                        uploaded: uploaded,
                        batch: batchSize,
                        start: startTime,
                        duration: NSDate().timeIntervalSince(startTime)
                    ))
                    
                    completion(total == uploaded, total, uploaded)
                    
                    // Break.
                    return
                }
                
                uploaded += batchSize
                
                self.uploadHistory.append((
                    status: true,
                    total: total,
                    uploaded: uploaded,
                    batch: batchSize,
                    start: startTime,
                    duration: NSDate().timeIntervalSince(startTime)
                ))
                
                // Continue.
                closure()
            }
        }

        closure()
    }
}
