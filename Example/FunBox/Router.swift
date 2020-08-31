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

extension Router.Page {
    static var message: Router.Page = Router.Page(rawValue: "message/list")
}

extension NamespaceWrapper where T : Router {
    
    
    
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
