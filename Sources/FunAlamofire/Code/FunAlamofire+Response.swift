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
public typealias FunDownloadResponse = FunAlamofire.DownloadResponse

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
        // 请求的选项
        var option: Option?
        
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
        public var fileURL: URL?
        
        public init(request: URLRequest?,
                    response: HTTPURLResponse?,
                    fileURL: URL?=nil,
                    resumeData: Data?=nil) {
            self.fileURL = fileURL
            self.resumeData = resumeData
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
        // 缓存有效期
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
