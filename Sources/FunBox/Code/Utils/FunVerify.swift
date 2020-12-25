//
//  FunVerify.swift
//  FunBox
//
//  Created by 肖华 on 2020/12/24.
//

import Foundation
public typealias FunVerify = FunBox.Verify
public protocol VerifyValue {}
extension String: VerifyValue {}
extension Array: VerifyValue {}
extension Dictionary: VerifyValue {}
extension FunBox {
    public struct Verify {
        
        public struct Regular {
            let rawValue: String
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            public static var mobile = Regular(rawValue: "^(1[0-9])\\d{9}$")
            public static var email = Regular(rawValue: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        }
        
        // 校验数据是否为空
        public static func isEmpty(_ object: VerifyValue?) -> Bool {
            
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

            return text.verify.regular(regular)
        }


        public static func isMobile(_ mobile: String?) -> Bool {
            return check(mobile, regular: .mobile)
        }
        
        public static func isEmail(_ email: String?) -> Bool {
            return check(email, regular: .email)
        }
        
    }
    
    
}

extension String: FunVerifyNamespaceWrappable {}
public extension FunVerifyNamespaceWrapper where T == String {
    func regular(_ regular: FunVerify.Regular) -> Bool {
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
public protocol FunVerifyNamespaceWrappable {
    associatedtype FunVerifyWrapperType
    var verify: FunVerifyWrapperType { get }
    static var verify: FunVerifyWrapperType.Type { get }
}

public extension FunVerifyNamespaceWrappable {
    var verify: FunVerifyNamespaceWrapper<Self> {
        return FunVerifyNamespaceWrapper(value: self)
    }
    
    static var verify: FunVerifyNamespaceWrapper<Self>.Type {
        return FunVerifyNamespaceWrapper.self
    }
}

public struct FunVerifyNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
