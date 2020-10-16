//
//  FunRouter.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/11.
//

import UIKit

public typealias FunRouter = FunBox.Router

/*
    关于二级路由
 
    创建任意一个类，遵守FunRouterable协议
    
    例：
    class JSRouter: FunRouterable {
        func open(url: FunRouterPathable?, handler: ((FunRouter.Response)->Void)?) {
 
        }
    }
    
    注册路由时:
    {
        "fun://webView/telMobile" : JSRouter
 
    }
 
    然后主路由会自动把`fun://webView/telMobile`交由二级路由CCRouter处理
    
 
    CCRouter在`open(url: FunRouterPathable?, handler: ((FunRouter.Response)->Void)?)`方法内自行处理和拓展
 
    
 */

public protocol FunRouterable {
    
    // MARK: - 添加新的路由表
//    func feedPages(JSON: [String: String]?)
    
//    func regist(url: FunRouterPathable?, class_name: String?)
    
    // 验证该页面有没有注册
//    func verifyRegist(_ page: FunRouterPathable?) -> Bool
    
    // 唤起路由事件
    func open(url: FunRouterPathable?, handler: ((FunRouter.Response)->Void)?)
    
    
}

extension FunRouterable {
    
}

// 路由跳转间的参数
public protocol FunRouterOptions {
    var url: URL? {get}
    var params: Any? {get}
}
// 路由跳转协议
public protocol FunRouterDelegate {
    
    func routerWillOpen(viewController: UIViewController, options: FunRouterOptions?)
    
    func routerWillBuild(options: FunRouterOptions?) -> UIViewController?
    
}
public extension FunRouterDelegate {
    func routerWillBuild(options: FunRouterOptions?) -> UIViewController? {
        return nil
    }
}
// 路由链接的解析方法
public protocol FunRouterPathable {
    
    func asParams() -> FunRouter.Parameter?
    
    func asURL() -> URL?
    
    func asPageKey() -> String?
}

public extension FunBox {
    // 路由单利
    static var router: Router {
        
        return Router.default
    }
    
    
    class Router: NSObject, FunRouterable {
        
        
        // 路由单利
        fileprivate struct Static {
            static var instance_router = FunRouter()
        }
        public static var `default`: FunRouter {
            return Static.instance_router
        }
        // 参数
        public typealias Parameter = [String: Any]
        
        // 内部Key
        fileprivate struct ParameterKey {
            static let URL = "com.FunBox.Router.ParameterKey.URL"
            static let params = "com.FunBox.Router.ParameterKey.params"
            static var options = "com.FunBox.Router.ParameterKey.options"
            static var rt_params = "com.FunBox.Router.ParameterKey.rt_params"
        }
        
        override init() {
            
            super.init()

        }
        
        // 路由表
        private var route_table: [Table: [String: Any]] = {
            var table = [Table: [String: Any]]()
            table[.main] = [String: String]()
            table[.sub_routers] = [String: FunRouterable]()
            return table
        }()
        
        struct Table: Hashable {
            var rawValue: String
            init(string: String) {
                rawValue = string
            }
            // 主表
            static let main = Table(string: "com.FunBox.Router.table.main")
            // 二级路由
            static let sub_routers = Table(string: "com.FunBox.Router.table.sub_routers")
        }
        
        // APP scheme
        public var scheme: String?
        // 项目名（方便swift去查询控制器）
        public var projectName: String? = UIApplication.shared.fb.projectName
        // 代理
        public var delegate: FunRouterDelegate?
        
        // MARK: - 打开页面
        fileprivate func show(viewController: UIViewController, animated: Bool = true, completion: ((Bool)->Void)?=nil) {
            
            if UIApplication.shared.fb.canPush {
                push2(viewController: viewController, animated: animated, completion: completion)
            } else {
                present2(viewController: viewController, animated: animated, completion: completion)
            }
        }
        
        fileprivate func push2(viewController: UIViewController, animated: Bool = true, completion: ((Bool)->Void)?=nil) {
            
            DispatchQueue.main.async {
                UIApplication.shared.fb.frontController?.navigationController?.pushViewController(viewController, animated: animated)
                if let completion = completion {
                    completion(true)
                }
            }
        }
        
        
        fileprivate func present2(viewController: UIViewController, animated: Bool = true, completion: ((Bool)->Void)?=nil) {
            

            DispatchQueue.main.async {
                UIApplication.shared.fb.frontController?.present(viewController, animated: true, completion: {
                    if let completion = completion {
                        completion(true)
                    }
                })
            }
            
            
        }
        
        // MARK: - 生成可跳转页面
        private func build(url: FunRouterPathable?, params: Any? = nil) -> UIViewController? {
            
            guard let URL = url?.asURL(), let key = URL.asPageKey(), let VC = viewController(route_table[.main]?[key] as? String) else { return nil }
            
            var options = FunRouter.Parameter()
            options[ParameterKey.URL] = URL.absoluteString
            if let option_params = (params ?? url?.asParams()) {
                options[ParameterKey.params] = option_params
            }
            
            var vc: UIViewController?
            if let viewController = delegate?.routerWillBuild(options: options) {
                
                vc = viewController
            } else {
                vc = VC.init()
            }
            vc?.rt.set(options: options)
            // 方便oc使用
            vc?.set(rt_params: options.params)
            
            if let delegate = delegate, let vc = vc {
                delegate.routerWillOpen(viewController: vc, options: options)
            }
            
            return vc
        }
        
        // MARK: - 注册支持路由的页面
        public func regist(url: FunRouterPathable?, class_name: String?) {
            guard let URL = url?.asURL() else { return }
            if router(class_name) != nil, let key = URL.asPageKey() {
                // 符合路由协议的，注册为二级路由事件
                route_table[.main]?[key] = class_name
            } else if viewController(class_name) != nil, let key = URL.asPageKey() {
                // class为ViewController的注册为页面
                route_table[.main]?[key] = class_name
            }
            
        }
        
        // MARK: - 注册二级路由
        public func regist(host: Host?, router: FunRouterable?) {
//            guard let URL = url?.asURL() else { return }
//            if router(class_name) != nil, let key = URL.asPageKey() {
//                // 符合路由协议的，注册为二级路由事件
//                route_table[.page]?[key] = class_name
//            } else if viewController(class_name) != nil, let key = URL.asPageKey() {
//                // class为ViewController的注册为页面
//                route_table[.page]?[key] = class_name
//            }
            
        }
        
        // MARK: - 添加新的注册页面
        public func feedPages(JSON: [String: String]?) {
            guard let JSON = JSON else { return }
            for item in JSON {
                regist(url: item.key, class_name: item.value)
            }
            
        }
        
        // 验证该页面有没有注册
        public func verifyRegist(_ page: FunRouterPathable?) -> Bool {
            guard let key = page?.asPageKey(), !key.isEmpty else { return false }
            var flag = false
            
            route_table[.main]?.forEach({ (item) in
                if item.key == key {
                    flag = true
                }
            })
            
            return flag
        }
        
        private func viewController(_ class_name: String?) -> UIViewController.Type? {
            guard let class_name = class_name,
                  let projectName = projectName,
                  let get_class = NSClassFromString(class_name) ?? NSClassFromString("\(projectName).\(class_name)") else {
                return nil
                
            }
            
            if get_class is UIViewController.Type {
                return get_class as? UIViewController.Type
            }
            
            return nil
        }
        
        private func router(_ class_name: String?) -> FunRouterable? {
            guard let class_name = class_name,
                  let projectName = projectName,
                  let get_class = NSClassFromString(class_name) ?? NSClassFromString("\(projectName).\(class_name)") else {
                return nil
                
            }
            
            if get_class is FunRouterable.Type {
                return get_class as? FunRouterable
            }
            
            return nil
        }
        
    }
    
}


extension FunRouter {
    // 公共页面
    public struct Page {
        fileprivate var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static func alert(message: String) -> Page {
            
            return Page(rawValue: "alert?message=\(message)")
        }
    }
    
    public struct Host {
        fileprivate var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    // 路由事件
    public struct Response {
        // 路由完整地址
        public var URL: URL?
        // 如果是Alert事件，会包含此信息
        public var alert: UIAlertAction?
        // 每个identifier会对应一个Page，方便外部查找
        public var identifier: String? {
            if let string = URL?.relativePath {
                
                if string.first == "/" {
                    return string.fb.subString(from: 1)
                }
                
                return string
            }
            return nil
        }
        // 错误信息
        public var error: Error?
    }
    
    // APP冷启动时用到的跳转方法
    public func open(launchOptions: Any?) {
        
        if let options = launchOptions as? [UIApplication.LaunchOptionsKey: Any] {
            open(url: options[.url] as? URL)
        } else if #available(iOS 13.0, *), let options = launchOptions as? UIScene.ConnectionOptions {
            open(url: options.urlContexts.first?.url)
        }
        
    }
    
    // 通过Page打开
    public func open(page: FunRouter.Page, params: Any? = nil, animated: Bool = true, completion: ((FunRouter.Response)->Void)?=nil) {
        // 生成URL
        if let scheme = scheme {
            
            let urlString = scheme + "://" + page.rawValue
            
            self.open(url: urlString, params: params, animated: animated, handler: completion)
        } else {
            completion?(Response(URL: nil, error: FunError(description: "scheme 未指派")))
        }
    }
    
    public func open(url: FunRouterPathable?, handler: ((Response) -> Void)?) {
        open(url: url, params: url?.asParams(), animated: true, handler: handler)
    }
    
    // 手动路由的方法
    public func open(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true, handler: ((FunRouter.Response)->Void)?=nil) {
        guard let URL = url?.asURL() else {
            // url为空,或者scheme不匹配
            //            HUD.tips("功能暂未开放")
            handler?(Response(URL: url?.asURL(), error: FunError(description: "url 异常")))
            return
        }
        
        if scheme != URL.scheme {
            handler?(Response(URL: URL, error: FunError(description: "scheme 不符")))
        }
        // Alert的页面不需要注册
        if ["Alert","alert"].contains(URL.host) { // Alert事件统一在这里处理
            
            let params = URL.asParams()
            var alert = FunBox.alert
                .title("提示")
                .messageFont(UIFont.systemFont(ofSize: 16))
                .messageColor(UIColor.darkText)
            if let message = (params?["message"] as? String) {
                alert = alert.message("\n\(message)")
            }
            if let title = (params?["title"] as? String) {
                alert = alert.title(title)
            }
            alert = alert.addAction(title: "取消", style: .cancel, color: UIColor.systemGray)
            alert = alert.addAction(title: "确定", style: .default, color: UIColor.orange) { (alertAction) in
                //                    if let completion = completion {
                handler?(Response(URL: URL, alert: alertAction))
                //                    }
            }
            
            alert.present()
        } else {
            
            // 已正常注册的页面
            if verifyRegist(url) {
                if let key = url?.asPageKey(),
                   let class_name = route_table[.main]?[key] as? String,
                   let subRouter = router(class_name) {
                    // 如果路由表指向了二级路由，交由二级路由处理
                    
                    subRouter.open(url: url, handler: handler)
                    debugPrint("FunRouter: SubRouter Action")
                    return
                }
                
                guard let viewController = build(url: url, params: params) else {
                    handler?(Response(URL: url?.asURL(), error: FunError(description: "未找到 ViewController")))
                    return
                    
                }
                
                if let isPresent = URL.asParams()?["present"] as? String, isPresent == "true" {
                    present2(viewController: viewController, animated: animated) { (success) in
                        //                            if let completion = completion {
                        handler?(Response(URL: URL))
                        //                            }
                    }
                } else {
                    show(viewController: viewController, animated: animated) { (success) in
                        handler?(Response(URL: URL))
                    }
                    
                }
                
            } else {
                // 没有找到已注册的页面
                //                HUD.tips("功能暂未开放")
                handler?(Response(URL: URL, error: FunError(description: "页面未注册")))
            }
        }
        
    }
}

public extension FunRouterNamespaceWrapper where T == String {
    
    var URLParameters: FunRouter.Parameter? {
        guard let url = URL.init(string: wrappedValue) else { return nil }
        
        return url.rt.URLParameters
    }
    
}


public extension FunRouterNamespaceWrapper where T == URL {
    
    var URLParameters: FunRouter.Parameter? {
        guard let components = URLComponents(url: wrappedValue, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
}

public extension FunRouterNamespaceWrapper where T: UIViewController {
    
    var options: FunRouterOptions? {
        return objc_getAssociatedObject(wrappedValue, &FunRouter.ParameterKey.options) as? FunRouter.Parameter
    }
    
    fileprivate func set(options: FunRouter.Parameter) {
        
        if !JSONSerialization.isValidJSONObject(options) {
            debugPrint("options is not a valid json object")
        }
        
        
        objc_setAssociatedObject(wrappedValue, &FunRouter.ParameterKey.options, options, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}

extension FunRouter {
    
    /// 供OC调用的方法
    /// - Parameters:
    ///   - url: 跳转地址
    ///   - params: 参数
    ///   - animated: 是否开启动画
    ///   - completion: (地址、标示、alert事件、错误信息)
    @objc public func open(url: String, params: Any? = nil, animated: Bool = true, completion: ((URL?,String?,UIAlertAction?,String?)->Void)?) {
        open(url: url, params: params, animated: animated) { (response) in
            completion?(response.URL,response.identifier,response.alert,response.error?.localizedDescription)
        }
    }
}

public extension UIViewController {
    
    @objc var rt_params: Any? {
        return objc_getAssociatedObject(self, &FunRouter.ParameterKey.rt_params)
    }
    
    fileprivate func set(rt_params: Any?) {
        
//        if !JSONSerialization.isValidJSONObject(rt_options) {
//            debugPrint("options is not a valid json object")
//        }
        
        objc_setAssociatedObject(self, &FunRouter.ParameterKey.rt_params, rt_params, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}

extension String: FunRouterNamespaceWrappable {}
extension URL: FunRouterNamespaceWrappable {}
extension UIViewController: FunRouterNamespaceWrappable {}

extension Dictionary: FunRouterPathable {
    
    public func asPageKey() -> String? {
        return nil
    }
    
    public func asURL() -> URL? {
        return nil
    }
    
    public func asParams() -> FunRouter.Parameter? {
        
        return self as? FunRouter.Parameter
    }
}

extension String: FunRouterPathable {
    public func asPageKey() -> String? {
        if let URL = asURL() {
            return URL.asPageKey()
        }
        return nil
    }
    
    
    public func asParams() -> FunRouter.Parameter? {
        
        return rt.URLParameters
    }
    
    public func asURL() -> URL? {
        
        return URL(string: self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self)
    }
}

extension URL: FunRouterPathable {
    public func asPageKey() -> String? {
        if let host = host {
            if relativePath.count > 0 {
                return host + relativePath
            } else {
                return host
            }
            
        }
        
        return nil
    }
    
    public func asParams() -> FunRouter.Parameter? {
        
        return rt.URLParameters
    }
    
    public func asURL() -> URL? {
        
        return self
    }
}

extension FunRouter.Parameter: FunRouterOptions {
    public var url: URL? {
        if let string = self[FunRouter.ParameterKey.URL] as? String {
            return URL(string: string)
        } else if let url = self[FunRouter.ParameterKey.URL] as? URL {
            
            return url
        }
        return nil
    }
    
    public var params: Any? {
        return self[FunRouter.ParameterKey.params]
    }
    
}


// 路由的命名空间
public protocol FunRouterNamespaceWrappable {
    associatedtype FunRouterWrapperType
    var rt: FunRouterWrapperType { get }
    static var rt: FunRouterWrapperType.Type { get }
}

public extension FunRouterNamespaceWrappable {
    var rt: FunRouterNamespaceWrapper<Self> {
        return FunRouterNamespaceWrapper(value: self)
    }
    
    static var rt: FunRouterNamespaceWrapper<Self>.Type {
        return FunRouterNamespaceWrapper.self
    }
}

public struct FunRouterNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}


