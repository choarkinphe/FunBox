//
//  FunFreedom+Cache.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/9/12.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
public extension FunNetworking {
    
    func cache_request(element: FunNetworking.RequestElement, response: Data?) {
        FunBox.networkManager.request_cache.cache_request(element, response: response)
    }
    
    func remove_request(element: FunNetworking.RequestElement) {
        FunBox.networkManager.request_cache.remove_request(element)
    }
    
    func remove_request(identifier: String?) {
        FunBox.networkManager.request_cache.remove_request(identifier: identifier)
    }
    
    func load_request(element: FunNetworking.RequestElement) -> Data? {
        return FunBox.networkManager.request_cache.load_request(element)
    }
    
    
}

private extension FunBox.Cache {
    // 缓存
    func cache_request(_ element: FunNetworking.RequestElement, response: Data?) {
        guard let key_str = element.identifier else { return }
        
        cache(key: key_str, data: response, options: [.memory,.disk,.timeOut(element.cacheTimeOut ?? 60)])
        
        debugPrint("cache_request=",element.urlString ?? "")
    }
    // 按完整请求信息删除对应缓存
    func remove_request(_ element: FunNetworking.RequestElement) {
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
    func load_request(_ element: FunNetworking.RequestElement) -> Data? {
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

