//
//  FunAlamofire+Response.swift
//  FunAlamofire
//
//  Created by 肖华 on 2019/9/14.
//

import Foundation
import Alamofire
#if !COCOAPODS
import FunBox
#endif
import UIKit
// 最终发出请求响应
public typealias FunResponse = FunAlamofire.Response
//public typealias FunRequest = FunAlamofire.Request
public typealias FunDownloadResponse = FunAlamofire.DownloadResponse
/*
public class FunRequest: Equatable,FunRequestable {
    public var path: String
//    public enum `Type` {
//        case normal
//        case download
//        case upload
//    }
//    var type: FunRequest.Type = .normal
    // 请求地址
//    public var path: String?
    // method
    public var method: HTTPMethod = .post
    // 请求参数
    public var params: [String: Any]?
    // baseURL
    public var baseURL: URLConvertible? = FunAlamofire.manager.baseURL
    // 请求头
    public var headers: HTTPHeaders? = FunAlamofire.manager.headers
    // encoding
    public var encoding: ParameterEncoding = URLEncoding.default
    
    var url_request: URLRequest?
    init(path: String?=nil, request: FunRequestable?=nil) {
        if let request = request as? URLRequest {
            self.url_request = request
        }
        self.baseURL = request?.baseURL
        self.path = request?.path ?? "error path"
        self.method = request?.method ?? .post
        self.headers = request?.headers
        self.params = request?.params

    }
    
//    func asFunRequest() -> FunRequest? {
//        
//    }
    
    public static func == (lhs: FunRequest, rhs: FunRequest) -> Bool {
//            return lhs.statusCode == rhs.statusCode
//                && lhs.data == rhs.data
//                && lhs.response == rhs.response
        return true
    }
    
    // 请求的真实地址
    var url: URL? {
        
        var url = URL(string: path)
        
        if !path.hasPrefix("http"), let baseURL = try? baseURL?.asURL() {
            url = baseURL.appendingPathComponent(path)
        }
        
        return url
        
        
    }
    
}

//class FunDownloadRequest: FunRequest {
//
//}

public extension FunRequest {
    func path(_ path: String) -> Self {
        self.path = path
        return self
    }
    func method(_ method: HTTPMethod) -> Self {
        self.method = method
        return self
    }
    func params(_ params: [String: Any]?) -> Self {
        self.params = params
        return self
    }
    func baseURL(_ baseURL: URLConvertible) -> Self {
        self.baseURL = baseURL
        return self
    }
    func headers(_ headers: HTTPHeaders?) -> Self {
        self.headers = headers
        return self
    }
    func encoding(_ encoding: ParameterEncoding) -> Self {
        self.encoding = encoding
        return self
    }
}
 */
public extension FunAlamofire {

    
    class Response: Equatable {
        /// The status code of the response.
        public let statusCode: Int
        // 上传&下载进度
        public var progress: Progress?

        // 真实的下载请求
        public var request: FunRequestable?
        
        /// The server's response to the URL request.
        public var response: HTTPURLResponse?
        
        // 请求结果
        public var data: Data?
        // 错误信息
        public var error: Error?
        // 回调
        var callBack: ((FunResponse)-> Void)?
        
        public init(statusCode: Int = 200, data: Data? = nil, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
            self.statusCode = statusCode
            self.data = data
            self.request = request
            self.response = response
        }

        /// A text description of the `Response`.
        public var description: String {
            return "Status Code: \(statusCode), Data Length: \(data?.count ?? 0)"
        }

        /// A text description of the `Response`. Suitable for debugging.
        public var debugDescription: String {
            return description
        }

        public static func == (lhs: Response, rhs: Response) -> Bool {
            return lhs.statusCode == rhs.statusCode
                && lhs.data == rhs.data
                && lhs.response == rhs.response
        }

    }
    
    class DownloadResponse: Response {
        // 下载恢复文件
        public let resumeData: Data?
        // 下载任务的地址
        public let fileURL: URL?
        
        public init(request: URLRequest?,
                    response: HTTPURLResponse?,
                    fileURL: URL?=nil,
                    resumeData: Data?=nil) {
            self.fileURL = fileURL
            self.resumeData = resumeData
//            super.init(request: request, response: response)
            super.init(statusCode: 200, data: nil, request: request, response: response)
            
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
