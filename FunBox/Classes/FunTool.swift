//
//  FunTool.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/22.
//

import Foundation
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

public extension FunBox {
    struct Config {
        
    }
    
    class Observer: NSObject {
        override init() {
            super.init()
            // 监听键盘弹出
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            // 监听键盘隐藏
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            // 监听屏幕方向
            NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        private var deviceOrientation: ((UIDeviceOrientation)->Void)?
        
        public func deviceOrientation(_ handler: ((UIDeviceOrientation)->Void)?) {
            deviceOrientation = handler
            if let handler = handler {
                handler(UIDevice.current.orientation)
            }
        }

        @objc fileprivate func deviceOrientationChanged(notification: Notification) {

            if let handler = deviceOrientation {
                handler(UIDevice.current.orientation)
            }

        }

        private var keyboardHandler: (((isShow: Bool, rect: CGRect))->Void)?
        public func keyboardShow(_ handler: (((isShow: Bool, rect: CGRect))->Void)?) {
            keyboardHandler = handler
        }
        
        @objc fileprivate func keyboardWillShow(notification: Notification) {
            keyboardChanged(isShow: true, notification: notification)
        }
        
        @objc fileprivate func keyboardWillHidden(notification: Notification) {
            keyboardChanged(isShow: false, notification: notification)
        }
        
        private func keyboardChanged(isShow: Bool, notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                
            //获取动画执行的时间(没有的话默认0.25s)
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
            
            UIView.animate(withDuration: duration, delay: 0, options: .allowAnimatedContent, animations: {
                if let handler = self.keyboardHandler {
                    handler((isShow,keyboardRect))
                }
            }) { (complete) in
                
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

extension FunBox.Config {
    struct Refresher {
        static var timeOut: TimeInterval = 15
    }
}
extension FunBox {
    public class Refresher: UIRefreshControl {
        private var handler: ((UIRefreshControl)->Void)?
//        lazy var control: UIRefreshControl = {
//            let control = UIRefreshControl()
//            control.addTarget(self, action: #selector(refreshAction(sender:)), for: .valueChanged)
//            return control
//        }()
        private var timeOut: TimeInterval = FunBox.Config.Refresher.timeOut
        public func text(_ text: String) -> Self {
            self.attributedTitle = NSAttributedString(string: text)
            return self
        }
        
        public func timeOut(_ timeOut: TimeInterval) -> Self {
            self.timeOut = timeOut
            return self
        }
        
        public func tintColor(_ tintColor: UIColor) -> Self {
            self.tintColor = tintColor
            return self
        }
        
        public func complete(_ complete: ((UIRefreshControl)->Void)?) {
            addTarget(self, action: #selector(refreshAction(sender:)), for: .valueChanged)
            self.handler = complete
        }
        
        @objc private func refreshAction(sender: UIRefreshControl) {
            if let handler = self.handler {
                handler(sender)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+timeOut) {
                sender.endRefreshing()
            }
        }
        
        public override func layoutSubviews() {
            superview?.layoutSubviews()
            
            
        }
    }
}

public protocol FunURLConvertable {
    
    var realURL: URL? { get }
}

extension URL: FunURLConvertable {
    public var realURL: URL? {
        return self
    }
    
    
}

extension String: FunURLConvertable {
    public var realURL: URL? {
        return URL.init(string: self)
    }
}


//public extension UIApplication {
//
//    // 获取当前的window
//    var currentWindow: UIWindow? {
//        
//        if let window = UIApplication.shared.keyWindow {
//            return window
//        }
//        
//        if #available(iOS 13.0, *) {
//
//            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
//                
//                if windowScene.activationState == .foregroundActive {
//                    
//                    return windowScene.windows.first
//                    
//                }
//                
//            }
//
//        }
//        
//        return nil
//        
//    }
//    
//    var canPush: Bool {
//        return frontController.navigationController != nil
//    }
//    
//    // 获取当前控制器
//    var frontController: UIViewController {
//        
//        let rootViewController = UIApplication.shared.currentWindow?.rootViewController
//        
//        return findFrontViewController(rootViewController!)
//    }
//    
//    var projectName: String? {
//
//        return Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
//    }
//    
//    private func findFrontViewController(_ currnet: UIViewController) -> UIViewController {
//        
//        if let presentedController = currnet.presentedViewController {
//            
//            return findFrontViewController(presentedController)
//            
//        } else if let svc = currnet as? UISplitViewController, let next = svc.viewControllers.last {
//            
//            
//            return findFrontViewController(next)
//            
//        } else if let nvc = currnet as? UINavigationController, let next = nvc.topViewController {
//            
//            return findFrontViewController(next)
//            
//        } else if let tvc = currnet as? UITabBarController, let next = tvc.selectedViewController {
//            
//            
//            return findFrontViewController(next)
//            
//            
//        } else if currnet.children.count > 0 {
//            
//            for child in currnet.children {
//                
//                if currnet.view.subviews.contains(child.view) {
//                    
//                    return findFrontViewController(child)
//                }
//            }
//            
//        }
//        
//        return currnet
//        
//    }
//    
//}



//public extension FunBox {
//
//    struct Device {
//
//        public var systemVersion: Float
//
////        public static var screenSize: CGSize {
////            return UIScreen.main.bounds.size
////        }
//
//        public var iPhoneXSeries: Bool = false
//
//        public init() {
//            if UIDevice.current.userInterfaceIdiom == .phone {
//
//                if let mainWindow = UIApplication.shared.delegate?.window as? UIWindow {
//                    if #available(iOS 11.0, *) {
//
//                    if mainWindow.safeAreaInsets.bottom > CGFloat(0.0) {
//
//                            iPhoneXSeries = true
//                        }
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }
//
//            }
//
////            screenSize = UIScreen.main.bounds.size
//
//            if let version = Float(UIDevice.current.systemVersion) {
//                systemVersion = version
//            } else {
//                systemVersion = 10.0
//            }
//        }
//
//    }
//}



/*
    方法交换
 */
protocol FunSwizz: class {
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





