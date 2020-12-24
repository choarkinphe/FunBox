//
//  FunBox.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/15.
//

import UIKit

public class FunBox {
    public static var bundle: Bundle? {
        
        if let url = Bundle(for: self).url(forResource: "FunBox", withExtension: "bundle") {
            return Bundle(url: url)
        } else if let url = Bundle(for: FunBox.self).path(forResource: "FunBox_FunBox.bundle", ofType: nil) {
            return Bundle(path: url)
        }
        return nil
    }
    
    public static var manager = Static.instance
    fileprivate struct Static {
        static let instance = FunBox()
    }
    
    public var config = Config()
    
}
extension FunBox {
    public struct Config: Codable {
        public var keyboardAutoDismiss: Bool = true
    }
}

// MARK: - NameSpace
public protocol FunNamespaceWrappable {
    associatedtype FunWrapperType
    var fb: FunWrapperType { get }
    static var fb: FunWrapperType.Type { get }
}

public extension FunNamespaceWrappable {
    var fb: FunNamespaceWrapper<Self> {
        return FunNamespaceWrapper(value: self)
    }

 static var fb: FunNamespaceWrapper<Self>.Type {
        return FunNamespaceWrapper.self
    }
}

public struct FunNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}

public protocol FunURLConvertable {
    
    var realURL: URL? { get }
}

extension URL: FunURLConvertable {
    public var realURL: URL? {
        return self
    }
}

extension String: FunURLConvertable {
    public var realURL: URL? {
        if self.lowercased().hasPrefix("http") {
            return URL(string: self)
        } else if let url = URL(string: self) {
            if url.scheme != nil {
                return url
            }
        }
        return nil
    }
}

/*
    方法交换
 */
protocol FunSwizz: class {
    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector)
}

extension FunSwizz {
    
    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        guard (originalMethod != nil && swizzledMethod != nil) else {
            return
        }
        if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
}


public typealias FunAuthorize = FunBox.Authorize
public extension FunBox {
    // 获取权限
    struct Authorize { }
}


public extension FunBox {
    struct Options {
        struct Application {
            static func openExternalURL(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
                return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
            }
        }
        
    }
}
