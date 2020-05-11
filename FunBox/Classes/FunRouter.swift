//
//  FunRouter.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/11.
//

import Foundation

public typealias FunRouterParameter = [String: Any]
public protocol FunRouterPathable {
    
    func asParams() -> FunRouterParameter?
    
    func asURL() -> URL?
}

public protocol FunRouterParametable {
//    func asParams() -> [String: Any]?
}

//extension FunRouterParametable {
//    func asParams() -> [String: Any]? {
//        return nil
//    }
//}

extension FunRouterParameter: FunRouterParametable {
//    public func asParams() -> [String : Any]? {
//
//        return self as? [String : Any]
//    }
//    func asParams() -> [String: Any]? {
//        return self as? [String : Any]
//    }
}

extension FunRouterParametable {
    
}

public protocol FunRoutable: UIViewController {
  /**
   类的初始化方法
   - params 传参字典
   */
    func setParams(_ params: FunRouterParametable?)
//        -> UIViewController
//    func setParams<T>(params: FunRouterPathable) -> T
    
}

//public protocol FunRouterURLConvertible {
//
//    func asURL() -> URL?
//}

public extension FunBox {
    
    static var router: Router {
        
        return Router.default
    }
    
    fileprivate struct Static {
        static var instance_router = Router()
    }
    
    class Router {
        
        private var table_vc = [String: String]()
        private var table_params = [String: String]()
        
        public static var `default`: Router {
            return Static.instance_router
        }
        
        public func push2<T>(url: FunRouterPathable?, params: T? = nil, animated: Bool = true) where T: FunRouterParametable {

            guard let vc = build(url: url, params: params) else { return }

            UIApplication.shared.frontController.navigationController?.pushViewController(vc, animated: animated)
        }
//
//        public func push2(url: FunRouterPathable?) {
//
//            guard let vc = getVC(url: url) else { return }
//
//            UIApplication.shared.frontController.present(vc, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)?.pushViewController(vc, animated: true)
//        }
        
        
        private func build<T>(url: FunRouterPathable?, params: T? = nil) -> UIViewController? where T: FunRouterParametable {
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

//fileprivate var FunRouterParamsKey = "com.FunBox.Router.paramsKey"
//
//public extension UIViewController {
//    
//    var rt_params: [String: Any]? {
//        set {
//            objc_setAssociatedObject(self, &FunRouterParamsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        get {
//            
//            return objc_getAssociatedObject(self, &FunRouterParamsKey) as? [String: Any]
//        }
//    }
//    
////    required convenience init(params: FunRouterProtocol?) {
////        self.init()
////
////        rt_params = params?.asParams()
////    }
//    
//}




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
