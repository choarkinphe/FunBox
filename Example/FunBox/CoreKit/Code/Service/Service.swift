import Foundation
import FunAlamofire
//public typealias ServerKey = Service.ServerKey
public typealias ServerList = [Service.ServerKey: String]
//public typealias Result = Service.Result
//public typealias PageElement = Service.PageElement
//public typealias Empty = Service.Empty

open class Service {
    
    // 单列
    public static var manager = Static.instance
    private struct Static {
        // 读取默认的JSON配置（通配）
        static let instance = Service(config: Config.deserialize(fileName: "ServerConfig.json"))
    }
    
    private var disposeBag = DisposeBag()
    
    public init(config new_config: Service.Config?=nil) {
        // 创建公共的请求头
        self.headers = [String:String?]()
        // 首先读取项目中的默认配置
        if let config = Config.deserialize(fileName: "APPConfig.json") {
            self.config = config // 读取项目的JSON配置
        } else if let config = new_config {
            self.config = config // 读取传入的配置
        } else {
            self.config = Config() // 没有默认配置直接创建配置文件
        }
        
        
        if let config = Service.cachePool.load(CacheKey.config, type: Config.self) {
            // 如果本地有手动配置过的内容,以手动配置过的为准
            if let servers = config.servers {
                // 如果配置有新的服务，添加新的服务
                self.feedServer(servers)
            }
            // 使用之前配置好的server
            self.config.serverKey = config.serverKey
            // 因为没有单独的status和keys的配置入口，所以不存在不一致的情况
            // 不处理status和keys等的二次赋值
            
        }
        
        // 如果配置中有status的相关信息，设置好status
        if let status = config.status {
            Status.notFound = Status(rawValue: status.notFound)
            Status.success = Status(rawValue: status.success)
            Status.error = Status(rawValue: status.error)
            Status.unauthorized = Status(rawValue: status.unauthorized)
            Status.forbidden = Status(rawValue: status.forbidden)
            Status.noPermission = Status(rawValue: status.noPermission)
        }
        
        // 如果配置中有scheme就设置scheme
        if let scheme = config.scheme {
            FunCoreKit.router.scheme = scheme
        }
        
        // 读取本地缓存的token
        if let data = Service.cachePool.loadCache(key: CacheKey.token),
           let token = String(data: data, encoding: .utf8) {
            self.token = token
        }
        
        // 订阅token的变化
        token_observable.bind { [weak self] (token) in
            guard let this = self else { return }
            this.headers[this.tokenKey] = token
            
            if let string = token {
                // token会保存到执行全缓存（内存、磁盘、和UserDefaults）
                // cache可能再某些情况下被系统删除，存储到UserDefaults做一层保险
                Service.cachePool.cache(key: CacheKey.token, data: string.data(using: String.Encoding.utf8), options: [.memory,.disk,.userDefaults])
            } else {
                // token被置空的同时，需要移除缓存
                Service.cachePool.removeCache(key: CacheKey.token)
            }
            
        }.disposed(by: disposeBag)
        
        // 订阅token键值的变化
        tokenKey_observable.bind { [weak self] (tokenKey) in
            guard let this = self else { return }
            // 按照token的键值，重新设置token
            this.headers[tokenKey] = this.token
        }.disposed(by: disposeBag)
        
        // 按照配置的token键值，存储本地的token键值
        if let keys = config.keys {
            tokenKey = keys.token
        }
        
    }
    
    // 缓存路径
    private static let cachePathName = "com.coreKit.servercache"
    private struct CacheKey {
        // 缓存的键值
        static let token = "com.coreKit.appcache.token"
        static let config = "com.coreKit.appcache.config"
    }
    
    /*
     缓存池，读写本地数据
     */
    private static var cachePool: FunBox.Cache {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        // 指定缓存路径
        let cachePool = FunBox.Cache.init(path: directoryPath! + "/\(Service.cachePathName)")
        // 缓存有效期为30天
        cachePool.cacheTimeOut = 2592000
        return cachePool
    }
    
    /*
     默认使用的请求地址（baseURL）
     */
    public var server: String? {
        let serverKey = config.serverKey
        
        return config.serverList[serverKey]
        
    }
    
    /// 设置当前使用的server
    public func setServer(_ server: ServerKey) {
        config.serverKey = server
    }
    
    // 设置tosat信息
    public func setToast(_ toast: ToastOptions) {
        config.toast = toast
    }
    
    // 读取默认的服务器配置信息
    public private(set) var config: Config {
        didSet { // 配置发生变更时做缓存
            Service.cachePool.save(CacheKey.config, model: config)
        }
    }
    
    // 默认的请求头
    public var headers: [String: String?]
    
    // default method
//    public var method: Moya.Method = .post
    
    /*
     Token相关配置
     */
    
    // token键值订阅
    private lazy var tokenKey_observable = BehaviorRelay<String>(value: "tokenid")
    // token键值
    public var tokenKey: String {
        get {
            return tokenKey_observable.value
        }
        set {
            tokenKey_observable.accept(newValue)
        }
    }
    // token值的订阅
    private lazy var token_observable = BehaviorRelay<String?>(value: nil)
    // token值
    public var token: String? {
        get {
            return token_observable.value
        }
        set {
            token_observable.accept(newValue)
        }
    }
    
    // 是否登陆（依据有无token）
    public var isLogin: Bool {
        
        if let token = token, !token.isEmpty {
            return true
        }
        return false
    }
    
    
    fileprivate var observe_response: (((status: Service.Status, message: String?))->Void)?
    public func observe_response(_ handle: @escaping (((status: Service.Status, message: String?))->Void)) {
        observe_response = handle
    }
}

/*
 Service的配置信息
 */

public typealias ToastOptions = [Service.ToastOption]

extension Service {
    // Toast的可选项
    public struct ToastOption: Equatable {
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        public static let response = ToastOption(rawValue: "response")
        public static let request = ToastOption(rawValue: "request")
    }
    
    // Toast的配置
    public enum Toast: String, HandyJSONEnum {
        case none = "none"
        case message = "message"
        case error = "error"
    }
    
    /*
     配置信息
     */
    public struct Config: HandyJSON {
        public init() { }
        // 从JSON文件读取配置
        static func deserialize(fileName: String) -> Config? {
            if let JSON = JSONSerialization.fb.json(filePath: Bundle.main.path(forResource: fileName, ofType: nil), type: [String: Any].self), let config = Config.deserialize(from: JSON) {
                
                return config
            }
            return nil
        }
        
        // 服务器列表
        public var serverList = ServerList()
        fileprivate var servers: [String: String]?
        // 服务器key
        public var serverKey: ServerKey = .default {
            didSet {
                server = serverKey.rawValue
            }
        }
        // 默认的服务器
        fileprivate var server: String?
        // 是否显示response错误信息(默认只显示请求信息)
        public var toast: ToastOptions = [.request]
        // 状态码
        fileprivate var status: Status?
        // 解析字段名
        fileprivate var keys: Key?
        // scheme
        fileprivate var scheme: String?
        
        public mutating func didFinishMapping() {
            if let server = server {
                self.serverKey = ServerKey(rawValue: server)
            }
            
            if let servers = servers {
                servers.forEach { (item) in
                    if item.value.hasPrefix("http") {
                        serverList[ServerKey(rawValue: item.key)] = item.value
                    }
                }
            }
            
            
        }
        
    }
    
    // 喂一组配置(JSON)
    public func feedConfig(_ config: [String: Any]?) {
        if let JSON = config, let config = Config.deserialize(from: JSON) {
            self.config = config
        }
    }
    
    // 添加服务器配置
    public func feedServer(_ server: String, for serverKey: ServerKey) {
        feedServer([serverKey.rawValue:server])
    }
    public func feedServer(_ server: [String: String]) {
        server.forEach { (item) in
            if item.value.hasPrefix("http") {
                self.config.serverList[ServerKey(rawValue: item.key)] = item.value
                self.config.servers?[item.key] = item.value
            }
        }
    }
    
    // 服务器Key（用来读取当前使用的那个服务器，方便拓展）
    public struct ServerKey: Hashable {
        public static func == (lhs: Service.ServerKey, rhs: Service.ServerKey) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        // 默认
        public static var `default` = ServerKey(rawValue: "default")
        // 本地
        public static var local = ServerKey(rawValue: "local")
        // 自定义
        public static var custom = ServerKey(rawValue: "custom")
        
    }
}

/*
 请求的结果数据
 */
extension Service {
    /*
     服务的状态码
     （统一本地服务于接口状态码）
     */
    public struct Status: HandyJSON, Hashable, Equatable {
        public init() {self.rawValue = 0}
        
        fileprivate var notFound: Int = 404
        fileprivate var success: Int = 100
        fileprivate var error: Int = 200
        fileprivate var unauthorized: Int = 202
        fileprivate var forbidden: Int = 403
        fileprivate var noPermission: Int = 201
        
        let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        // 可以自定义状态码的真实值
        public static var notFound = Status(rawValue: 404)
        public static var success = Status(rawValue: 100)
        public static var error = Status(rawValue: 200)
        public static var unauthorized = Status(rawValue: 202)
        public static var forbidden = Status(rawValue: 403)
        public static var noPermission = Status(rawValue: 201)
        
        public static func == (lhs: Status, rhs: Status) -> Bool {
            // id相同就表示两模型相同
            return lhs.rawValue == rhs.rawValue
        }
        
    }
    
    // 请求结果对应的字符，方便自定义
    public struct Key: HandyJSON, Equatable {
        public init() {}
        
        fileprivate var success: String = "success"
        fileprivate var code: String = "code"
        fileprivate var data: String = "data"
        fileprivate var message: String = "message"
        fileprivate var totalPages: String = "totalPages"
        fileprivate var currentPage: String = "currentPage"
        fileprivate var total: String = "total"
        fileprivate var rows: String = "rows"
        fileprivate var token: String = "tokenid"
        
    }
    
    // 如果data为空，可以传入这个空Struct占位
    public struct Empty: HandyJSON {
        public init() {}
    }
    
    // 分页
    public struct PageElement<T: HandyJSON>: HandyJSON {
        public init() {}
        public var totalPages: Int = 0
        public var currentPage: Int = 0
        public var total: Int = 0
        public var rows: [T]?
        
        mutating public func mapping(mapper: HelpingMapper) {
            // 将totalPages、currentPage、total、rows解析到指定值
            if let totalPagesKey = Service.manager.config.keys?.totalPages {
                mapper.specify(property: &totalPages, name: totalPagesKey)
            }
            if let currentPageKey = Service.manager.config.keys?.currentPage {
                mapper.specify(property: &currentPage, name: currentPageKey)
            }
            if let totalKey = Service.manager.config.keys?.total {
                mapper.specify(property: &total, name: totalKey)
            }
            if let rowsKey = Service.manager.config.keys?.rows {
                mapper.specify(property: &rows, name: rowsKey)
            }
            
        }
    }
    
    
    
    /*
     统一的请求结果
     接口返回的data根据值类型不同，对象分配给object，数组分配给array，方便处理
     */
    public struct Result<T: HandyJSON>: HandyJSON {
        
        public init() {}
        public var code: Int = 0
        public var status: Status {
            return Status(rawValue: code)
        }
        public private(set) var success: Bool = false
        
        public var message: String?
        private var data: Any?
        public var object: T?
        public var array: [T]?
        // 配置信息
        var option: FunResponse.Option?
        
        mutating public func mapping(mapper: HelpingMapper) {
            // 将code、data、message解析到指定值
            if let successKey = Service.manager.config.keys?.success {
                mapper.specify(property: &success, name: successKey)
            }
            if let codeKey = Service.manager.config.keys?.code {
                mapper.specify(property: &code, name: codeKey)
            }
            if let messageKey = Service.manager.config.keys?.message {
                mapper.specify(property: &message, name: messageKey)
            }
            if let dataKey = Service.manager.config.keys?.data {
                mapper.specify(property: &array, name: dataKey)
                mapper.specify(property: &object, name: dataKey)
            } else {
                mapper.specify(property: &array, name: "data")
                mapper.specify(property: &object, name: "data")
            }
            
            
            
        }
        
        mutating public func didFinishMapping() {
            
            if !success {
                // 请求报错，处理异常
                if let message = message {
                    debugPrint(message)
                }
                
                // Token过期，跳转到登陆页
                if status == .unauthorized {
                    
                }
            }
            
            Service.manager.observe_response?((status,message))
            
            if !success {
                success = (status == .success)
            }
            
            if Service.manager.config.toast.contains(.request) {
                // 全局开关关闭的话，不考略弹窗
                // 如果开启了请求的错误弹窗
                if option?.toast == .message {
                    FunHUD.toast(.info, message: message)
                } else if option?.toast == .error, !success {
                    FunHUD.toast(.info, message: message)
                }
            }
        }
        
    }
}

// MARK: - Extensions

// RxSwift + CK
extension ObservableType {
    
    public func response(onNext: ((Element) -> Void)? = nil) -> RxSwift.Disposable {
        return response(onSuccess: onNext, onError: nil)
    }
    public func response(onSuccess: ((Element) -> Void)? = nil, onError: ((Error)->Void)?=nil) -> RxSwift.Disposable {
        
        return subscribe { (event) in
            switch event {
            case let .next(element):
                onSuccess?(element)
            case .error(let error):
                
                debugPrint(error.localizedDescription)
                if let onError = onError {
                    onError(error)
                } else if Service.manager.config.toast.contains(.response) {
                    // toast配置中包含有错误提醒
                    FunHUD.toast(.error, message: error.localizedDescription)
                }
                
                
            case .completed:
                break
                
            }
        }
    }
}

//extension Response {
//    // 请求响应配置
//    struct Option: HandyJSON {
//        // toast配置，默认只给错误弹窗
//        var toast: Service.Toast = .error
//        // display view
//        var container: UIView?
//        // 响应器
//        var sender: UIView?
//        // 缓存有效期
//        var cache_timeOut: TimeInterval?
//        
//    }
//}


/*
 FunCache + HandyJSON
 */
extension FunCache {
    // 缓存
    public func load<T>(_ identifier: String, type: T.Type) -> T? where T: HandyJSON {
        guard let data = loadCache(key: identifier), let json = String(data: data, encoding: .utf8) else {
            
            debugPrint("FunCache: no cache")
            return nil
        }
        
        guard let object = T.deserialize(from: json) else {
            debugPrint("FunCache: load type error")
            
            return nil
        }
        
        return object
    }
    
    // 读取缓存
    public func save(_ identifier: String, model: HandyJSON?) {
        guard let data = model?.toJSONString()?.data(using: .utf8) else {
            debugPrint("FunCache: cache model exception")
            return
        }
        cache(key: identifier, data: data)
    }
    
}

// MARK: - Router
typealias Router = FunBox.Router
extension Service: FunRouterDelegate {
    
    // APP启动参数
    typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]
    
    @objc static var router: Router {
        let router = Router.default
        router.delegate = Service.manager
        router.scheme = "funbox"
        return router
    }
    
    public func routerWillOpen(viewController: UIViewController, options: FunRouterOptions?) {
        // 这里可以获取到所有即将通过路由打开的页面
        
        
    }
//    构造需要跳转的VC，实现了就会走这里
    public func routerWillBuild(options: FunRouterOptions?) -> UIViewController? {
        if options?.url?.pathExtension == "message/list" {
            return UIStoryboard.init(name: "xx", bundle: .main).instantiateInitialViewController()
        }
        return nil
    }
    
}


extension Router.Page {
    static var message: Router.Page = Router.Page(rawValue: "message/list")
}

// APP启动数据协议
public protocol APPLaunchable {
    var url: URL? { get }
}

@available(iOS 13.0, *)
extension UIScene.ConnectionOptions: APPLaunchable {
    public var url: URL? {
        return urlContexts.first?.url
    }

}


extension Service.LaunchOptions: APPLaunchable {
    public var url: URL? {
        return self[.url] as? URL
    }

}
