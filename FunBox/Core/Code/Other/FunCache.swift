//
//  ResponseCache.swift
//  ResponseCache
//
//  Created by choarkinphe on 2019/9/9.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import CommonCrypto

public protocol FunCacheKey {
    var rawValue: String { get }
}

extension String: FunCacheKey {
    public var rawValue: String {
        return self
    }
}

public typealias FunCache = FunBox.Cache
fileprivate let FunCachePathName = "com.FunBox.funcache"
public extension FunBox {
    static var cache: Cache {
        
        return Cache.default
    }
    class Cache {
        
        private struct Static {
            // 生成默认的缓存路径
            static var instance: Cache = Cache(path: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + FunCachePathName)
        }
        
        static var `default`: Cache {
            return Static.instance
        }
        
        let diskCachePath: String
        public init(path: String) {
            diskCachePath = path
        }

        // 内存缓存
        private var memoryCache = NSCache<NSString,NSData>()
        // 任务对列
        private lazy var ioQueue = DispatchQueue(label: "com.FunBox.cache_io.\(diskCachePath)")
        private lazy var fileManager = FileManager.default
        // 默认缓存时效为1周
        public var cacheTimeOut: TimeInterval = 604800
        
        
        /*
            缓存目录下增加一个索引文件
         */
        private let index_key = "index"
        // 缓存的索引
        public lazy var indexes: [String: String] = {
            var indexes = [String: String]()
            
            let decoder = JSONDecoder()
            // 解码数据
            if let data = loadCache(key: index_key), let result = try? decoder.decode([String: String].self, from: data) {
                indexes = result
            }
            
            return indexes
        }()
        
        public func cache(key: FunCacheKey?, data: Data?, options: FunCacheOptions = [.memory,.disk]) {
            
            // 保存数据
                self.cacheData(key: key, data: data, options: options)

            // 保存索引
            if let index = key?.rawValue {
                indexes[index] = cachePathForKey(key: key)
                // 写入索引(索引的有效期设置为10年----伪永久有效)
//                let string = indexes.joined(separator: "(&)")
                
//                cacheData(key: index_key, data: string.data(using: .utf8), options: [.memory,.disk,.timeOut(315360000)])
                
                write_indexes()
            }
            
        }
        
        // 写入索引
        private func write_indexes() {
            // 获取真实的Data
            let encoder = JSONEncoder()
//            indexes[index] = cachePathForKey(key: index)
            do {
                
                let data = try encoder.encode(indexes)
                
                cacheData(key: index_key, data: data, options: [.memory,.disk,.timeOut(315360000)])
                
            } catch let error {
                debugPrint("FunBoxCache: \(error.localizedDescription)")
                
            }
        }
        
        // 最终的缓存方法
        fileprivate func cacheData(key: FunCacheKey?, data: Data?, options: FunCacheOptions = [.memory,.disk]) {

            ioQueue.async {

                // 获取保存地址，判断缓存数据是否存在
                guard let data = data, let cachePath = self.cachePathForKey(key: key) else { return }
                
                // 获取当前时间
                let load_time = Date().timeIntervalSince1970
                // 计算失效时间
                var invalid_time = load_time + self.cacheTimeOut
                // 分析options，作出相应处理
                options.asOptions().forEach { (item) in
                    // 有单独设置过失效时间的
                    if item == .timeOut(0), let timeOut = item.external as? TimeInterval {
                        // 按照单独设置的有效期来设置失效时间
                        invalid_time = load_time + timeOut
                    }
                }
                // 创建真实的缓存模型（直接算出时效时间，并存储） * 优先存储传入的有效期，没有再读取默认值
                let cacheModel = CacheData(data: data, invalid_time: invalid_time)

                // 获取真实的Data
                let encoder = JSONEncoder()
                
                do {
                    let cacheData = try encoder.encode(cacheModel)
                    
                    
                    if options.asOptions().contains(.memory) {
                        // 放进缓存池
                        self.memoryCache.setObject(cacheData as NSData, forKey: NSString(string: cachePath))
                    }

                    // 写入
                    if options.asOptions().contains(.disk) {

                        if !self.fileManager.fileExists(atPath: self.diskCachePath) {
                            
                            try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                            
                            }
                            
                            if !NSKeyedArchiver.archiveRootObject(cacheData, toFile: cachePath) {
                                debugPrint("FunBoxCache: archive failed")
                            }
                        
                        
                        
                    }

                } catch let error {
                    debugPrint("FunBoxCache: \(error.localizedDescription)")
                    
                }

            }
            
        }
        
        public func contains(_ key: FunCacheKey?) -> Bool {
            guard let key = key else { return false }
            // 先在索引中查找文件
            if indexes[key.rawValue] != nil  {
                return true
            }
            return containsData(key: key)
        }
        
        private func containsData(key: FunCacheKey?) -> Bool {
            guard let key = key else { return false }

            // 索引中未找到，再查询文件目录
            guard let cachePath = self.cachePathForKey(key: key) else { return false }
            // 查找内存缓存
            if memoryCache.object(forKey: NSString(string: cachePath)) != nil {
                return true
            }
            
            // 查找磁盘缓存
            var exists = fileManager.fileExists(atPath: cachePath)
            
            if !exists {
                exists = fileManager.fileExists(atPath: diskCachePath)
            }
            
            return exists
        }
        
        
        public func loadCache(key: FunCacheKey?) -> Data? {
            
            guard let cachePath = self.cachePathForKey(key: key), containsData(key: key) else { return nil }
            
            // 获取内存缓存
            if let cacheData = memoryCache.object(forKey: NSString(string: cachePath)) {
                return proving(key: key, data: cacheData as Data)
            }
            // 读取磁盘缓存
            if let cacheData = NSKeyedUnarchiver.unarchiveObject(withFile: cachePath) as? Data {
                return proving(key: key, data: cacheData)
                
            }
            
            return nil
        }
        
        // 验证程序（判断有效期，或者拓展其他）
        private func proving(key: FunCacheKey?, data: Data) -> Data? {
            
            let decoder = JSONDecoder()
            // 解码数据
            if let cacheModel = try? decoder.decode(CacheData.self, from: data) {
                // 获取当前时间
                let load_time = Date().timeIntervalSince1970
                // 失效时间在当前时间以前,删除当前数据，且不返回数据
                if let invalid_time = cacheModel.invalid_time, invalid_time < load_time {
                    
                    removeCache(key: key)
                    
                    return nil
                }
                return cacheModel.data
            }
            
            return nil
        }
        
        // 删除指定的缓存数据
        public func removeCache(key: FunCacheKey?) {
            
            guard let key = key else { return }
            ioQueue.async {
                guard let cachePath = self.cachePathForKey(key: key) else { return }
                // 删除memory缓存
                self.memoryCache.removeObject(forKey: NSString(string: cachePath))
                // 删除磁盘缓存
                try? self.fileManager.removeItem(atPath: cachePath)
                // 清除索引(如果有)
//                if let index = self.indexes.firstIndex(of: key.rawValue) {
//                    self.indexes.remove(at: index)
//                    let string = self.indexes.joined(separator: "(&)")
//                    self.cacheData(key: self.index_key, data: string.data(using: .utf8), options: [.memory,.disk,.timeOut(315360000)])
//                }
                self.indexes.removeValue(forKey: key.rawValue)
                
                self.write_indexes()
            }
            
        }
        
        // 清除所有缓存
        public func removeAllCache() {
            ioQueue.async {
                
                // 清空缓存池
                self.memoryCache.removeAllObjects()
                // 清空磁盘
                try? self.fileManager.removeItem(atPath: self.diskCachePath)
                //  清空索引
                self.indexes.removeAll()
            }
        }
        
        // 计算本地缓存的大小
        public var totalSize: Int
        {
            
            
            var size = 0
            if let fileEnumerator = fileManager.enumerator(atPath: diskCachePath) {
                for file in fileEnumerator {
                    if let fileName = file as? String {
                        let filePath = diskCachePath + "/\(fileName)"
                        if let attrs = try? fileManager.attributesOfItem(atPath: filePath) {
                            size = attrs.count + size
                        }
                    }
                    
                    
                }
            }
            
            return size
        }
        
        // 将key进行一次md5，拼接最终储存路径（防止key过长与重复）
        private func cachePathForKey(key: FunCacheKey?) -> String? {
            
            if let fileName = key?.rawValue.md5 {
                
                return diskCachePath + "/\(fileName)"
            }
            
            return nil
        }
        
        
    }
    
}

extension String {
    fileprivate var md5: String {
        
        if let utf8 = cString(using: .utf8), !utf8.isEmpty {
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(utf8, CC_LONG(utf8.count - 1), &digest)
            return digest.reduce("") { $0 + String(format:"%02X", $1)
                
            }
        }
        return self
    }
}

public protocol FunCacheOptions {
    func asOptions() -> [FunBox.Cache.Option]
}
private typealias Options = [FunBox.Cache.Option]
extension FunBox.Cache {
    public struct Option: Equatable {
        public static func == (lhs: FunBox.Cache.Option, rhs: FunBox.Cache.Option) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        let rawValue: String
        var external: Any?
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        public static let disk = Option(rawValue: "disk")
        public static let memory = Option(rawValue: "memory")
        public static func timeOut(_ time: TimeInterval) -> Option {
            var timeOut = Option(rawValue: "timeOut")
            timeOut.external = time
            return timeOut
        }
        
    }
    
    fileprivate class CacheData: Codable {
        var data: Data? // 缓存数据
        var invalid_time: TimeInterval? // 失效时间
        
        private enum CodingKeys: String,CodingKey {
            case data
            case invalid_time
        }
        
        init(data: Data?, invalid_time: TimeInterval?) {
            self.data = data
            self.invalid_time = invalid_time
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            data = try container.decode(Data.self, forKey: .data)
            invalid_time = try container.decode(TimeInterval.self, forKey: .invalid_time)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(data, forKey: .data)
            try container.encode(invalid_time, forKey: .invalid_time)
        }
    }
}

extension Options: FunCacheOptions {
    public func asOptions() -> [FunBox.Cache.Option] {
        return self
    }
}

extension FunBox.Cache.Option: FunCacheOptions {
    public func asOptions() -> [FunBox.Cache.Option] {
        return [self]
    }
}

// MARK: - 内部缓存
extension FunBox {
    
    struct CacheKey {
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    private static let cachePathName = "com.funbox.core.cache"
    
    static var cachePool: Cache {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        // 指定缓存路径
        let cachePool = FunBox.Cache.init(path: directoryPath! + "/\(cachePathName)")
        // 缓存有效期为300天
        cachePool.cacheTimeOut = 25920000
        return cachePool
    }
}

extension FunCache {
    func cache(key: FunBox.CacheKey, data: Data?) {
        FunBox.cachePool.cache(key: key.rawValue, data: data)
    }
    
    func load(key: FunBox.CacheKey) -> Data? {
        return FunBox.cachePool.loadCache(key: key.rawValue)
    }
}
