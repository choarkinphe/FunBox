//
//  FunAlamofire+Task.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/25.
//


import Alamofire
import FunBox
import UIKit
public protocol FunTaskType {
    func resume(wait: TimeInterval)
}
extension FunAlamofire {
    // MARK: - 请求任务
    public class Task: FunTaskType {
        
        public enum State: String, Codable {
            case wait = "wait"              // 等待
            case cancel = "cancel"          // 取消
            case finish = "finish"          // 已完成
            case failed = "failed"          // 失败
        }
        
        // 任务状态
        var state: State = .wait
        
        // 管理session
        let session: Session
        
        // 请求结果
        public var response: FunResponse?
        
        fileprivate var url_request: URLRequest?
        
        init(session: Session, path: String?=nil, request: FunRequestable?=nil) {
            self.session = session
            if let request = request as? URLRequest {
                self.url_request = request
            }
            self.baseURL = request?.baseURL
            self.path = request?.path
            self.method = request?.method ?? .post
            self.headers = request?.headers
            self.params = request?.params
            
        }
        
        // 请求地址
        var path: String?
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
        public var formDataHandler: ((MultipartFormData)->Void)?
        
        // 请求配置
        fileprivate var options: [FunAlamofire.Option] = [.toast(FunAlamofire.manager.toast)]
        
        //        private var option: FunResponse.Option?
        
        // 任务进度
        fileprivate var up_progress: ((Progress) -> Void)?
        fileprivate var down_progress: ((Progress) -> Void)?
        //        fileprivate var response_completion: ((FunResponse)-> Void)?
        
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
        
        //真实请求
        fileprivate var request: Request? {
            guard let url = url else { return nil }
            if let url_request = url_request {
                
                return session.request(url_request)
            } else {
                return session.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
            }
        }
        
        // 缓存键值
        var cacheKey: String {
            var url = path ?? ""
            if let baseURL = try? baseURL?.asURL().absoluteString {
                url = baseURL + url
            }
            return url.fb.md5
        }
        
        public func response(_ completion: ((FunResponse)-> Void)?=nil) -> Task {
            
            // 普通任务（包含上传）
            if let dataRequest = request as? DataRequest {
                
                if let progress = up_progress {
                    dataRequest.uploadProgress(closure: progress)
                }
                if let progress = down_progress {
                    dataRequest.downloadProgress(closure: progress)
                }
                
                let option = FunResponse.Option.deserialize(options: options)
                
                option.sender?.isUserInteractionEnabled = true
                
                if option.cache_timeOut != nil, let response = FunAlamofire.default.load(from: self) {
                    // 直接返回结果
                    completion?(response)
                    debugPrint("FunAlamofire: Task-\(url?.absoluteString ?? "null") load cache")
                    // 请求完成时打开sender事件
                    option.sender?.isUserInteractionEnabled = true
                    
                    // 将任务标记为取消
                    state = .cancel
                    
                    debugPrint("FunAlamofire: Task-\(url?.absoluteString ?? "null") cancel")
                } else {
                    // 未找到缓存数据，转移回调，不做处理
                    if self is FunAlamofire.DownLoadTask {
                        self.response = FunDownloadResponse(request: request?.request, response: request?.response)
                    } else {
                        self.response = FunResponse(request: request?.request, response: request?.response)
                    }
                    
                    response?.callBack = completion
                    
                    response?.option = option
                    
                    debugPrint("FunAlamofire: Task-\(url?.absoluteString ?? "null") new request")
                }
                
            }
            
            return self
            
        }
        
        // 开启请求任务
        open func resume(wait: TimeInterval = 0) {
            
            if state != .wait { // 非等待状态的任务不执行
                return
            }
            
            guard let dataRequest = request as? DataRequest, let response = response else {
                self.response = nil
                return
            }
            
            // 请求开启关闭响应者事件
            response.option?.sender?.isUserInteractionEnabled = false
            
            // 开启请求任务
            
            dataRequest.responseData { [weak self] (data_response) in
                
                // 处理结果
                switch data_response.result {
                    
                case .success(_):
                    
                    if let data = data_response.data {
                        response.data = data
                        // 开启了缓存,保存请求信息
                        if let timeOut = response.option?.cache_timeOut, let this = self {
                            FunAlamofire.default.cache(to: this, timeOut: timeOut, response: response)
                            debugPrint("FunAlamofire: Task-\(self?.url?.absoluteString ?? "null") is cached")
                        }
                    } else {
                        response.error = FunError(description: "responseData is empty")
                    }
                    // 任务标记为已完成
                    self?.state = .finish
                    // 请求完成
                    debugPrint("FunAlamofire: Task-\(self?.url?.absoluteString ?? "null") is finished")
                    
                case .failure(let error):
                    
                    response.error = error
                    
                    // 默认的错误HUD
                    if response.option?.toast != FunAlamofire.Toast.none {
                        FunBox.toast.message(error.localizedDescription).show()
                    }
                    
                    // 任务标记为已完成
                    self?.state = .failed
                    // 请求完成
                    debugPrint("FunAlamofire: Task-\(self?.url?.absoluteString ?? "null") is failed")
                    
                }
                
                response.callBack?(response)
                
                // 请求完成时打开sender事件
                response.option?.sender?.isUserInteractionEnabled = true
                
                // 手动销毁response
                self?.response = nil
            }
            
        }
        
        deinit {
            debugPrint("FunAlamofire: Task-\(url?.absoluteString ?? "null") is destroyed")
        }
        
    }
    
    // MARK: - 下载任务
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
        public override func resume(wait: TimeInterval = 0) {
            
            if state != .wait { // 非等待状态的任务不执行
                return
            }
            
            guard let downloadRequest = request as? DownloadRequest, let response = response as? FunDownloadResponse else {
                self.response = nil
                return
            }
            
            downloadRequest.responseData { [weak self] (download_response) in
                
//                let response = FunDownloadResponse(request: request.request, response: request.response, fileURL: download_response.fileURL)
                
                // 内部回调
                switch download_response.result {
                case .success(_):
                    response.data = download_response.fileURL?.dataRepresentation
                    response.fileURL = download_response.fileURL
                    // 开启了缓存,保存请求信息
                    if let timeOut = response.option?.cache_timeOut, let this = self {
                        FunAlamofire.default.cache(to: this, timeOut: timeOut, response: response)
                    }
                    // 任务标记为已完成
                    self?.state = .finish
                    // 请求完成
                    debugPrint("FunAlamofire: Task-\(self?.url?.absoluteString ?? "null") is finished")
                    
                case .failure(let error):
                    
                    response.error = error
                    
                    // 默认的错误HUD
                    if response.option?.toast != FunAlamofire.Toast.none {
                        FunBox.toast.message(error.localizedDescription).show()
                    }
                    
                    // 任务标记为已完成
                    self?.state = .failed
                    // 请求完成
                    debugPrint("FunAlamofire: Task-\(self?.url?.absoluteString ?? "null") is failed")
                }
                
                //                    self?.response_completion?(response)
                response.callBack?(response)
                // 请求完成时打开sender事件
                response.option?.sender?.isUserInteractionEnabled = true
                
                // 手动销毁response
                self?.response = nil
            }
            
            
        }
    }
    
    // MARK: - 上传任务
    public class UpLoadTask: FunAlamofire.Task {
        override var request: Request? {
            guard let url = url else { return nil }
            let formData = MultipartFormData(fileManager: FileManager.default)
            
            if let formDataHandler = formDataHandler {
                formDataHandler(formData)
            }
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
    func body(_ body: ((MultipartFormData) -> Void)?) -> Self {
        self.formDataHandler = body
        return self
    }
    
    
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

// MARK: - Task->Map
public extension FunAlamofire.Task {
    
    func mapJSON(_ completion: ((Any)-> Void)?) -> FunAlamofire.Task {
        
        return response { response in
            // 调用通用完整response方法获取请求结果
            if let data = response.data { // 判断data是否有值
                do {
                    // 解析json
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    // 判断解析出来的是否为json对象
                    if JSONSerialization.isValidJSONObject(json) {
                        // 抛出解析结果
                        completion?(json)
                    } else {
                        debugPrint("FunAlamofire: Task-\(self.url?.absoluteString ?? "null") isValidJSONObject fail")
                    }
                }
                
                catch{
                    debugPrint("FunAlamofire: \(error.localizedDescription)")
                }
                
            } else {
                debugPrint("FunAlamofire: Task-\(self.url?.absoluteString ?? "null") response data is empty")
            }
        }
    }
}

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
