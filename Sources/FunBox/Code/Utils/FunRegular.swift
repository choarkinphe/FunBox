//
//  Regular.swift
//  Regular
//
//  Created by choarkinphe on 2020/9/22.
//  正则匹配

import Foundation
public typealias FunRegular = FunBox.Regular
public protocol FunRegularValues {}
extension String: FunRegularValues{}
extension Array: FunRegularValues{}
extension Dictionary: FunRegularValues{}
extension FunBox {
    public struct Regular {
        let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public static var mobile = Regular(rawValue: "^(1[0-9])\\d{9}$")
        public static var email = Regular(rawValue: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
//        public struct Regular {
//
//        }
        
        // 校验数据是否为空
        public static func isEmpty(_ object: FunRegularValues?) -> Bool {
            
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
        
        static func matching(_ text: String?, regular: Regular) -> Bool {
            guard let text = text else { return false }

            return text.regular.matching(regular)
        }


        public static func isMobile(_ mobile: String?) -> Bool {
            return matching(mobile, regular: .mobile)
        }
        
        public static func isEmail(_ email: String?) -> Bool {
            return matching(email, regular: .email)
        }
        
    }
    
    
}

extension String: FunRegularNamespaceWrappable {}
public extension FunRegularNamespaceWrapper where T == String {
    func matching(_ regular: FunRegular) -> Bool {
        var isValid = false
        
        let regex = regular.rawValue
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        isValid = predicate.evaluate(with: wrappedValue)
        
        return isValid
    }
    
    var isMobile: Bool {
        return matching(.mobile)
    }
    
    var isEmail: Bool {
        return matching(.email)
    }
    
}

// 创建一个hz的命名空间，方便扩展方法
public protocol FunRegularNamespaceWrappable {
    associatedtype FunRegularWrapperType
    var regular: FunRegularWrapperType { get }
    static var regular: FunRegularWrapperType.Type { get }
}

public extension FunRegularNamespaceWrappable {
    var regular: FunRegularNamespaceWrapper<Self> {
        return FunRegularNamespaceWrapper(value: self)
    }
    
    static var regular: FunRegularNamespaceWrapper<Self>.Type {
        return FunRegularNamespaceWrapper.self
    }
}

public struct FunRegularNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
