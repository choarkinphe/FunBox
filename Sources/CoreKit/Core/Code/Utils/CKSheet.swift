//
//  Selector.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/10.
//

import Foundation
public protocol CKSheetValue: HandyJSON {
    var text: String? { get }
    var value: String? { get }
}
public struct CKSheetPath {
    let rawValue: String
    public init(path: String) {
        self.rawValue = path
    }
}
public struct CKKeyValue: CKSheetValue {
    public init() { }
    public var text: String?
    public var value: String?
}

public struct CKSheet<Element: CKSheetValue>: APITargetType {
    private var disposeBag = DisposeBag()
    let rawPath: CKSheetPath
    public init(_ path: CKSheetPath) {
        self.rawPath = path
    }
    public var path: String {
        return rawPath.rawValue
    }
    
    private var provider = MoyaProvider<CKSheet>().rx

    /*
     缓存池，读写本地数据
     */
    private static var cachePool: FunBox.Cache {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        
        let cachePathName = "com.hz_tech.core.appcache.sheet"
        // 指定缓存路径
        let cachePool = FunBox.Cache.init(path: directoryPath! + "/\(cachePathName)")
        // 缓存有效期为30秒
        cachePool.cacheTimeOut = 30
        return cachePool
    }
    
    public func response(options: CKSheetOptions?=nil, complete: @escaping ((Element)->Void)) {
        
        var cache_timeOut: TimeInterval = .zero
        var sender: UIView?
        options?.forEach { (option) in
            if option == .cache, let timeOut = option.paramter as? TimeInterval {
                cache_timeOut = timeOut
            }
            if option == .sender {
                sender = option.paramter as? UIView
            }
        }
        
        if cache_timeOut != .zero {
            if let data = CKSheet<Element>.cachePool.loadCache(key: path), let string = String(data: data, encoding: .utf8), let elements = [Element].deserialize(from: string) as? [Element] {
                sender?.isUserInteractionEnabled = true
                present(elements: elements, complete: complete)
                return
            }
        }
        
        provider.request(to: self)
            .mapResult(Element.self)
            .response { (result) in
                sender?.isUserInteractionEnabled = true
                // 得到列表的数据模型
                if let elements = result.array {
                    present(elements: elements, complete: complete)
                    if let string = elements.toJSONString(), cache_timeOut != .zero {
                        CKSheet<Element>.cachePool.cache(key: path, data: string.data(using: String.Encoding.utf8), options: [.timeOut(cache_timeOut)])
                    }
                }
            }.disposed(by: disposeBag)
    }
    
    private func present(elements: [Element], complete: @escaping ((Element)->Void)) {
        // 生成一个Sheet弹窗
        FunBox.Sheet.default.addActions(texts(elements)).handler { (action) in
            // 将最终选取到的结果回调出去
            DispatchQueue.main.async {
                
                complete(elements[action.index])
            }
        }.present()
    }
    
    // 数据转换
    private func texts(_ items: [Element]) -> [String] {
        var texts = [String]()
        for item in items {
            if let text = item.text {
                texts.append(text)
            }
        }
        
        return texts
    }
    

}

// MARK: - HZSheetOptions
public typealias CKSheetOptions = [CKSheetOption]
public struct CKSheetOption: Equatable {
    public static func == (lhs: CKSheetOption, rhs: CKSheetOption) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    var paramter: Any?
    private let rawValue: String
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    // 使用缓存
    fileprivate static let cache = CKSheetOption(rawValue: "cache")
    public static func cache(timeOut: TimeInterval = 15) -> CKSheetOption {
        var option = CKSheetOption(rawValue: "cache")
        option.paramter = timeOut
        return option
    }
    
    // 绑定触发器
    fileprivate static let sender = CKSheetOption(rawValue: "sender")
    public static func sender(_ sender: UIView?) -> CKSheetOption {
        var option = CKSheetOption(rawValue: "sender")
        option.paramter = sender
        return option
    }
    
}



