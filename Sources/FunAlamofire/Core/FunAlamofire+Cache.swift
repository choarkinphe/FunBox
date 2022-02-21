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
        
    // 缓存路径
    public var diskCachePath: String { return "com.funalamofire.requestcache" }
        
    // 请求缓存
    func cache(to task: FunAlamofire.Task, timeOut: TimeInterval, response: FunAlamofire.Response) {
        pool.cache(key: task.cacheKey, data: response.data, options: [.memory, .timeOut(timeOut)])
    }
    
    // 删除缓存
    func remove(from task: FunAlamofire.Task) {
        pool.removeCache(key: task.cacheKey)
    }
    
    // 读取缓存
    func load(from task: FunAlamofire.Task) -> FunAlamofire.Response? {
        if let data = pool.loadCache(key: task.cacheKey) {
            return FunAlamofire.Response(data: data, request: nil, response: nil)
        }
        return nil
    }
}
