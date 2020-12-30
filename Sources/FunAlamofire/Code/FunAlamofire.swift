//
//  FunFreedom.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/7/23.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import Alamofire
#if !COCOAPODS
import FunBox
#endif

import UIKit
// 缓存用的线程
fileprivate let FunNetworkCachePathName = "com.funfreedom.funnetwork.cache"
public typealias FunAlamofire = FunBox.Funfreedom

public protocol FunRequestable {
    var path: String { get }
    var methed: HTTPMethod { get }
    var params: [String: Any]? { get }
    var headers: HTTPHeaders? { get }
    var baseURL: URLConvertible? { get }
}

extension FunRequestable {
    public var methed: HTTPMethod { return .post }
    public var params: [String: Any]? { return nil }
    public var headers: HTTPHeaders? { return FunAlamofire.manager.headers }
    public var baseURL: URLConvertible? { return FunAlamofire.manager.baseURL }
}

extension String: FunRequestable {
    public var path: String {
        return self
    }
}

extension URLRequest: FunRequestable {
    public var path: String {
        return url?.relativePath ?? ""
    }
    public var methed: HTTPMethod {
        return HTTPMethod(rawValue: httpMethod?.uppercased() ?? "POST")
    }
    public var params: [String : Any]? {
        if let httpBody = httpBody {
            return try? JSONSerialization.jsonObject(with: httpBody, options: .allowFragments) as? [String : Any]
        }
        return nil
    }
    public var headers: HTTPHeaders? {
        if let allHTTPHeaderFields = allHTTPHeaderFields {
            var headers = HTTPHeaders()
            allHTTPHeaderFields.forEach { (item) in
                headers.add(name: item.key, value: item.value)
            }
            return headers
        }
        return nil
    }
    public var baseURL: URLConvertible? {
        return url?.host
    }
}

public extension FunBox {
    
    // 构建请求
    class Funfreedom {
        
        // 请求管理器
        fileprivate let session: Session
        public init(session: Session = Session.sessionManager) {
            self.session = session
        }
        
        public static var `default`: Funfreedom {
            
            let _kit = Funfreedom()
            
            return _kit
        }
        
        public static var manager: Manager {
            return Manager.Static.shared
        }
        
        public func request(to request: FunRequestable) -> FunAlamofire.Task {
            // 创建基本的请求任务
            if let request = request as? URLRequest {
                return FunAlamofire.Task(session: session, request: request)
            }
            let task = FunAlamofire.Task(session: session, path: request.path)
            task.params = request.params
            task.headers = request.headers
            task.baseURL = request.baseURL
            return task
        }
        
    }
    
}


// MARK: - Manager
extension FunAlamofire {
    public class Manager {
        
        fileprivate struct Static {
            static var shared: Manager = Manager()
        }
        // baseURL
        public var baseURL: URLConvertible?
        // 默认的公共请求头
        public var headers: HTTPHeaders?
        
        // 默认显示错误
        public var toast: Toast = .error
        
        public lazy var cachePool: FunBox.Cache = {
            
            // 默认的请求缓存放在temp下（重启或储存空间报警自动移除）
            // 生成对应的请求缓存工具
            var request_cache = FunBox.Cache.init(path: NSTemporaryDirectory() + "/\(FunNetworkCachePathName)")
            // 默认请求缓存的时效为2分钟
            request_cache.cacheTimeOut = 120
            
            return request_cache
            
            
        }()
    }
    
    // 用来检测所有请求，方便处理公共事件
    fileprivate class Monitor: EventMonitor {
        
        struct Static {
            static let instance_monitor = Monitor()
        }
        
        static var `default`: Monitor {
            return Static.instance_monitor
        }
        
    }
}

extension Session {
    public static let sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 15
        return Session(configuration: configuration, eventMonitors: [FunAlamofire.Monitor.default])
        
    }()
}

extension URLRequest {
    // 拼接默认的request标识
    var identifier: String? {
        
        guard let urlString = url?.absoluteString else { return nil}
        
        var key = urlString.fb.md5
        
//        if let header = allHTTPHeaderFields, header.count > 0, let data = try? JSONSerialization.data(withJSONObject: header, options: []), let header_string = String(data: data, encoding: String.Encoding.utf8) {
//            key = key + header_string
//        }
        
        if let params_string = httpBody?.fb.hexString.fb.md5 {
            key = key + params_string
        }
        
        return key.fb.md5
        
    }
    
    
}



