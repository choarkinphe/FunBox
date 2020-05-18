//
//  FunTool.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/22.
//

import UIKit


public extension UIApplication {

    // 获取当前的window
    var currentWindow: UIWindow? {
        
        if let window = UIApplication.shared.keyWindow {
            return window
        }
        
        if #available(iOS 13.0, *) {

            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                
                if windowScene.activationState == .foregroundActive {
                    
                    return windowScene.windows.first
                    
                }
                
            }

        }
        
        return nil
        
    }
    
    var canPush: Bool {
        return frontController.navigationController != nil
    }
    
    // 获取当前控制器
    var frontController: UIViewController {
        
        let rootViewController = UIApplication.shared.currentWindow?.rootViewController
        
        return findFrontViewController(rootViewController!)
    }
    
    var projectName: String? {

        return Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
    }
    
    private func findFrontViewController(_ currnet: UIViewController) -> UIViewController {
        
        if let presentedController = currnet.presentedViewController {
            
            return findFrontViewController(presentedController)
            
        } else if let svc = currnet as? UISplitViewController, let next = svc.viewControllers.last {
            
            
            return findFrontViewController(next)
            
        } else if let nvc = currnet as? UINavigationController, let next = nvc.topViewController {
            
            return findFrontViewController(next)
            
        } else if let tvc = currnet as? UITabBarController, let next = tvc.selectedViewController {
            
            
            return findFrontViewController(next)
            
            
        } else if currnet.children.count > 0 {
            
            for child in currnet.children {
                
                if currnet.view.subviews.contains(child.view) {
                    
                    return findFrontViewController(child)
                }
            }
            
        }
        
        return currnet
        
    }
    
}

public extension FunBox {
    
    struct Device {
        
        public var systemVersion: Float
        
        public var screenSize: CGSize
        
        public var iPhoneXSeries: Bool = false
        
        public init() {
            if UIDevice.current.userInterfaceIdiom == .phone {
                
                if let mainWindow = UIApplication.shared.delegate?.window {
                    
                    if #available(iOS 11.0, *) {
                        if mainWindow!.safeAreaInsets.bottom > CGFloat(0.0) {
                            
                            iPhoneXSeries = true
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
            }
            
            screenSize = UIScreen.main.bounds.size
            
            if let version = Float(UIDevice.current.systemVersion) {
                systemVersion = version
            } else {
                systemVersion = 10.0
            }
        }

    }
}



/*
    方法交换
 */
public protocol FunSwizz: class {
    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector)
}

public extension FunSwizz {
    
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





