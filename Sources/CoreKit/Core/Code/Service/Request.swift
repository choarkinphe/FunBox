//
//  Request.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/3.
//

import Foundation
@_exported import HandyJSON
@_exported import RxSwift
@_exported import Moya


public struct API {
    public typealias Paramter = [String: Any]
    public typealias Provider = MoyaProvider
    private static let cachePathName = "com.corekit.core.requestcache"

    // 方便创建请求实例
    public static func provider<T>(_ type: T.Type) -> Provider<T> where T: TargetType {
        return Provider<T>()
    }
    
    fileprivate static var cachePool: FunBox.Cache {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        // 指定缓存路径
        let cachePool = FunBox.Cache(path: directoryPath! + "/\(API.cachePathName)")
        
        return cachePool
    }
}

extension String: HandyJSON {}

extension API.Paramter: APIPageParamterable {

    public var index: Int {
        get {
            return (self["index"] as? Int) ?? 1
        }
        set {
            self["index"] = newValue
        }
    }

}
// MARK: - API.公共配置
// 分页请求数据协议
public protocol APIPageParamterable: APIParamterable {
    var size: Int { get }
    var index: Int { get set }
}

extension APIPageParamterable {
    public var size: Int {
        
        return 20
    }
}

// 请求数据的标准协议
public protocol APIParamterable {
    
    func asParams() -> API.Paramter
}

extension APIParamterable {
    public func asParams() -> API.Paramter {
        
        if let map = (self as? HandyJSON)?.toJSON() {
            
            return map
        }
        
        return API.Paramter()
    }
}

extension API.Paramter: APIParamterable {
    
    public func asParams() -> API.Paramter {
        return self
    }
}

// 默认的公共请求配置
extension TargetType {
    // default serverURL
    public var baseURL: URL {
        if let urlString = Service.manager.server {
            return URL(string: urlString)!
        }
        return URL(string: "")!
    }
    
    // default method
    public var method: Moya.Method {
        return Service.manager.method
    }
    
    //Alamofire validate
    public var validate: Bool {
        return false
    }
    
    // testinfo
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    

    
    // default headers
    public var headers: [String: String]? {
        var headers = ["Content-Type":"application/json;charset=UTF-8"]
        if method == .get || method == .delete {
            headers = ["Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"]
        }
        
        Service.manager.headers.forEach { (item) in
            headers[item.key] = item.value
        }

        return headers
    }
    

}

// 二级协议（项目中使用该协议，省去配置Task的麻烦）
public protocol APITargetType: TargetType {
    var params: API.Paramter? { get }
}

extension APITargetType {
    public var params: API.Paramter? { return nil }
    public var task: Task {
        
        if let params = params {
            if method == .get {
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            } else if method == .post {
                return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            }
        }
        return .requestPlain
    }
}

// MARK: - Moya+HandyJSON
extension Reactive where Base: MoyaProviderType {
    
    /// 请求实体生成器
    /// - Parameters:
    ///   - token: 请求来源
    ///   - options: 请求配置
    ///   - callbackQueue: 回调线程
    ///   - progress: 进度
    /// - Returns: 返回Observable实体
    public func request(to token: Base.Target, options: RequestOptions = [], callbackQueue: DispatchQueue? = nil, progress: ProgressBlock?=nil) -> Observable<Response> {
        
        let option = Response.Option.deserialize(options: options)
        if option.cache_timeOut != nil, let response = load(from: token) {
            return Single.create { single in
                single(SingleEvent<Response>.success(response))
                return Disposables.create {
                    // 请求释放后开启sender的响应
                    option.sender?.isUserInteractionEnabled = true
//                    cancellableToken?.cancel()
                }
            }.asObservable()
        }
        // 关闭sender的响应
        option.sender?.isUserInteractionEnabled = false
        return Single.create { [weak base] single in
            let cancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case let .success(response):
                    // 暂存option的信息
                    response.option = option
                    single(.success(response))
                    if let timeOut = option.cache_timeOut {
                        self.cache(to: token, timeOut: timeOut, response: response)
                    }
                    
                case let .failure(error):
                    single(.error(error))
                    if Service.manager.config.toast.contains(.request), option.toast != .none {
                        // 未关闭弹窗的话，就显示toast
                        FunBox.toast.message(error.localizedDescription).inView(UIApplication.shared.fb.currentWindow).position(.center).image(UIImage(named: "Toast_tips_error", in: CoreKit.bundle, compatibleWith: nil)).show()
                    }
                    if let container = option.container {
                        container.holder.show(.notFound)
                    }
                }
                // 请求完成后重新开启sender的响应
                option.sender?.isUserInteractionEnabled = true
            }

            return Disposables.create {
                // 请求释放后开启sender的响应
                option.sender?.isUserInteractionEnabled = true
                cancellableToken?.cancel()
            }
        }.asObservable()
        
    }
    
    func cache(to token: Base.Target, timeOut: TimeInterval, response: Response) {
        API.cachePool.cache(key: token.cacheKey, data: response.data, options: [.memory, .timeOut(timeOut)])
    }
    
    func load(from token: Base.Target) -> Response? {
        if let data = API.cachePool.loadCache(key: token.cacheKey) {
            return Response(statusCode: 200, data: data, request: nil, response: nil)
        }
        return nil
    }
}

extension TargetType {

    fileprivate var cacheKey: String {
        return (baseURL.absoluteString + path).fb.md5
    }
}

extension ObservableType where Element == Response {
    public func mapObject<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(T.self))
        }
    }
    
    public func mapResult<T: HandyJSON>(_ type: T.Type) -> Observable<CKResult<T>> {
        return flatMap { response -> Observable<CKResult<T>> in
            return Observable.just(try response.mapResult(type))
        }
    }
}



private var optionsKey = "com.corekit.response.options"
extension Response {
    
    fileprivate var option: Response.Option? {
        get {
            return objc_getAssociatedObject(self, &optionsKey) as? Response.Option
        }
        set {
            objc_setAssociatedObject(self, &optionsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func mapObject<T: HandyJSON>(_ type: T.Type) throws -> T {
        
        guard let object = JSONDeserializer<T>.deserializeFrom(json: try mapString()) else {
            throw MoyaError.jsonMapping(self)
        }
        return object
    }
    
    public func mapResult<T: HandyJSON>(_ type: T.Type) throws -> CKResult<T> {
        
        guard let JSON = try mapJSON() as? [String: Any] else {
            throw MoyaError.jsonMapping(self)
        }
        
//        JSON["option"] = option?.toJSON()
        
        guard var object = CKResult<T>.deserialize(from: JSON) else {
            throw MoyaError.jsonMapping(self)
        }
        
        object.option = option
        
        if let container = option?.container {
            if let holder = object.status as? HolderType {
                container.holder.show(holder.holderType)
            } else {
                container.holder.show(object.holderType)
            }
        }
        
        return object
    }
}

// MARK: - RequestOptions

public typealias RequestOptions = [API.Option]

extension API {

    public struct Option: Equatable {
        public static func == (lhs: API.Option, rhs: API.Option) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        var paramter: Any?
        private let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        // 使用缓存
        fileprivate static let cache = Option(rawValue: "cache")
        public static func cache(timeOut: TimeInterval = 15) -> Option {
            var option = Option(rawValue: "cache")
            option.paramter = timeOut
            return option
        }
        
        // 绑定触发器
        fileprivate static let sender = Option(rawValue: "sender")
        public static func sender(_ sender: UIView?) -> Option {
            var option = Option(rawValue: "sender")
            option.paramter = sender
            return option
        }
        
        // toast信息
        fileprivate static let toast = Option(rawValue: "toast")
        public static func toast(_ toast: Service.Toast) -> Option {
            var option = Option(rawValue: "toast")
            option.paramter = toast
            return option
        }
        
        // display view
        fileprivate static let container = Option(rawValue: "container")
        public static func container(_ container: UIView?) -> Option {
            var option = Option(rawValue: "container")
            option.paramter = container
            return option
        }

    }
}

extension Response.Option {
    static func deserialize(options: RequestOptions) -> Response.Option {
        // 生成一组option
        var option = Response.Option()
        
        options.forEach { (item) in
            // 找到响应器就先缓存
            if item == .sender {
                option.sender = item.paramter as? UIView
            }
            // 配置option的toast信息
            if item == .toast, let paramter = item.paramter as? Service.Toast {
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
