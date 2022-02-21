//
//  FunFreedom.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/7/23.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import Alamofire
import FunBox

import UIKit
import Accelerate
// 缓存用的线程
public typealias FunAlamofire = FunBox.Funfreedom
public protocol FunRequestable {
    var path: String { get }
    var method: HTTPMethod { get }
    var params: FunParams? { get }
    var headers: HTTPHeaders? { get }
    var baseURL: URLConvertible? { get }
}

extension FunRequestable {
    public var method: HTTPMethod { return .post }
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
    public var method: HTTPMethod {
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
        
//        private var tasks = [String: FunAlamofire.Task]()
//        
//        func add(task: FunAlamofire.Task) {
//            tasks[task.cacheKey] = task
//        }
        
        public func request(to request: FunRequestable) -> FunAlamofire.Task {
            // 创建基本的请求任务
            return FunAlamofire.Task(session: session, request: request)
        }
        
        public func download(to request: FunRequestable) -> FunAlamofire.DownLoadTask {
            // 创建下载请求任务
            return FunAlamofire.DownLoadTask(session: session, request: request)
        }
        
        public func upload(to request: FunRequestable) -> FunAlamofire.UpLoadTask {
            // 创建上传请求任务
            return FunAlamofire.UpLoadTask(session: session, request: request)
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



