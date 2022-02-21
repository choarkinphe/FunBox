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
import FunAlamofire
public struct API {
    public typealias Paramter = [String: Any]
    public typealias Provider = MoyaProvider
    // 缓存路径
    private static let cachePathName = "com.corekit.requestcache"

    // 方便创建请求实例
    public static func provider<T>(_ type: T.Type) -> MoyaProvider<T> where T: TargetType {
        return MoyaProvider<T>()
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
                        FunBox.toast.message(error.localizedDescription).inView(UIApplication.shared.fb.currentWindow).position(.center).image(UIImage(named: "Toast_tips_error", in: FunCoreKit.bundle, compatibleWith: nil)).show()
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
    
    public func mapResult<T: HandyJSON>(_ type: T.Type) -> Observable<Service.Result<T>> {
        return flatMap { response -> Observable<Service.Result<T>> in
            return Observable.just(try response.mapResult(type))
        }
    }
}

public class FunObservable<Element> : FunObservableType {
    init() {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
    }
    
//    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
//        rxAbstractMethod()
//    }
    
    public func asObservable() -> FunObservable<Element> {
        return self
    }
    
    deinit {
#if TRACE_RESOURCES
        _ = Resources.decrementTotal()
#endif
    }
}

public protocol FunObservableType {
    /// Type of elements in sequence.
    associatedtype Element

    @available(*, deprecated, renamed: "Element")
    typealias E = Element

    /// Converts `self` to `Observable` sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    func asObservable() -> FunObservable<Element>
}

//extension FunAlamofire {
//    struct ObservableType<T> {
//
//    }
//}
//public extension FunAlamofire.Task {
//
//    func mapObject<T: HandyJSON>(_ type: T.Type, completion: ((T)-> Void)?) -> FunAlamofire.Task {
//        return mapJSON { json in
//            
//            if let json = json as? [String: Any], let obj = T.deserialize(from: json, designatedPath: nil) {
//            
//                completion?(obj)
//            }
//        }
//    }
//}

extension FunAlamofire.Task {
//    public typealias Element =
    
    func a() {
//        response { response in
//            
//        }
    }
//    public func mapObject<T: HandyJSON>(_ type: T.Type) -> FunAlamofire.Task {
//        return flatMap { response -> Observable<T> in
//            return Observable.just(try response.mapObject(T.self))
//        }
//    }
//    public typealias Element = <#type#>
    
//    public func mapObject<T: HandyJSON>(_ type: T.Type) -> FunAlamofire.Task<T> {
//
//        return
//    }
}
//extension ObservableType where Element == Response {
//    public func mapObject<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
//        return flatMap { response -> Observable<T> in
//            return Observable.just(try response.mapObject(T.self))
//        }
//    }
//
//    public func mapResult<T: HandyJSON>(_ type: T.Type) -> Observable<Service.Result<T>> {
//        return flatMap { response -> Observable<Service.Result<T>> in
//            return Observable.just(try response.mapResult(type))
//        }
//    }
//}

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
    
    public func mapResult<T: HandyJSON>(_ type: T.Type) throws -> Service.Result<T> {
        
        guard let JSON = try mapJSON() as? [String: Any] else {
            throw MoyaError.jsonMapping(self)
        }
        
//        JSON["option"] = option?.toJSON()
        
        guard var object = Service.Result<T>.deserialize(from: JSON) else {
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


//public extension URL {
//
//    /// Initialize URL from Moya's `TargetType`.
//    init<T: TargetType>(target: T) {
//        // When a TargetType's path is empty, URL.appendingPathComponent may introduce trailing /, which may not be wanted in some cases
//        // See: https://github.com/Moya/Moya/pull/1053
//        // And: https://github.com/Moya/Moya/issues/1049
//        let targetPath = target.path
//        if targetPath.isEmpty {
//            self = target.baseURL
//        } else {
//         //   self = target.baseURL.appendingPathComponent(targetPath)
//          //修改如下，如果有更好的方法，欢迎补充
//            let urlWithPath = target.baseURL.absoluteString + targetPath
//            self = URL(string: urlWithPath) ?? target.baseURL
//        }
//    }
//}
