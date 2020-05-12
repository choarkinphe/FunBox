//
//  FunRouter.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/11.
//

import Foundation

public typealias FunRouter = FunBox.Router
public typealias FunRouterParameter = [String: Any]
public protocol FunRouterPathable {
    
    func asParams() -> FunRouterParameter?
    
    func asURL() -> URL?
}

public protocol FunRouterParametable {
    func asDictionary() -> FunRouterParameter?
}

public protocol FunRoutable: UIViewController {
    
    func setParams(_ params: FunRouterParametable?)
}

public extension FunBox {

    static var router: Router {

        return Router.default
    }
    
    
    class Router {
        
        fileprivate struct Static {
            static var instance_router = FunRouter()
        }
        
        private var table_vc = [String: String]()
        private var table_params = [String: String]()
        
        public static var `default`: FunRouter {
            return Static.instance_router
        }
        
        public func push2(url: FunRouterPathable?, params: FunRouterParametable? = nil, animated: Bool = true) {

            guard let vc = build(url: url, params: params) else { return }

            UIApplication.shared.frontController.navigationController?.pushViewController(vc, animated: animated)
        }

        public func present2(url: FunRouterPathable?, params: FunRouterParametable? = nil, animated: Bool = true, completion: (()->Void)?=nil) {

            guard let vc = build(url: url, params: params) else { return }

            UIApplication.shared.frontController.present(vc, animated: animated, completion: completion)
        }
        
        
        private func build(url: FunRouterPathable?, params: FunRouterParametable? = nil) -> UIViewController? {
            guard let identifier = url?.asURL()?.host, let projectName = UIApplication.shared.projectName, let vc_name = table_vc[identifier] else { return nil }
            let class_name = "\(projectName).\(vc_name)"
            
            guard let get_class = NSClassFromString(class_name), let VC = get_class as? FunRoutable.Type else { return nil }
            
            let vc = VC.init()
            
            vc.setParams(params ?? url?.asParams())
            
            return vc
        }
        
        public func registVC() {
            table_vc["AAA"] = "TableViewController"
        }
        
    }

}

public extension FunRouterNamespaceWrapper where T == String {
    
    var URLParameters: [String: String]? {
        guard let url = URL.init(string: wrappedValue) else { return nil }
        
        return url.rt.URLParameters
    }
    
    var host: String? {
        
        guard let url = URL.init(string: wrappedValue) else { return nil }
        
        return url.host
    }
}



public extension FunRouterNamespaceWrapper where T == URL {
    
    var URLParameters: [String: String]? {
        guard let components = URLComponents(url: wrappedValue, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
}

extension String: FunRouterNamespaceWrappable {}
extension URL: FunRouterNamespaceWrappable {}

extension FunRouterParametable {
    public func asDictionary() -> FunRouterParameter? {
        return nil
    }
}

extension Dictionary: FunRouterParametable {
    public func asDictionary() -> FunRouterParameter? {
        return self as? FunRouterParameter
    }
}


extension Dictionary: FunRouterPathable {
    public func asURL() -> URL? {
        return nil
    }

    public func asParams() -> [String : Any]? {

        return self as? [String : Any]
    }
}

extension String: FunRouterPathable {
    public func asParams() -> [String : Any]? {
        
        return rt.URLParameters
    }
    
    public func asURL() -> URL? {

        return URL(string: self)
    }
}

extension URL: FunRouterPathable {
    public func asParams() -> [String : Any]? {
        
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
