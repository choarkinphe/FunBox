//
//  FunRouter.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/11.
//

import UIKit

public typealias FunRouter = FunBox.Router
// 路由跳转间的参数
public protocol FunRouterOptions {
    var url: URL? {get}
    var params: Any? {get}
}
// 路由跳转协议
public protocol FunRouterDelegate {
    
    func routerWillOpen(viewController: UIViewController, options: FunRouterOptions?)
    
}
// 路由链接的解析方法
public protocol FunRouterPathable {
    
    func asParams() -> FunRouter.Parameter?
    
    func asURL() -> URL?
    
    func asPageKey() -> String?
}

// APP启动数据协议
public protocol APPLaunchable {
    var url: URL? { get }
}

public extension FunBox {
    // 路由单利
    static var router: Router {
        
        return Router.default
    }
    
    
    class Router: NSObject {
        // 路由单利
        fileprivate struct Static {
            static var instance_router = FunRouter()
        }
        public static var `default`: FunRouter {
            return Static.instance_router
        }
        // 参数
        public typealias Parameter = [String: Any]
        // APP启动参数
        public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]
        
        // 内部Key
        fileprivate struct ParameterKey {
            static let URL = "com.FunBox.Router.ParameterKey.URL"
            static let params = "com.FunBox.Router.ParameterKey.params"
            static var options = "com.FunBox.Router.ParameterKey.options"
        }
        
        override init() {

            super.init()
//            NotificationCenter.default.addObserver(self, selector: #selector(memoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }
        
        // MARK: - 内存报警时清除非前台页面参数
//        @objc func memoryWarning() {
//
//            for item in table_params {
//                if item.key != "\(UIApplication.shared.fb.frontController.hashValue)" {
//
//                    table_params.removeValue(forKey: item.key)
//                }
//            }
//
//        }
        

        
        // 所有已注册的路由表
//        public var routerPages: [String] {
//            var pages = [String]()
//            if let items = route_table[.page] {
//                
//                for item in items {
//                    pages.append(item.key)
//                }
//            }
//            return pages
//        }
        
        // 路由表
        
        
        private var route_table: [Table: [String: Any]] = {
            var table = [Table: [String: Any]]()
            table[.page] = [String: String]()
            return table
        }()
        
        struct Table: Hashable {
            var rawValue: String
            init(string: String) {
                rawValue = string
            }
            // 页面表
            static let page: Table = Table(string: "com.FunBox.Router.table.page")
        }
//        fileprivate var table_params = [String: FunRouterOptions]()
        // APP scheme（预留）
        public var scheme: String?
        // 代理
        public var delegate: FunRouterDelegate?
        
        
        // MARK: - 打开页面
        fileprivate func show(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true, completion: ((Bool)->Void)?=nil) {
            
            if UIApplication.shared.fb.canPush {
                push2(url: url, params: params, animated: animated, completion: completion)
            } else {
                present2(url: url, params: params, animated: animated, completion: completion)
            }
        }
        
        public func push2(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true, completion: ((Bool)->Void)?=nil) {
            
            guard let vc = build(url: url, params: params) else {
                if let completion = completion {
                    completion(false)
                }
                return
                
            }
            DispatchQueue.main.async {
                UIApplication.shared.fb.frontController?.navigationController?.pushViewController(vc, animated: animated)
                if let completion = completion {
                    completion(true)
                }
            }
        }
        
        
        public func present2(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true, completion: ((Bool)->Void)?=nil) {
            
            guard let vc = build(url: url, params: params) else {
                if let completion = completion {
                    completion(false)
                }
                return
                
            }
            DispatchQueue.main.async {
                UIApplication.shared.fb.frontController?.present(vc, animated: true, completion: {
                    if let completion = completion {
                        completion(true)
                    }
                })
            }
            
            
        }
        
        // MARK: - 生成可跳转页面
        private func build(url: FunRouterPathable?, params: Any? = nil) -> UIViewController? {
            
            guard let URL = url?.asURL(), let key = URL.asPageKey(), let VC = viewController(route_table[.page]?[key] as? String) else { return nil }
            
            let vc = VC.init()
            
            var options = FunRouter.Parameter()
            options[ParameterKey.URL] = URL.absoluteString
            if let option_params = (params ?? url?.asParams()) {
                options[ParameterKey.params] = option_params
            }
            
//            table_params["\(vc.hashValue)"] = options
            vc.rt.set(options: options)
            
            if let delegate = delegate {
                delegate.routerWillOpen(viewController: vc, options: options)
            }
            
            return vc
        }
        
        // MARK: - 注册支持路由的页面
        public func regist(url: FunRouterPathable?, class_name: String?) {
            guard let URL = url?.asURL() else { return }
//            guard let URL = url?.asURL(), let class_name = class_name, let projectName = UIApplication.shared.fb.projectName else { return }
//            class_name = "\(projectName).\(class_name)"
            // 先直接获取类(oc不需要项目名)，没有货渠道再拼叫项目名获取swift类
//            guard let get_class = NSClassFromString(class_name) ?? NSClassFromString("\(projectName).\(class_name)") else { return }
//
//            if get_class is UIViewController.Type {
//                guard let key = URL.asPageKey() else { return }
////                table_vc[key] = get_class as? UIViewController.Type
//                route_table[.page]?[key] = class_name
//            }
            
            if viewController(class_name) != nil, let key = URL.asPageKey() {
                
                route_table[.page]?[key] = class_name
            }
            
        }
        
        // 验证该页面有没有注册
        public func verifyRegist(_ page: FunRouterPathable?) -> Bool {
            guard let key = page?.asPageKey(), !key.isEmpty else { return false }
            var flag = false
            
            route_table[.page]?.forEach({ (item) in
                if item.key == key {
                    flag = true
                }
            })
            
            return flag
        }
        
        private func viewController(_ class_name: String?) -> UIViewController.Type? {
            guard let class_name = class_name, let projectName = UIApplication.shared.fb.projectName, let get_class = NSClassFromString(class_name) ?? NSClassFromString("\(projectName).\(class_name)") else { return nil }
            
            if get_class is UIViewController.Type {
                return get_class as? UIViewController.Type
            }
            
            return nil
        }
        
//        fileprivate func cleanParams() {
//
//            FunRouter.default.table_params.removeValue(forKey: "\(UIApplication.shared.fb.frontController.hashValue)")
//
//        }
        
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
    
    // 路由事件
    public struct Action {
        // 路由完整地址
        public var URL: URL?
        // 如果是Alert事件，会包含此信息
        public var alertAction: UIAlertAction?
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
        
    }
    
    // APP启动或者外部唤醒APP时会走到这里
    public func open(launchOptions: APPLaunchable?, completion: ((FunRouter.Action)->Void)?=nil) {

        guard let launchOptions = launchOptions, let url = launchOptions.url else { return }
        
        self.open(url: url, params: nil, animated: true, handler: completion)
    }
    
    // 通过Page打开
    public func open(page: FunRouter.Page, params: Any? = nil, animated: Bool = true, completion: ((FunRouter.Action)->Void)?=nil) {
        // 生成URL
        if let scheme = scheme {
        
            let urlString = scheme + page.rawValue
            
            self.open(url: urlString, params: params, animated: animated, handler: completion)
        }
    }
    
    // 手动路由的方法
    public func open(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true, handler: ((FunRouter.Action)->Void)?=nil) {
            guard let url = url?.asURL() else {
                // url为空
    //            HUD.tips("功能暂未开放")
                
                return
            }
            
            if ["Alert","alert"].contains(url.host) { // Alert事件统一在这里处理

                let params = url.asParams()
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
                alert = alert.addAction(title: "取消", style: .cancel, color: UIColor.lightText)
                alert = alert.addAction(title: "确定", style: .default, color: UIColor.orange) { (action) in
//                    if let completion = completion {
                        handler?(Action(URL: url.asURL(), alertAction: action))
//                    }
                }
                
                alert.present()
            } else {
                
                // 已正常注册的页面
                if verifyRegist(url) {
                
                    if let isPresent = url.asParams()?["present"] as? String, isPresent == "true" {
                        present2(url: url, params: params, animated: animated) { (success) in
//                            if let completion = completion {
                                handler?(Action(URL: url.asURL(), alertAction: nil))
//                            }
                        }
                    } else {
                        show(url: url, params: params, animated: animated) { (success) in
                            handler?(Action(URL: url.asURL(), alertAction: nil))
                        }

                    }
                    
                } else {
                    // 没有找到已注册的页面
    //                HUD.tips("功能暂未开放")
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

@available(iOS 13.0, *)
extension UIScene.ConnectionOptions: APPLaunchable {
    public var url: URL? {
        return urlContexts.first?.url
    }
    
}

extension FunRouter.LaunchOptions: APPLaunchable {
    public var url: URL? {
        return self[UIApplication.LaunchOptionsKey.url] as? URL
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


