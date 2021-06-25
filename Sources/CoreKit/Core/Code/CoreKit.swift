//
//  CoreKit.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/15.
//

import Foundation
#if !COCOAPODS
import FunBox
#endif
//public typealias HZRouter = FunBox.Router
public class CoreKit: NSObject {
    public static var router: FunRouter {
        let router = FunRouter.default
        
        return router
    }
    
    fileprivate static var modules: [String] {
        var modules = [String]()
        modules.append("HZUIKit")
        return modules
    }
    
}

// create namespace
extension NSObject: CKNamespaceWrappable {}
public protocol CKNamespaceWrappable {
    associatedtype WrapperType
    var ck: WrapperType { get }
    static var ck: WrapperType.Type { get }
}

public extension CKNamespaceWrappable {
    var ck: CKNamespaceWrapper<Self> {
        return CKNamespaceWrapper(value: self)
    }

    static var ck: CKNamespaceWrapper<Self>.Type {
        return CKNamespaceWrapper.self
    }
}

public struct CKNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}

extension CoreKit: CKModuleProtocol {
    public static var bundle: Bundle? {
        
        if let url = Bundle(for: self).url(forResource: "CoreKit", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
    
    @objc public static func install() {
        
        modules.forEach { (class_name) in
            
            
                (NSClassFromString("CoreKit.\(class_name)") as? CKModuleProtocol.Type)?.install()
                
            
        }
        
    }
}

public class CKClass: NSObject {
    open class func swizz() {}
}

public protocol CKModuleProtocol: AnyObject {
    static func install()
    
    static var bundle: Bundle? { get }
    
    static var routingTablePath: String? { get }
}

public extension CKModuleProtocol {
    static func install() {
        // 注册路由表
        CoreKit.router.feedPages(JSON: JSONSerialization.fb.json(filePath: routingTablePath, type: [String: String].self))
    }
    
    static var routingTablePath: String? {
        return nil
    }
    
    static var bundle: Bundle? { return .main }
}





