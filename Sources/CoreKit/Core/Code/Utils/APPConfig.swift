//
//  APPConfig.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/3.
//

import Foundation

//public let CachePool = APP.cachePool
public class APP {
    private static let cachePathName = "com.hz_tech.core.appconfig"
    private struct CacheKey {
        static var status = "com.hz_tech.core.appcache.status"
//        static var token = "com.hz_tech.core.appcache.token"
    }
    /*
     APP的运行时管理器
     */
    public static var manager = Static.instance
    private struct Static {
        static let instance = APP()
    }
    /*
     缓存池，读写本地数据
     */
    public static var cachePool: FunBox.Cache {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        // 指定缓存路径
        let cachePool = FunBox.Cache.init(path: directoryPath! + "/\(APP.cachePathName)")
        // 缓存有效期为30天
        cachePool.cacheTimeOut = 2592000
        return cachePool
    }
    
    
    // 状态信息
    private var _status: Status?
    public var status: Status? {
        get {
            if _status == nil {
                if let data = APP.cachePool.loadCache(key: CacheKey.status), let string = String(data: data, encoding: .utf8) {
                    _status = Status.deserialize(from: string)
                } else {
                    _status = Status()
                }
            }
            
            return _status
        }
        
        set {
           _status = newValue
            if let string = newValue?.toJSONString() {
                APP.cachePool.cache(key: CacheKey.status, data: string.data(using: String.Encoding.utf8))
            } else {
                APP.cachePool.removeCache(key: CacheKey.status)
            }
            
        }
    }
    
    public lazy var info: Info? = {
        let info = Info.deserialize(from: Bundle.main.infoDictionary)
        
        return info
    }()
}

extension APP {
    public struct Info: HandyJSON {
        public init() {}
        // APP DisplayName
        public var name: String?
        // Short version
        public var version: String?
        // Build version
        public var build: String?
        
        mutating public func mapping(mapper: HelpingMapper) {
            mapper.specify(property: &name, name: "CFBundleDisplayName")
            mapper.specify(property: &version, name: "CFBundleShortVersionString")
            mapper.specify(property: &build, name: "CFBundleVersion")
        }
    }
    // 状态信息
    public struct Status: HandyJSON {
        public init() {}
        // 初次启动
        public var isFirstLaunch: Bool = true
    }

}

