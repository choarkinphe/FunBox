//
//  Service.swift
//  FunBox_Example
//
//  Created by 肖华 on 2020/8/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
@_exported import FunBox
//@_exported import HandyJSON

typealias Result = Service.Result
typealias PageElement = Service.PageElement
open class Service {
    
    enum Server: String {
        case `default` = "default"
        case local_zy = "local_zy"
    }
    
    private struct Static {
        static let instance = Service()
    }
    
    static var manager = Static.instance
    
    /*
     服务的状态码
     （统一本地服务于接口状态码）
     */
    struct Status {
        static let OK = 200
        static let Created = 201
        static let Unauthorized = 401
        static let Forbidden = 403
        static let NotFound = 404
    }
    
    struct PageElement<T: Codable>: Codable {
        var page: Int = 0
        var totalSize: Int = 0
        var data: [T]?
    }

    /*
        统一的请求结果
        接口返回的data根据值类型不同，对象分配给object，数组分配给array，方便处理
     */
    struct Result<T: Codable>: Codable {

        var errorCode: Int?
        var success: Bool = false
        var message: String?
//        private var data: Any?
        var object: T?
        var array: [T]?
        
//        mutating func mapping(mapper: HelpingMapper) {
//            // 方法 - 1
//            // 直接将‘data’解析到object和array
//            mapper.specify(property: &array, name: "data")
//            mapper.specify(property: &object, name: "data")
//        }
        
        /*
        mutating func didFinishMapping() {
            // 方法 - 2
            // 判断data的值类型，再做最终的解析（本项目直接使用方法1即可）
            /*
            if let data = data as? [String: Any] {
                object = T.deserialize(from: data)
            } else if let data = data as? [Any] {
                array = [T].deserialize(from: data) as? [T]
            }
            */
            if !success {
                // 请求报错，处理异常
                if let message = message {
                    debugPrint(message)
                }
                
                // Token过期，跳转到登陆页
                if errorCode == Service.Status.Unauthorized {
                    
                    HUD.tips("登录授权过期")
//                    FunBox.toast.message("登录授权过期").duration(2).showToast()
                    
                    RootViewController.shard.changeRootView(isLogin: false)
                }
            }
            

            
        }
         */

    }
}

// 创建一个hz的命名空间，方便扩展方法
public protocol NamespaceWrappable {
    associatedtype WrapperType
    var hz: WrapperType { get }
    static var hz: WrapperType.Type { get }
}

public extension NamespaceWrappable {
    var hz: NamespaceWrapper<Self> {
        return NamespaceWrapper(value: self)
    }

 static var hz: NamespaceWrapper<Self>.Type {
        return NamespaceWrapper.self
    }
}

public struct NamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}

