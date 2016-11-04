//
//  ConfigManager.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 6/1/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

// MARK: - FPCSEndpoint

enum FPCSEndpoint : String {
    case sandbox    = "https://fpcs-sandbox.funplusgame.com/service/gameconf"
    case production = "https://fpcs.funplusgame.com/service/gameconf"
}

// MARK: - FPCSResponse

enum FPCSResponse {
    case success(configEtag: String, configDict: [String: AnyObject])
    case failure(errorMsg: String)
}

// MARK: - ConfigManager

/**
    The `ConfigManager` class manages SDK configurations. It handles with the following tasks:
 
    1. Parse configurations from default config file.
    2. Load/save configurations from/to local storage.
    3. Fetch configurations from remote config server.
 */
class ConfigManager {
    
    static let ETAG_SAVED_KEY = "com.funplus.sdk.ConfigEtag"
    
    let appId: String
    let appKey: String
    let env: SDKEnvironment
    
    let url: String
    var configEtag: String
    var configDict = [String: Any]()
    
    var timer: Timer?
    let syncInterval: TimeInterval = 60.0
    
    let defaultConfigFilePath: String = {
        return Bundle.main.path(forResource: "funsdk-default-config", ofType: "plist")!
    }()
    
    let archiveConfigFilePath: String = {
        let filename = "funsdk-archive-config.plist"
        let libraryDirectory = FileManager().urls(for: .libraryDirectory, in: .userDomainMask).last!
        return libraryDirectory.appendingPathComponent(filename).path
    }()
    
    init(appId: String, appKey: String, environment: SDKEnvironment) {
        self.appId = appId
        self.appKey = appKey
        self.env = environment
        
        let endpoint = env == .sandbox ? FPCSEndpoint.sandbox.rawValue : FPCSEndpoint.production.rawValue
        url = "\(endpoint)?app_id=\(appId)&app_version=\(DeviceInfo.appVersion)&platform=ios"
        
        configEtag = UserDefaults.standard.string(forKey: ConfigManager.ETAG_SAVED_KEY) ?? ""
        configDict = load()
        
//        startTimer()
    }
    
    deinit {
        stopTimer()
    }
    
    func getFunPlusConfig() throws -> FunPlusConfig {
        return try FunPlusConfig(appId: appId, appKey: appKey, environment: env, configEtag: configEtag, configDict: configDict)
    }
    
    func load() -> [String: Any] {
        // TODO
//        var configDict = [String: AnyObject]()
        
//        if let dict = unarchive(), !dict.isEmpty {
//            configDict = dict
//        } else if let dict = parse() {
//            configDict = dict
//            archive()
//        } else {
//            // Lord, it is a miracle!
//            // TODO
//        }
        
//        return configDict
        return parse()!
    }
    
    func parse() -> [String: Any]? {
        let dict = NSDictionary(contentsOfFile: defaultConfigFilePath) as? [String: Any]
        return dict?[env.rawValue] as? [String: Any]
    }
    
    func fetch(completion: @escaping (_ response: FPCSResponse) -> Void) {
        let headers = ["If-None-Match": configEtag]
        
        RequestSessionManager.default.request(url, headers: headers).responseJSON { res in
            guard res.response?.statusCode == 200 else {
                completion(.failure(errorMsg: "Cannot retrieve configurations from remote server"))
                return
            }
            
            guard let configDict = res.result.value as? [String: AnyObject] else {
                completion(.failure(errorMsg: "Cannot convert response to dictionary"))
                return
            }
            
            let etag = res.response?.allHeaderFields["Etag"] as? String ?? ""
            completion(.success(configEtag: etag, configDict: configDict))
        }
    }
    
    @objc func sync() {
        fetch { res in
            switch res {
            case .success(let etag, let dict):
                if !etag.isEmpty && etag != self.configEtag {
                    self.configEtag = etag
                    self.configDict = dict
                    
                    self.archive()
                }
            case .failure:
                // TODO
                break
            }
        }
    }
    
    func archive() {
        UserDefaults.standard.set(configEtag, forKey: ConfigManager.ETAG_SAVED_KEY)
        NSKeyedArchiver.archiveRootObject(self.configDict, toFile: archiveConfigFilePath)
    }
    
    func unarchive() -> [String: Any]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: archiveConfigFilePath) as? [String: Any]
    }
    
    func startTimer() {
        // If `syncInterval` is 0.0, do not start the timer.
        if timer == nil && syncInterval > 0.0 {
            timer = Timer.scheduledTimer(
                timeInterval: syncInterval,
                target: self,
                selector: #selector(sync),
                userInfo: nil,
                repeats: true
            )
            timer!.fire()
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
