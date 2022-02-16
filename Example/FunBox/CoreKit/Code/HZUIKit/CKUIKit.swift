//
//  HZUIKit.swift
//  HZCommon
//
//  Created by choarkinphe on 2020/8/11.
//  Copyright © 2020 hongzheng. All rights reserved.
//

import UIKit

// 初始化（初始化才能加载HZView的特性）
public typealias CKView = CKUIKit
public class CKUIKit: CKModuleProtocol {
    
    public static func install() {
        UITableViewCell.ck.swizzle()
        UITableView.ck.swizzle()
        UIViewController.ck.swizzle()
        UINavigationController.ck.swizzle()
    }
    
}

public typealias CKScreen = CKUIKit.Screen
extension CKUIKit {
    public struct Screen {
        // 屏幕宽
        public static let width: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        // 屏幕高
        public static let height: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        // 标准尺寸比
        public static let scale: CGFloat = Screen.width / 375.0
        // 宽高比
        public static let ratio: CGFloat = Screen.width / Screen.height
        // 是否全面屏
        public static let isInfinity: Bool = UIDevice.current.fb.isInfinity
        
        public static let navigationBarHeight: CGFloat = CKScreen.isInfinity ? 88.0 : 64.0
    }
}

// MARK: - HZUIKitProtocol
public protocol CKBaseStyle {
    var fillColor: UIColor { get }
}

extension CKBaseStyle {
    public var fillColor: UIColor {
        return Theme.Color.systemBackground
    }
}

/*
 UITableView
 */
public protocol CKTableView: CKBaseStyle {}

extension CKTableView {
    
    public var fillColor: UIColor {
        return Theme.Color.lightBackground
    }
    
}
extension UITableView: Swizz {
    
    @objc fileprivate func hz_didMoveToSuperview() {
        hz_didMoveToSuperview()
        
        if let style = self as? CKTableView {
            
            separatorStyle = .none
            if tableHeaderView == nil {
                tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: CKScreen.width, height: 0.01))
            }
            if backgroundColor == nil {
                backgroundColor = style.fillColor
            }
            
            if estimatedRowHeight == 0 {
                estimatedRowHeight = 88
            }
            
        }
        
    }
    
}

/*
 UITableViewCell
 */
public protocol CKTableViewCell: CKBaseStyle {}

extension CKTableViewCell {
    
    public var fillColor: UIColor {
        return Theme.Color.systemBackground
    }
}
extension UITableViewCell: Swizz {
    
    @objc fileprivate func hz_didMoveToSuperview() {
        hz_didMoveToSuperview()
        if let style = self as? CKTableViewCell {
            if backgroundColor == nil {
                
                contentView.backgroundColor = style.fillColor
                
            }
            
            selectionStyle = .none
        }
        
    }
    
}

/*
 UIViewController
 */
// 业务控制器协议
public protocol Controller: CKBaseStyle {

    func initNavigator(navigator: CKNavigator)

    func navigationStyle() -> UIViewController.NavigationStyle

}

extension Controller {
    public func navigationStyle() -> UIViewController.NavigationStyle {
        return .system
    }
    
    public func initNavigator(navigator: CKNavigator) {}
}
public protocol HZController: Controller {
    
    func initNavigationBar(navigationBar: CKNavigationBar)

}

public protocol HZContainer: HZNavigationController {}

public protocol HZNavigationController: AnyObject {}

// 协议的默认实现
extension HZController {
//
//    public func initNavigationBar(navigationBar: CKNavigationBar) {}
    
    public func navigationStyle() -> UIViewController.NavigationStyle {
        return .custom
    }
    
//    public func initNavigator(navigator: HZNavigator) {}

}
/*
 UINavigationController
 */
extension UINavigationController {
    
    private func buildNavigationBar( viewController: UIViewController) -> CKNavigationBar? {
        if self is HZNavigationController {
            return CKNavigationBar(template: .default)
        } else if let controller = viewController as? HZController, controller.navigationStyle() != .system {
            return CKNavigationBar(template: .default)
        }
        return nil
        
    }
    
    @objc fileprivate func hz_pushViewController(_ viewController: UIViewController, animated: Bool) {
        hz_pushViewController(viewController, animated: animated)
        
        if self is HZContainer {
            setNavigationBarHidden(false, animated: false)
            viewController.navigationItem.set(rightItem: CKNavigationBar.ClipBar(frame: CGRect(x: 0, y: 0, width: 81, height: 30)))
//            viewController.navigationItem.rightItem =
            navigationBar.tintColor = UIColor(white: 0.35, alpha: 1)

        } else if let navigationBar = buildNavigationBar(viewController: viewController) {
            // 使用了自定义导航栏，隐藏掉系统导航栏
            setNavigationBarHidden(true, animated: false)
            
            if let controller = viewController as? HZController, controller.navigationStyle() != .system {
                navigationBar.backItem.isHidden = viewControllers.count <= 1
                
                viewController.fb.navigationBar = navigationBar
                
                controller.initNavigationBar(navigationBar: navigationBar)

            }
            
        } else {
            setNavigationBarHidden(false, animated: false)
        }
        
        if let controller = viewController as? Controller {
            controller.initNavigator(navigator: ck.navigationBar ?? viewController.navigationItem)
        }
        
    }
    
    @objc fileprivate func hz_popViewController(animated: Bool) -> UIViewController? {
        let viewController = hz_popViewController(animated: animated)
        if self is HZContainer {
            setNavigationBarHidden(false, animated: false)
        } else if self is HZNavigationController {
            setNavigationBarHidden(true, animated: false)
        } else {
            if let viewController = visibleViewController as? HZController,
               viewController.navigationStyle() != .system {
                // 使用了自定义导航栏，隐藏掉系统导航栏
                
                setNavigationBarHidden(true, animated: false)
                
            } else {
                setNavigationBarHidden(false, animated: false)
            }
        }

        return viewController
    }
    
    @objc fileprivate func hz_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let viewControllers = hz_popToViewController(viewController, animated: animated)
        if self is HZContainer {
            setNavigationBarHidden(false, animated: false)
        } else if self is HZNavigationController {
            setNavigationBarHidden(true, animated: false)
        } else {
            if let viewController = visibleViewController as? HZController,
               viewController.navigationStyle() != .system {
                // 使用了自定义导航栏，隐藏掉系统导航栏
                
                setNavigationBarHidden(true, animated: false)
                
            } else {
                setNavigationBarHidden(false, animated: false)
            }
        }
        
        return viewControllers
    }
    
    @objc fileprivate func hz_popToRootViewController(animated: Bool) -> [UIViewController]? {
        let viewController = hz_popToRootViewController(animated: animated)
        if self is HZContainer {
            setNavigationBarHidden(false, animated: false)
        } else if self is HZNavigationController {
            setNavigationBarHidden(true, animated: false)
        } else {
            if let viewController = visibleViewController as? HZController, viewController.navigationStyle() != .system {
                // 使用了自定义导航栏，隐藏掉系统导航栏
                
                setNavigationBarHidden(true, animated: false)
                
            } else {
                setNavigationBarHidden(false, animated: false)
            }
        }
        return viewController
    }
    

    
}

extension UIViewController: Swizz {
    
    public enum NavigationStyle {
        case none
        case system
        case custom
    }
    
    @objc fileprivate func hz_viewDidLoad() {
        hz_viewDidLoad()
        
        if let vc = self as? HZController {
            view.backgroundColor = vc.fillColor

        }

    }
    
    @objc fileprivate func hz_viewWillAppear(_ animated: Bool) {
        hz_viewWillAppear(animated)
        if self.navigationController is HZContainer {
            navigationController?.setNavigationBarHidden(false, animated: false)
        } else if self.navigationController is HZNavigationController {
            // 使用了自定义导航栏，隐藏掉系统导航栏
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else if let viewController = self as? HZController, viewController.navigationStyle() != .system {
            // 使用了自定义导航栏，隐藏掉系统导航栏
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

    }
    
    @objc fileprivate func hz_viewDidAppear(_ animated: Bool) {
        hz_viewDidAppear(animated)
        
        
    }
    
    @objc fileprivate func hz_viewWillDisappear(_ animated: Bool) {
        hz_viewWillDisappear(animated)
        
        
    }
    
    @objc fileprivate func hz_viewDidDisappear(_ animated: Bool) {
        hz_viewDidDisappear(animated)
        
        
    }
    
    @objc fileprivate func hz_viewDidLayoutSubviews() {
        hz_viewDidLayoutSubviews()
        
        if let viewController = self as? HZController, viewController.navigationStyle() != .system {

            if let navigationBar = ck.navigationBar {
                fb.contentInsets = UIEdgeInsets(top: navigationBar.frame.height, left: 0, bottom: 0, right: 0)
            }
            
        }
    }
    
    
}


open class HZContainerController: UINavigationController, HZContainer {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .overFullScreen
        
    }
}

/*
 swizz
 */
extension CKNamespaceWrapper where T : UITableView {
    static func swizzle() {
        DispatchQueue.fb.once {
            UITableView.swizz(UITableView.self, originalSelector: #selector(UITableView.didMoveToSuperview), swizzledSelector: #selector(UITableView.hz_didMoveToSuperview))
        }
    }
}

extension CKNamespaceWrapper where T : UITableViewCell {
    static func swizzle() {
        DispatchQueue.fb.once {
            UITableViewCell.swizz(UITableViewCell.self, originalSelector: #selector(UITableViewCell.didMoveToSuperview), swizzledSelector: #selector(UITableViewCell.hz_didMoveToSuperview))
        }
    }
}

extension CKNamespaceWrapper where T : UIViewController {
    
    static func swizzle() {
        DispatchQueue.fb.once {
            UIViewController.swizz(UIViewController.self, originalSelector: #selector(UIViewController.viewDidLoad), swizzledSelector: #selector(UIViewController.hz_viewDidLoad))
            UIViewController.swizz(UIViewController.self, originalSelector: #selector(UIViewController.viewWillAppear(_:)), swizzledSelector: #selector(UIViewController.hz_viewWillAppear(_:)))
            UIViewController.swizz(UIViewController.self, originalSelector: #selector(UIViewController.viewDidAppear(_:)), swizzledSelector: #selector(UIViewController.hz_viewDidAppear(_:)))
            UIViewController.swizz(UIViewController.self, originalSelector: #selector(UIViewController.viewWillDisappear(_:)), swizzledSelector: #selector(UIViewController.hz_viewWillDisappear(_:)))
            UIViewController.swizz(UIViewController.self, originalSelector: #selector(UIViewController.viewDidDisappear(_:)), swizzledSelector: #selector(UIViewController.hz_viewDidDisappear(_:)))
            UIViewController.swizz(UIViewController.self, originalSelector: #selector(UIViewController.viewDidLayoutSubviews), swizzledSelector: #selector(UIViewController.hz_viewDidLayoutSubviews))
        }
    }
}

extension CKNamespaceWrapper where T : UINavigationController {
    
    static func swizzle() {
        DispatchQueue.fb.once {
            UINavigationController.swizz(UINavigationController.self, originalSelector: #selector(UINavigationController.pushViewController(_:animated:)), swizzledSelector: #selector(UINavigationController.hz_pushViewController(_:animated:)))
            UINavigationController.swizz(UINavigationController.self, originalSelector: #selector(UINavigationController.popViewController(animated:)), swizzledSelector: #selector(UINavigationController.hz_popViewController(animated:)))
            UINavigationController.swizz(UINavigationController.self, originalSelector: #selector(UINavigationController.popToViewController(_:animated:)), swizzledSelector: #selector(UINavigationController.hz_popToViewController(_:animated:)))
            UINavigationController.swizz(UINavigationController.self, originalSelector: #selector(UINavigationController.popToRootViewController(animated:)), swizzledSelector: #selector(UINavigationController.hz_popToRootViewController(animated:)))
        }
    }
}

fileprivate protocol Swizz: AnyObject {
    static func swizz(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector)
}

fileprivate extension Swizz {
    
    static func swizz(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
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

