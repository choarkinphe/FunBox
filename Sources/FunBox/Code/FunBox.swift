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
        public var navigationBarHidden: Bool = false
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
    
    func characterSet(_ characterSet: CharacterSet) -> URL?
    
    func appendQuery(_ params: URLParamsConvertable?, characters: CharacterSet?) -> URL?
    
    func query() -> URLParams?
}

extension URL: FunURLConvertable {
    public var realURL: URL? {
        return self
    }
    
    public func appendQuery(_ params: URLParamsConvertable?, characters: CharacterSet?) -> URL? {
        
        return absoluteString.appendQuery(params, characters: characters)
        
    }

    public func characterSet(_ characterSet: CharacterSet) -> URL? {
        return absoluteString.characterSet(characterSet)
    }
    
    public func query() -> URLParams? {
        
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: URLParams()) { (result, item) in
            result[item.name] = item.value
        }
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
    
    public func appendQuery(_ params: URLParamsConvertable?, characters: CharacterSet?) -> URL? {
        
        var url = self
        
        if let query = params?.asQuery(characters: characters) {
            var new_query = true
            // 解码出url 中已经包含的参数
            if let url_query = url.query() ?? url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.query() {
                // 如果url结尾与参数值相同，说明原来有参数在结尾
                url_query.forEach { (item) in
                    if url.hasSuffix(item.value) {
                        new_query = false
                    }
                }
            }
            
            if new_query {
                // 新添加的参数用"?"拼接
                url = url + "?" + query
            } else {
                // 继续添加参数用&分割
                url = url + "&" + query
            }
        }
        //绝对地址
        return url.realURL
        
    }
    
    public func characterSet(_ characterSet: CharacterSet) -> URL? {
        
        if let url = addingPercentEncoding(withAllowedCharacters: characterSet) {
            return url.realURL
        }
        
        return nil
    }
    // 从String中截取出参数
    public func query() -> URLParams? {
        
        return realURL?.query()
        
    }
}

extension CharacterSet {
    public static var `default`: CharacterSet {
        var set = CharacterSet.urlQueryAllowed
        set.insert("#")
        set.insert("%")
        return set
    }
    
    public static let query = CharacterSet(charactersIn: "?!@#$^&%*+,:;='\"`<>()[]{}/\\|")
}


public typealias URLParams = [String: String]
public protocol URLParamsConvertable {
    func asQuery(characters: CharacterSet?) -> String?
}
extension URLParams: URLParamsConvertable {
    public func asQuery(characters: CharacterSet?) -> String? {
        var pairs = [String]()
        
        forEach { (item) in
            
            if let characters = characters, let escaped_value = item.value.addingPercentEncoding(withAllowedCharacters: characters) {
            
                pairs.append("\(item.key)=\(escaped_value)")
            } else {
                pairs.append("\(item.key)=\(item.value)")
            }
        }
        
        if !pairs.isEmpty {
            return pairs.joined(separator: "&")
        }
        
        return nil
    }
}

extension String: URLParamsConvertable {
    public func asQuery(characters: CharacterSet?) -> String? {
        if let characters = characters {
            return addingPercentEncoding(withAllowedCharacters: characters)
        }
        return self
    }
}


/*
    方法交换
 */
protocol FunSwizz: AnyObject {
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


public protocol FunModuleProtocol: AnyObject {
    
    static var bundle: Bundle? { get }
    
}
public typealias FunEncoder = FunBox.Encoder
extension FunBox {
    public struct Encoder: Equatable {
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        public static let base64 = Encoder(rawValue: "base64")
    }
}
