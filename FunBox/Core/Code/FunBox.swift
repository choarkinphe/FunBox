//
//  FunBox.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation

public class FunBox {
    public static var bundle: Bundle? {
        
        if let url = Bundle(for: self).url(forResource: "FunBox", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
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
        if hasPrefix("http") {
            return URL(string: self)
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


