//
//  LogAgentClient.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 3/30/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ProgressHandler

/**
    The `ProgressHandler` is used as callback function when data is being uploaded.
 
    - parameter status:     The status of this uploading process.
    - parameter total:      The total count of logs.
    - parameter uploaded:   The count of logs uploaded.
 */
typealias ProgressHandler = (_ status: Bool, _ total: Int, _ uploaded: Int) -> Void

// MARK: - LogAgentClient

class LogAgentClient {
    
    // MARK: - Properties
    
    /// The max allowed size of data queue.
    static let MAX_QUEUE_SIZE = 2000
    
    /// The SDK configurations.
    let funPlusConfig: FunPlusConfig
    
    /// The label of current `LogAgentClient` instance, **should be globally unique**.
    let label: String
    
    /// The uploader used to upload data to FunPlus Log Agent.
    let uploader: LogAgentDataUploader
    
    /// The data container used to cache all incoming data. It is actually a mutable string array.
    var dataQueue: [[String: Any]]
    
     /// The serial operation queue.
    let serialQueue: DispatchQueue
    
    /// The file path used to archive data that hasn't been uploaded when app terminates.
    let archiveFilePath: String
    
    /// The time interval when to tick an upload progress.
    var uploadInterval: TimeInterval
    
    /// The timer used to periodically tick an upload progress.
    var timer: Timer? = nil
    
    /// The periodically callback when data is being uploaded.
    var progress: ProgressHandler?
    
    // MARK: - Init & Deinit
    
    /**
        Create a new `LogAgentClient` instance.
     
        - parameter funPlusConfig:  The SDK configurations.
        - parameter label:          A globally unique label.
        - parameter endpoint:       The endpoint of Log Agent.
        - parameter tag:            The Log Agent tag.
        - parameter key:            The Log Agent key.
        - parameter uploadInterval: The interval of uploading processes.
        - parameter progress:       An optional progress callback.
     */
    public init(
        funPlusConfig: FunPlusConfig,
        label: String,
        endpoint: String,
        tag: String,
        key: String,
        uploadInterval: TimeInterval = 10.0,
        progress: ProgressHandler? = nil)
    {
        self.funPlusConfig = funPlusConfig
        self.label = label
        self.uploader = LogAgentDataUploader(funPlusConfig: funPlusConfig, endpoint: endpoint, tag: tag, key: key)
        self.uploadInterval = uploadInterval
        self.progress = progress
        
        serialQueue = DispatchQueue(label: label, attributes: [])
        archiveFilePath = {
            let filename = "logger-archive-\(label).log"
            let libraryDirectory = FileManager().urls(for: .libraryDirectory, in: .userDomainMask).last!
            return libraryDirectory.appendingPathComponent(filename).path
        }()
        
        // Unarchive local stored data.
        dataQueue = NSKeyedUnarchiver.unarchiveObject(withFile: archiveFilePath) as? [[String: Any]] ?? []
        // Clear local stored data.
        NSKeyedArchiver.archiveRootObject([], toFile: archiveFilePath)
        
        registerNotificationObservers()
        startTimer()
    }
    
    deinit {
        stopTimer()
        unregisterNotificationObservers()
    }
    
    // MARK: - Trace & Upload & Archive
    
    /**
        Trace an entry.
     
        - parameter entry: The entry to be traced.
     */
    func trace(entry: [String: Any]) {
        serialQueue.async {
            if (self.dataQueue.count >= LogAgentClient.MAX_QUEUE_SIZE) {
                self.dataQueue.remove(at: 0)
            }
            self.dataQueue.append(entry)
        }
    }
    
    /**
        Trace a batch of entries.
     
        - parameter entries: The batch of entries to be traced.
     */
    func trace(entries: [[String: Any]]) {
        for entry in entries {
            trace(entry: entry)
        }
    }
    
    /**
        Submit an upload process.
     */
    func upload() {
        serialQueue.async {
            guard self.dataQueue.count > 0 else { return }
            
            autoreleasepool {
            
                let batchSize = min(self.dataQueue.count, LogAgentDataUploader.MAX_BATCH_SIZE)
                let data = Array(self.dataQueue[0..<batchSize])
                self.dataQueue.removeSubrange(0..<batchSize)
                
                self.uploader.upload(data: data) { [weak self] status in
                    guard let that = self else { return }
                    
                    if status {
                        that.progress?(true, batchSize, batchSize)
                    } else {
                        that.progress?(false, 0, 0)
                        that.trace(entries: data)
                    }
                }
                
            }
        }
    }
    
    /**
        Archive current data queue to file.
     */
    func archive() {
        serialQueue.async {
            guard !self.dataQueue.isEmpty else {
                return
            }
            
            if NSKeyedArchiver.archiveRootObject(self.dataQueue, toFile: self.archiveFilePath) {
                print("\(self.label): \(self.dataQueue.count) entries archived")
                self.dataQueue.removeAll()
            }
        }
    }
    
    // MARK: - Timer
    
    /**
        Trigger an upload process.
     */
    @objc fileprivate func timedUpload() {
        self.upload()
    }
    
    /**
        Start the timer.
     */
    func startTimer() {
        // If `uploadInterval` is 0.0, do not start the timer.
        guard timer == nil, uploadInterval > 0.0 else {
            return
        }
        
        timer = Timer.scheduledTimer(
            timeInterval: uploadInterval,
            target: self,
            selector: #selector(timedUpload),
            userInfo: nil,
            repeats: true
        )
    }
    
    /**
        Stop the timer.
     */
    func stopTimer() {
        guard timer != nil else {
            return
        }
        
        timer!.invalidate()
        timer = nil
    }
    
    // MARK: - App Life Cycle

    /// When application did become active, we start the timer.
    @objc func appDidBecomeActive() {
        startTimer()
    }

    /// When application will resign active, we stop the timer.
    @objc func appWillResignActive() {
        stopTimer()
    }

    /// When application will terminate, we archive un-flushed data.
    @objc func appWillTerminate() {
        archive()
    }
    
    /**
        Register app life cycle notification observers.
     */
    fileprivate func registerNotificationObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        nc.addObserver(self, selector: #selector(self.appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        nc.addObserver(self, selector: #selector(self.appWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    /**
        Unregister notification observers.
     */
    fileprivate func unregisterNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
