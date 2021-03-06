//
//  FunAlamofire+Task.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/25.
//


import Alamofire
import FunBox
import UIKit

extension FunAlamofire {
    public class Task {
        // 管理session
        let session: Session
        
//        public enum `Type`: String {
//            case `default` = "default"
//            case download = "download"
//            case upload = "upload"
//        }
        // 请求地址
        var path: String?
        fileprivate var url_request: URLRequest?
        init(session: Session, path: String?=nil, request: URLRequest?=nil) {
            self.session = session
            if let request = request {
                self.url_request = request
                self.baseURL = request.baseURL
                self.path = request.path
                self.method = request.method ?? .post
                self.headers = request.headers
                self.params = request.params
            } else {
                self.path = path
            }
        }
        // 请求类型
//        var type: Type = .default
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
        // body体
//        public var formDataHandler: ((MultipartFormData)->Void)?
        
        // 请求配置
        public var options: [FunAlamofire.Option] = [.toast(FunAlamofire.manager.toast)]
        
        // 任务进度
        fileprivate var up_progress: ((Progress) -> Void)?
        fileprivate var down_progress: ((Progress) -> Void)?
        
        // 请求的真实地址
        fileprivate var url: URL? {
            if let path = path {
                var url = URL(string: path)
                
                if !path.hasPrefix("http"), let baseURL = try? baseURL?.asURL() {
                    url = baseURL.appendingPathComponent(path)
                }
                
                return url
            }
            return nil
        }
        
        // 真实请求
        fileprivate var request: Request? {
            guard let url = url else { return nil }
            if let url_request = url_request {
                
                return session.request(url_request)
            } else {
                return session.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
            }
//            switch type {
//
//                case .default: // 创建普通请求
//
//
//                case .download: // 创建下载请求
//                    return session.download(url, method: method, parameters: params, encoding: encoding, headers: headers, to: destination)
//
//                case .upload: // 创建上传请求
//
//                    return session.upload(multipartFormData: formData, to: url, method: method, headers: headers)
//
//            }
            
        }
        
        open func response(_ completion: ((FunResponse)-> Void)?) {
            guard let request = request else { return }
            // 生成响应选项
            let option = FunResponse.Option.deserialize(options: options)
            
            // 请求开启关闭响应者事件
            option.sender?.isUserInteractionEnabled = false
            // 开启缓存时，优先读取缓存的内容
            /*
             if element.isCache, let data = manager?.load_request(element: element) {
             
             if let result = completion {
             
             var response = FunAlamofire.RequestResponse(request: request.request, response: request.response, fileURL: nil, resumeData: nil)
             response.data = data
             result(response)
             }
             
             element.sender?.isEnabled = true
             // 拿到对应的缓存后直接回调，执行真正的请求
             return
             }
             */
            
            
            
            // 普通任务（包含上传）
            if let dataRequest = request as? DataRequest {
                
                if let progress = up_progress {
                    dataRequest.uploadProgress(closure: progress)
                }
                if let progress = down_progress {
                    dataRequest.downloadProgress(closure: progress)
                }
                // 开启请求任务
                dataRequest.responseData { (data_response) in
                    
                    let response = FunResponse(request: request.request, response: request.response)
                    
                    // 处理结果
                    switch data_response.result {
                        case .success(_):
                            
                            if let data = data_response.data {
                                response.data = data
                                // 开启了缓存,保存请求信息
                                //                                if element.isCache == true {
                                //
                                //                                    self?.manager?.cache_request(element: element, response: data)
                                //                                }
                            } else {
                                response.error = FunError(description: "responseData is empty")
                            }
                            
                        case .failure(let error):
                            
                            response.error = error
                            
                            // 默认的错误HUD
                            if option.toast != .none {
                                FunBox.toast.message(error.localizedDescription).show()
                            }
                            
                    }
                    completion?(response)
                    
                    // 请求完成时打开sender事件
                    option.sender?.isUserInteractionEnabled = true
                }
                
            }
            
            

            
        }
        
        deinit {
            debugPrint("FunAlamofire.Task die")
        }
        
    }
    
    public class DownLoadTask: FunAlamofire.Task {
        // 储存路径
        public var destinationURL: URL?
        fileprivate var destination = DownloadRequest.suggestedDownloadDestination(
            for: .cachesDirectory,
            in: .userDomainMask,
            options: .removePreviousFile
        )
        override var request: Request? {
            guard let url = url else { return nil }
            return session.download(url, method: method, parameters: params, encoding: encoding, headers: headers, to: destination)
        }
        
        // 下载任务
        public override func response(_ completion: ((FunDownloadResponse) -> Void)?) {
            guard let request = request else { return }
            // 生成响应选项
            let option = FunResponse.Option.deserialize(options: options)
            
            // 请求开启关闭响应者事件
            option.sender?.isUserInteractionEnabled = false
            
            if let downloadRequest = request as? DownloadRequest {
                if let progress = up_progress {
                    downloadRequest.uploadProgress(closure: progress)
                }
                if let progress = down_progress {
                    downloadRequest.downloadProgress(closure: progress)
                }
                downloadRequest.responseData { (download_response) in
                    
                    let response = FunDownloadResponse(request: request.request, response: request.response, fileURL: download_response.fileURL)
                    
                    // 内部回调
                    switch download_response.result {
                        case .success(_):
                            response.data = download_response.fileURL?.dataRepresentation
                            
                        case .failure(let error):
                            
                            response.error = error
                            
                            // 默认的错误HUD
                            if option.toast != .none {
                                FunBox.toast.message(error.localizedDescription).show()
                            }
                    }
                    
                    completion?(response)
                    
                    // 请求完成时打开sender事件
                    option.sender?.isUserInteractionEnabled = true
                }
                
            }
        }
    }
    public class UpLoadTask: FunAlamofire.Task {
        override var request: Request? {
            guard let url = url else { return nil }
            let formData = MultipartFormData(fileManager: FileManager.default)
            
//            if let formDataHandler = formDataHandler {
//                formDataHandler(formData)
//            }
            return session.upload(multipartFormData: formData, to: url, method: method, headers: headers)
        }
    }
}

// Task的链式构建方法
public extension FunAlamofire.Task {
    func path(_ path: String) -> Self {
        self.path = path
        return self
    }
//    func taskType(_ type: Type) -> Self {
//        self.type = type
//        return self
//    }
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
//    func body(_ body: ((MultipartFormData) -> Void)?) -> Self {
//        self.formDataHandler = body
//        return self
//    }

    
    func options(_ options: [FunAlamofire.Option]) -> Self {
        self.options = options
        
        return self
    }
    
    func progress(upload handler: @escaping ((Progress) -> Void)) -> Self {
        up_progress = handler
        return self
    }
    func progress(download handler: @escaping ((Progress) -> Void)) -> Self {
        down_progress = handler
        return self
    }
}

public extension FunAlamofire.DownLoadTask {
    func destinationURL(_ destinationURL: URL?) -> Self {
        self.destinationURL = destinationURL
        self.destination = { temporaryURL, response in
            
            let url = destinationURL?.appendingPathComponent(response.suggestedFilename!) ?? temporaryURL
            
            return (url, .removePreviousFile)
        }
        return self
    }
}

// MARK: - Task->Response
//public extension FunAlamofire.Task {
//
//
//
//}
//
//public extension FunAlamofire.DownLoadTask {
//
//}

// MARK: - RequestOption
extension FunAlamofire {
    
    // Toast的配置
    public enum Toast: String {
        case none = "none"
        case message = "message"
        case error = "error"
    }
    
    public struct Option: Equatable {
        public static func == (lhs: FunAlamofire.Option, rhs: FunAlamofire.Option) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        var paramter: Any?
        private let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        // 使用缓存
        static let cache = Option(rawValue: "cache")
        public static func cache(timeOut: TimeInterval = 15) -> Option {
            var option = Option(rawValue: "cache")
            option.paramter = timeOut
            return option
        }
        
        // 绑定触发器
        static let sender = Option(rawValue: "sender")
        public static func sender(_ sender: UIView?) -> Option {
            var option = Option(rawValue: "sender")
            option.paramter = sender
            return option
        }
        
        // toast信息
        static let toast = Option(rawValue: "toast")
        public static func toast(_ toast: Toast) -> Option {
            var option = Option(rawValue: "toast")
            option.paramter = toast
            return option
        }
        
        // display view
        static let container = Option(rawValue: "container")
        public static func container(_ container: UIView?) -> Option {
            var option = Option(rawValue: "container")
            option.paramter = container
            return option
        }
        
    }
}
