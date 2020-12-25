//
//  FunAlamofire+Response.swift
//  FunAlamofire
//
//  Created by 肖华 on 2019/9/14.
//

import Foundation
#if !COCOAPODS
import FunBox
#endif
import UIKit
// 最终发出请求响应
public typealias FunResponse = FunAlamofire.Response
public extension FunAlamofire {
    
    class Response {
        
        // 上传&下载进度
        public var progress: Progress?
        
        // 下载恢复文件
        public let resumeData: Data?
        
        // 真实的下载请求
        public let request: URLRequest?
        
        /// The server's response to the URL request.
        public let response: HTTPURLResponse?
        
        // 请求结果
        public var data: Data?
        // 错误信息
        public var error: Error?
        // 下载任务的地址
        public let fileURL: URL?
        
        
        public init(request: URLRequest?,
                    response: HTTPURLResponse?,
                    fileURL: URL?=nil,
                    resumeData: Data?=nil) {
            self.request = request
            self.response = response
            self.fileURL = fileURL
            self.resumeData = resumeData
            
        }
        
        

    }
}




extension FunResponse {
    struct Option {
        // toast配置，默认只给错误弹窗
        var toast: FunAlamofire.Toast = .error
        // display view
        var container: UIView?
        // 响应器
        var sender: UIView?
        
        var cache_timeOut: TimeInterval?
        
        static func deserialize(options: [FunAlamofire.Option]) -> FunResponse.Option {
            // 生成一组option
            var option = FunResponse.Option()
            
            options.forEach { (item) in
                // 找到响应器就先缓存
                if item == .sender {
                    option.sender = item.paramter as? UIView
                }
                // 配置option的toast信息
                if item == .toast, let paramter = item.paramter as? FunAlamofire.Toast {
                    option.toast = paramter
                }
                // option display view
                if item == .container, let paramter = item.paramter as? UIView {
                    option.container = paramter
                }
                // option cache timeOut
                if item == .cache, let paramter = item.paramter as? TimeInterval {
                    option.cache_timeOut = paramter
                }
            }
            
            return option
        }
    }

}
//public extension FunAlamofire.Responder {
    
//    func request<T>(_ type: T.Type?, _ completion: @escaping Responder<T?>) where T: Codable {
//        
//        request { (result) in
//            if let data = result.data {
//
//                let model = try? JSONDecoder().decode(T.self, from: data)
//                completion((success: result.success, data: model, error: nil))
//                
//
//            } else {
//                completion((success: result.success, data: nil, error: nil))
//            }
//            
//            
//        }
//    }

//}
