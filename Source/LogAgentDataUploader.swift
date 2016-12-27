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
    static let MAX_BATCH_SIZE = 100
    
    /// The configurations.
    let funPlusConfig: FunPlusConfig
    
    /// The endpoint where to upload data to.
    let endpoint: String
    
    /// The FunPlus Log Agent tag.
    let tag: String
    
    /// The FunPlus Log Agent key.
    let key: String
    
    // MARK: - Init
    
    /**
        Create a `LogAgentDataUploader` instance.
     
        - parameter funPlusConfig:  The configurations.
        - parameter endpoint:       The Log Agent endpoint.
        - parameter tag:            The tag used to request to Log Agent.
        - parameter key:            The key used to request to Log Agent.
     
        - returns:  The created instance.
     */
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
    func upload(data: [[String: Any]], completion: @escaping (Bool) -> Void) {
        let total = data.count
        
        guard total > 0 else {
            completion(false)
            return
        }
        
        // Batch size must not exceed MAX_BATCH_SIZE.
        let batchSize = min(total, LogAgentDataUploader.MAX_BATCH_SIZE)
        let subArray = Array(data[0..<batchSize])
        let batch = subArray.map { item -> String in
            autoreleasepool {
                do {
                    let data = try JSONSerialization.data(withJSONObject: item, options: [])
                    if let json = String(data: data, encoding: .utf8) {
                        return json
                    } else {
                        return ""
                    }
                } catch {
                    return ""
                }
            }
        }
        
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let sig = "\(self.tag):\(timestamp):\(self.key)".md5()
        let url = "\(self.endpoint)?tag=\(self.tag)&timestamp=\(timestamp)&num=\(batchSize)&signature=\(sig)"
        let requestBody = batch.joined(separator: "\n").data(using: String.Encoding.utf8)

        LogAgentDataUploader.request(url: url, data: requestBody!) { status in
            completion(status)
        }
    }
    
    /**
        Submit a request.
     
        - parameter url:    The URL to request to.
        - parameter data:   The data to be attached in request body.
        - completion:       The completion callback with one parameter
                            indication the request status.
     */
    private class func request(
        url: String,
        data: Data,
        completion: @escaping (Bool) -> ())
    {
        // Compose the URL.
        guard let url = URL(string: url) else {
            completion(false)
            return
        }
        
        autoreleasepool {
        
            // Compose the request.
            var request = URLRequest(url: url)
            request.httpMethod = "post"
            request.httpBody = data
            
            // Use the default shared session.
            let session = URLSession.shared
            session.uploadTask(with: request, from: data) { (data, res, error) -> Void in
                autoreleasepool {
                    
                    //==============================================
                    //     Step 1: Check response status
                    //==============================================
                    guard let res = res as? HTTPURLResponse, res.statusCode == 200 else {
                        completion(false)
                        return
                    }
                    
                    //==============================================
                    //     Step 2: Check response body
                    //==============================================
                    guard let data = data, String(data: data, encoding: String.Encoding.utf8) == "OK" else {
                        completion(false)
                        return
                    }
                    
                    //==============================================
                    //     Okay
                    //==============================================
                    completion(true)
                    session.reset {}
                        
                }
            }.resume()
            
        }
    }
}
