//
//  Router.swift
//  FunBox_Example
//
//  Created by 肖华 on 2020/8/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FunBox

typealias Router = FunBox.Router
extension Service: FunRouterDelegate {

static var router: Router {
    let router = Router.default
    router.delegate = Service.manager
    router.scheme = "funbox://"
    return router
}

public func routerWillOpen(viewController: UIViewController, options: FunRouterOptions?) {
    // 这里可以获取到所有即将通过路由打开的页面
    
    
}
    
}
extension Service {
    // 路由事件
    struct RouterAction {
        // 路由完整地址
        var URL: URL?
        // 如果是Alert事件，会包含此信息
        var alertAction: UIAlertAction?
        // 每个identifier会对应一个Page，方便外部查找
        var identifier: String? {
            if let string = URL?.relativePath {
                
                if string.first == "/" {
                    return string.fb.subString(from: 1)
                }
                
                return string
            }
            return nil
        }
        
    }
}

extension Router {
    // 公共页面
    enum Page: String {
        case message = "message/list"
    }
}

extension NamespaceWrapper where T : Router {
    
    func open(page: Router.Page, animated: Bool = true, completion: ((Service.RouterAction)->Void)?=nil) {
        // 生成URL
        if let scheme = wrappedValue.scheme {
        
            let urlString = scheme + page.rawValue
            
            open(url: urlString, params: nil, animated: animated, completion: completion)
        }
    }
    
    // 手动路由的方法
    func open(url: FunRouterPathable?, params: Any? = nil, animated: Bool = true, completion: ((Service.RouterAction)->Void)?=nil) {
        guard let url = url?.asURL() else {
            // url为空
//            HUD.tips("功能暂未开放")
            
            return
        }
        
        if ["Alert","alert"].contains(url.host) { // Alert事件统一在这里处理

            let params = url.asParams()
            var alert = FunBox.alert
                .title("提示")
                .messageFont(UIFont.systemFont(ofSize: 16))
                .messageColor(UIColor.darkText)
            if let message = (params?["message"] as? String) {
                alert = alert.message("\n\(message)")
            }
            if let title = (params?["title"] as? String) {
                alert = alert.title(title)
            }
            alert = alert.addAction(title: "取消", style: .cancel, color: UIColor.lightText)
            alert = alert.addAction(title: "确定", style: .default, color: UIColor.orange) { (action) in
                if let completion = completion {
                    completion(Service.RouterAction(URL: url.asURL(), alertAction: action))
                }
            }
            
            alert.present()
        } else {
            
            // 已正常注册的页面
            if wrappedValue.verifyRegist(url) {
            
                if let isPresent = url.asParams()?["present"] as? String, isPresent == "true" {
                    wrappedValue.present2(url: url, params: params, animated: animated) { (success) in
                        if let completion = completion {
                            completion(Service.RouterAction(URL: url.asURL(), alertAction: nil))
                        }
                    }
                } else {
                
                wrappedValue.open(url: url, params: params, animated: animated) { (success) in
                    if let completion = completion {
                        completion(Service.RouterAction(URL: url.asURL(), alertAction: nil))
                    }
                }
                }
                
            } else {
                // 没有找到已注册的页面
//                HUD.tips("功能暂未开放")
            }
        }
        
    }
    
    // 注册本地JSON文件中的路由规则
    func regist() {
        
        if let json = JSONSerialization.fb.json(fileName: "RouterPage.JSON", type: [String: String].self) {
            for item in json {
                print(item)
                wrappedValue.regist(url: item.key, class_name: item.value)
            }
        }
        
    }
}

extension Router: NamespaceWrappable {}
