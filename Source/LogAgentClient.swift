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
    
    static let MAX_QUEUE_SIZE = 1024
    
    let funPlusConfig: FunPlusConfig
    
    /// The label of current `LogAgentClient` instance, **should be globally unique**.
    let label: String
    
    /// The uploader used to upload data to FunPlus Log Agent.
    let uploader: LogAgentDataUploader
    
    /// The data container used to cache all incoming data. It is actually a mutable string array.
    var dataQueue = [[String: Any]]()
    
     /// The serial operation queue.
    let serialQueue: DispatchQueue
    
    /// The file path used to archive data that hasn't been uploaded when app terminates.
    let archiveFilePath: String
    
    /// The time interval when to tick an upload progress.
    var uploadInterval: TimeInterval
    
    /// The timer used to periodically tick an upload progress.
    var timer: Timer? = nil
    
    /// The network reachability manager.
    var networkReachabilityManager: NetworkReachabilityManager?
    
    /// The identifier of background task used by currnet `LogAgentClient` instance.
    var backgroundTaskId: UIBackgroundTaskIdentifier?
    
    /// Indicates if network is reachable.
    var isOffline: Bool = false
    
    /// Indicates if any upload progress is underlying.
    var isUploading: Bool = false
    
    /// The periodically callback when data is being uploaded.
    var progress: ProgressHandler?
    
    // MARK: - Init & Deinit
    
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
            let filename = "logger-archive-\(label).json"
            let libraryDirectory = FileManager().urls(for: .libraryDirectory, in: .userDomainMask).last!
            return libraryDirectory.appendingPathComponent(filename).path
        }()
        
        // Unarchive local stored data.
        dataQueue = unarchive() ?? []
        // Clear local stored data.
        NSKeyedArchiver.archiveRootObject([], toFile: archiveFilePath)
        
        networkReachabilityManager = NetworkReachabilityManager()
        
        registerNotificationObservers()
        registerNetworkListener()
        startTimer()
    }
    
    deinit {
        stopTimer()
        unregisterNetworkListener()
        unregisterNotificationObservers()
    }
    
    // MARK: - Trace & Upload & Archive
    
    func trace(entry: [String: Any]) {
        serialQueue.sync {
            if (self.dataQueue.count >= LogAgentClient.MAX_QUEUE_SIZE) {
                self.dataQueue.remove(at: 0)
            }
            self.dataQueue.append(entry)
        }
    }
    
    func trace(entries: [[String: Any]]) {
        for entry in entries {
            trace(entry: entry)
        }
    }
    
    func upload() {
        serialQueue.sync {
            guard !self.isUploading && !self.isOffline && self.dataQueue.count > 0 else { return }
            
            self.isUploading = true
            
            self.uploader.upload(data: &self.dataQueue) { [unowned self] uploaded in
                self.serialQueue.sync(execute: {
                    self.dataQueue.removeSubrange(0..<uploaded)
                    self.isUploading = false
//                    self.progress?(status, total, uploaded)
                })
            }
        }
    }
    
    func archive() {
        guard !dataQueue.isEmpty else {
            return
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dataQueue, options: [])
            if let json = String(data: data, encoding: .utf8) {
                if NSKeyedArchiver.archiveRootObject(json, toFile: archiveFilePath) {
                    print("\(label): \(dataQueue.count) entries archived")
                }
            }
        } catch {
        }
    }
    
    func unarchive() -> [[String: Any]]? {
        guard let json = NSKeyedUnarchiver.unarchiveObject(withFile: archiveFilePath) as? String else {
            return nil
        }
        
        guard let data = json.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        } catch {
            return nil
        }
    }
    
    // MARK: - Timer
    
    @objc fileprivate func timedUpload() {
        self.upload()
    }
    
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

    /// When application did enter background, we start a background task to
    /// flush data and then end the background task.
    @objc func appDidEnterBackground() {
        let app = UIApplication.shared
        self.backgroundTaskId = app.beginBackgroundTask (expirationHandler: {
            self.backgroundTaskId = UIBackgroundTaskInvalid
        })
        
        let executeBackgroundTask: () -> Void = { () in
            self.upload()
        }
        
        executeBackgroundTask()
        
        serialQueue.sync {
            if let backgroundTaskId = self.backgroundTaskId {
                app.endBackgroundTask(backgroundTaskId)
                self.backgroundTaskId = UIBackgroundTaskInvalid
            }
        }
    }

    /// When application will enter foreground, we end the background task
    /// if it is still alive.
    @objc func appWillEnterForeground() {
        let app = UIApplication.shared
        
        serialQueue.sync {
            if let backgroundTaskId = self.backgroundTaskId {
                app.endBackgroundTask(backgroundTaskId)
                self.backgroundTaskId = UIBackgroundTaskInvalid
            }
        }
    }

    /// When application will terminate, we archive un-flushed data.
    @objc func appWillTerminate() {
        archive()
    }
    
    fileprivate func registerNotificationObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        nc.addObserver(self, selector: #selector(self.appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        nc.addObserver(self, selector: #selector(self.appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        nc.addObserver(self, selector: #selector(self.appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        nc.addObserver(self, selector: #selector(self.appWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    fileprivate func unregisterNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Network Listener
    
    fileprivate func registerNetworkListener() {
        networkReachabilityManager?.listener = { status in
            switch status {
            case .reachable:
                self.isOffline = false
            case .notReachable, .unknown:
                self.isOffline = true
            }
        }
        
        networkReachabilityManager?.startListening()
    }
    
    fileprivate func unregisterNetworkListener() {
        networkReachabilityManager?.stopListening()
    }
}
