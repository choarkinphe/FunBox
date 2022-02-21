//
//  FunFreedom+Cache.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/9/12.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import FunBox
//import Alamofire
//#if !COCOAPODS
//import FunBox
//#endif

extension FunAlamofire: FunCacheable {
//    struct Cache: FunCacheable {
        
        // 缓存路径
        public var diskCachePath: String { return "com.funalamofire.requestcache" }
        
//    }
    
    func cache(to task: FunAlamofire.Task, timeOut: TimeInterval, response: FunAlamofire.Response) {
        pool.cache(key: task.cacheKey, data: response.data, options: [.memory, .timeOut(timeOut)])
    }
    
    func remove(from task: FunAlamofire.Task) {
//        FunAlamofire.manager.request_cache.remove_request(element)
        pool.removeCache(key: task.cacheKey)
    }
    
    func load(from task: FunAlamofire.Task) -> FunAlamofire.Response? {
        if let data = pool.loadCache(key: task.cacheKey) {
            return FunAlamofire.Response(data: data, request: nil, response: nil)
        }
        return nil
    }
}

public extension FunAlamofire.Task {
    
//    fileprivate var cacheKey: String {
//        var url = path ?? ""
//        if let baseURL = try? baseURL?.asURL().absoluteString {
//            url = baseURL + url
//        }
//        return url.fb.md5
////        return ((baseURL?.asURL().absoluteString ?? "") + (path ?? "")).fb.md5
//    }
    

    

    
//    func cache_request(element: FunAlamofire.Task, response: Data?) {
//        FunAlamofire.manager.request_cache.cache_request(element, response: response)
//    }
//
//    func remove_request(element: FunAlamofire.Task) {
//        FunAlamofire.manager.request_cache.remove_request(element)
//    }
//
//    func remove_request(identifier: String?) {
//        FunAlamofire.manager.request_cache.remove_request(identifier: identifier)
//    }
//
//    func load_request(element: FunAlamofire.Task) -> Data? {
//        return FunAlamofire.manager.request_cache.load_request(element)
//    }
    
    
}
/*
private extension FunBox.Cache {
    // 缓存
    func cache_request(_ element: FunAlamofire.Task, response: Data?) {
        guard let key_str = element.identifier else { return }
        
        cache(key: key_str, data: response, options: [.memory,.disk,.timeOut(element.cacheTimeOut ?? 60)])
        
        debugPrint("cache_request=",element.urlString ?? "")
    }
    // 按完整请求信息删除对应缓存
    func remove_request(_ element: FunAlamofire.Task) {
        guard let key_str = element.identifier else { return }
        
        removeCache(key: key_str)
        
        debugPrint("remove_request=",element.urlString ?? "")
    }
    // 按标识符删除对应的缓存
    func remove_request(identifier: String?) {
        guard let key_str = identifier else { return }
        
        removeCache(key: key_str)
        
        debugPrint("remove_request=",identifier ?? "")
    }
    
    // 读取缓存
    func load_request(_ element: FunAlamofire.Task) -> Data? {
        guard let key_str = element.identifier,
            let cache_data = loadCache(key: key_str)
            else { return nil}
        
        debugPrint("load_request=",element.urlString ?? "")
        
        return cache_data
    }
    
//    private func format_key(session: FunFreedom.NetworkKit.RequestSession) -> String? {
//
//        if let identifier = session.identifier {
//            return identifier
//        }
//        guard let url = session.urlString else { return nil}
//        var key = url
//
//        if let header = session.headers, let data = try? JSONSerialization.data(withJSONObject: header, options: []), let header_string = String(data: data, encoding: String.Encoding.utf8) {
//            key = key + header_string
//        }
//
//        if let params = session.params, let data = try? JSONSerialization.data(withJSONObject: params, options: []), let params_string = String(data: data, encoding: String.Encoding.utf8) {
//            key = key + params_string
//        }
//
//        return key
//    }
}
 */
