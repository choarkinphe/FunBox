//
//  FunRouter.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/11.
//

import UIKit

public typealias FunRouter = FunBox.Router
public typealias FunRouterParameter = [String: Any]

public protocol FunRouterOptions {
    var url: URL? {get}
    var params: Any? {get}
}

fileprivate struct FunRouterParameterKey {
    static let URL = "com.FunBox.Router.ParameterKey.URL"
    static let params = "com.FunBox.Router.ParameterKey.params"
}
extension FunRouterParameter: FunRouterOptions {
    public var url: URL? {
        return self[FunRouterParameterKey.URL] as? URL
    }
    
    public var params: Any? {
        return self[FunRouterParameterKey.params]
    }
    
    
}
public protocol FunRouterDelegate {
    
    func routerWillOpen(viewController: UIViewController, options: FunRouterOptions?)
    
}

public protocol FunRouterPathable {
    
    func asParams() -> FunRouterParameter?
    
    func asURL() -> URL?
}

public extension FunBox {
    
    static var router: Router {
        
        return Router.default
    }
    
    
    class Router {
        
        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(memoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }
        
        // MARK: - 内存报警时清除非前台页面参数
        @objc func memoryWarning() {
            
            for item in table_params {
                if item.key != "\(UIApplication.shared.fb.frontController.hashValue)" {
                    
                    table_params.removeValue(forKey: item.key)
                }
            }
            
        }
        
        fileprivate struct Static {
            static var instance_router = FunRouter()
        }
        
        private var table_vc = [String: UIViewController.Type]()
        fileprivate var table_params = [String: FunRouterOptions]()

        public var scheme: String?
        
        public var delegate: FunRouterDelegate?
        
        public static var `default`: FunRouter {
            return Static.instance_router
        }
        
        // MARK: - 打开页面
        public func open(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true, completion: (()->Void)?=nil) {
            
            if UIApplication.shared.fb.canPush {
                push2(url: url, params: params, animated: animated)
            } else {
                present2(url: url, params: params, animated: animated, completion: completion)
            }
        }
        
        public func push2(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true) {
            
            guard let vc = build(url: url, params: params) else { return }
            
            UIApplication.shared.fb.frontController.navigationController?.pushViewController(vc, animated: animated)
            
        }
        
        
        public func present2(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true, completion: (()->Void)?=nil) {
            
            guard let vc = build(url: url, params: params) else { return }
            
            UIApplication.shared.fb.frontController.present(vc, animated: animated, completion: completion)
            
        }
        
        // MARK: - 生成可跳转页面
        private func build(url: FunRouterPathable?, params: Any? = nil) -> UIViewController? {
            
            guard let URL = url?.asURL(), let host = URL.host, let VC = table_vc["\(host).\(URL.relativePath)"] else { return nil }
            
            let vc = VC.init()
            
            var options = FunRouterParameter()
            options[FunRouterParameterKey.URL] = URL
            if let option_params = (params ?? url?.asParams()) {
                options[FunRouterParameterKey.params] = option_params
            }

            table_params["\(vc.hashValue)"] = options
            
            if let delegate = delegate {
                delegate.routerWillOpen(viewController: vc, options: options)
            }
            
            return vc
        }
        
        // MARK: - 注册支持路由的页面
        public func regist(url: FunRouterPathable?, class_name: String?) {
            
            guard let URL = url?.asURL(), let class_name = class_name, let projectName = UIApplication.shared.fb.projectName else { return }
            
            guard let get_class = NSClassFromString("\(projectName).\(class_name)") else { return }
            
            if get_class is UIViewController.Type {
                guard let host = URL.host else { return }
                table_vc["\(host).\(URL.relativePath)"]  = get_class as? UIViewController.Type
            }
            
        }
        
        fileprivate func cleanParams() {
            
            FunRouter.default.table_params.removeValue(forKey: "\(UIApplication.shared.fb.frontController.hashValue)")
            
        }
        
    }
    
}

public extension FunRouterNamespaceWrapper where T == String {
    
    var URLParameters: FunRouterParameter? {
        guard let url = URL.init(string: wrappedValue) else { return nil }
        
        return url.rt.URLParameters
    }
    
    
}


public extension FunRouterNamespaceWrapper where T == URL {
    
    var URLParameters: FunRouterParameter? {
        guard let components = URLComponents(url: wrappedValue, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
}

public extension FunRouterNamespaceWrapper where T: UIViewController {
    
    var options: FunRouterOptions? {
        return FunRouter.default.table_params["\(wrappedValue.hashValue)"]
    }
    
}

extension String: FunRouterNamespaceWrappable {}
extension URL: FunRouterNamespaceWrappable {}
extension UIViewController: FunRouterNamespaceWrappable {}

extension Dictionary: FunRouterPathable {
    
    public func asURL() -> URL? {
        return nil
    }
    
    public func asParams() -> FunRouterParameter? {
        
        return self as? FunRouterParameter
    }
}

extension String: FunRouterPathable {
    
    public func asParams() -> FunRouterParameter? {
        
        return rt.URLParameters
    }
    
    public func asURL() -> URL? {
        
        return URL(string: self)
    }
}

extension URL: FunRouterPathable {
    public func asParams() -> FunRouterParameter? {
        
        return rt.URLParameters
    }
    
    public func asURL() -> URL? {
        
        return self
    }
}

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
