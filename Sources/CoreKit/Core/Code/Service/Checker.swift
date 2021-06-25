//
//  Checker.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/22.
//

import Foundation
public typealias Checker = Service.Checker
public protocol CheckValues {}
extension String: CheckValues{}
extension Array: CheckValues{}
extension Dictionary: CheckValues{}
extension Service {
    public struct Checker {
        
        public struct Regular {
            let rawValue: String
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            public static var mobile = Regular(rawValue: "^(1[0-9])\\d{9}$")
            public static var email = Regular(rawValue: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        }
        
        // 校验数据是否为空
        public static func isEmpty(_ object: CheckValues?) -> Bool {
            
            if let text = object as? String {
                return text.isEmpty
            }
            
            if let array = object as? [Any] {
                return array.isEmpty
            }
            
            if let dict = object as? [String: Any] {
                return dict.isEmpty
            }
            
            return true
        }
        
        static func check(_ text: String?, regular: Regular) -> Bool {
            guard let text = text else { return false }

            return text.checker.regular(regular)
        }


        public static func isMobile(_ mobile: String?) -> Bool {
            return check(mobile, regular: .mobile)
        }
        
        public static func isEmail(_ email: String?) -> Bool {
            return check(email, regular: .email)
        }
        
    }
    
    
}

extension String: CheckerNamespaceWrappable {}
public extension CheckerNamespaceWrapper where T == String {
    func regular(_ regular: Checker.Regular) -> Bool {
        var isValid = false
        
        let regex = regular.rawValue
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        isValid = predicate.evaluate(with: wrappedValue)
        
        return isValid
    }
    
    var isMobile: Bool {
        return regular(.mobile)
    }
    
    var isEmail: Bool {
        return regular(.email)
    }
    
}

// 创建一个hz的命名空间，方便扩展方法
public protocol CheckerNamespaceWrappable {
    associatedtype CheckerWrapperType
    var checker: CheckerWrapperType { get }
    static var checker: CheckerWrapperType.Type { get }
}

public extension CheckerNamespaceWrappable {
    var checker: CheckerNamespaceWrapper<Self> {
        return CheckerNamespaceWrapper(value: self)
    }
    
    static var checker: CheckerNamespaceWrapper<Self>.Type {
        return CheckerNamespaceWrapper.self
    }
}

public struct CheckerNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
