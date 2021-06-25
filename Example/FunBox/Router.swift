//
//  Router.swift
//  FunBox_Example
//
//  Created by 肖华 on 2020/8/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FunBox
import CoreKit

typealias Router = FunBox.Router
extension Service: FunRouterDelegate {
    
    
    // APP启动参数
    typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]
    
    @objc static var router: Router {
        let router = Router.default
        router.delegate = Service.manager
        router.scheme = "funbox"
        return router
    }
    
    public func routerWillOpen(viewController: UIViewController, options: FunRouterOptions?) {
        // 这里可以获取到所有即将通过路由打开的页面
        
        
    }
//    构造需要跳转的VC，实现了就会走这里
    public func routerWillBuild(options: FunRouterOptions?) -> UIViewController? {
        if options?.url?.pathExtension == "message/list" {
            return UIStoryboard.init(name: "xx", bundle: .main).instantiateInitialViewController()
        }
        return nil
    }
    
}


extension Router.Page {
    static var message: Router.Page = Router.Page(rawValue: "message/list")
}

// APP启动数据协议
public protocol APPLaunchable {
    var url: URL? { get }
}

@available(iOS 13.0, *)
extension UIScene.ConnectionOptions: APPLaunchable {
    public var url: URL? {
        return urlContexts.first?.url
    }

}


extension Service.LaunchOptions: APPLaunchable {
    public var url: URL? {
        return self[.url] as? URL
    }

}

//extension NamespaceWrapper where T : Router {
//    
//    // APP启动或者外部唤醒APP时会走到这里
//    func open(launchOptions: APPLaunchable?, completion: ((FunRouter.Response)->Void)?=nil) {
//        
//        guard let launchOptions = launchOptions, let url = launchOptions.url else { return }
//        
//        wrappedValue.open(url: url, params: nil, animated: true, handler: completion)
//    }
//
//    // 注册本地JSON文件中的路由规则
//    func regist() {
//        
//        if let json = JSONSerialization.fb.json(fileName: "RouterPage.JSON", type: [String: String].self) {
//            for item in json {
//                print(item)
//                wrappedValue.regist(url: item.key, class_name: item.value)
//            }
//        }
//        
//    }
//}
//
//extension Router: NamespaceWrappable {}
