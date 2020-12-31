//
//  UIViewController+Fun.swift
//  FunBox
//
//  Created by Choarkinphe on 2019/6/28.
//  Copyright © 2019 choarkinphe. All rights reserved.
//

import UIKit
private var funControllerKey = "funControllerKey"
extension UIViewController: FunSwizz {
    
    fileprivate static func swizzleMethod() {
        DispatchQueue.fb.once {
            
            swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidLoad), swizzledSelector: #selector(swizzled_viewDidLoad))
            swizzlingForClass(UIViewController.self, originalSelector: #selector(viewWillAppear(_:)), swizzledSelector: #selector(swizzled_viewWillAppear(animated:)))
            swizzlingForClass(UIViewController.self, originalSelector: #selector(viewWillDisappear(_:)), swizzledSelector: #selector(swizzled_viewWillDisappear(animated:)))
            swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidLayoutSubviews), swizzledSelector: #selector(swizzled_viewDidLayoutSubviews))
        }
    }
    
    
    @objc func swizzled_viewDidLoad() {
        swizzled_viewDidLoad()
        
    }
    
    
    @objc func swizzled_viewWillAppear(animated: Bool) {
        swizzled_viewWillAppear(animated: animated)
        fb.addObservations()
        //        debugPrint("willappear",self)
        if !(navigationController?.interactivePopGestureRecognizer?.delegate is Self) {
            navigationController?.interactivePopGestureRecognizer?.delegate = fb
        }
        
        navigationController?.setNavigationBarHidden(fb.isNavigationBarHidden, animated: false)

    }
    
    
    @objc func swizzled_viewWillDisappear(animated: Bool) {
        swizzled_viewWillDisappear(animated: animated)
        //        debugPrint("willdisappear",self)
        fb.removeObservations()
    }
    
    @objc func swizzled_viewDidLayoutSubviews() {
        swizzled_viewDidLayoutSubviews()
        //        debugPrint("layout",self)
        // 只要在标记需要更新布局时才会更新
        guard fb.isNeedLayout else { return }
        
        var rect = view.bounds
        // 默认偏移出安全区域
        rect.origin.y = fb.safeAeraInsets.top
        
        if edgesForExtendedLayout != .init(rawValue: 0), edgesForExtendedLayout != .top {
            /*
             None     不做任何扩展,如果有navigationBar和tabBar时,self.view显示区域在二者之间
             Top      扩展顶部,self.view显示区域是从navigationBar顶部计算面开始计算一直到屏幕tabBar上部
             Left     扩展左边,上下都不扩展,显示区域和UIRectEdgeNone是一样的
             Bottom   扩展底部,self.view显示区域是从navigationBar底部到tabBar底部
             Right    扩展右边,上下都不扩展,显示区域和UIRectEdgeNone是一样的
             All      上下左右都扩展,及暂满全屏,是默认选项
             */
            // none == 0 ,此时view不需要做特殊处理
            // 只有在view的地步不从tabBar顶部开始计算时，才需要在布局中减去tabBar的高度
            if let tabBarController = tabBarController, !hidesBottomBarWhenPushed {
                if (!tabBarController.tabBar.isHidden && tabBarController.tabBar.isTranslucent) {
                    // tabBar没有隐藏，且tabBar是半透明状态
                    rect.size.height = rect.size.height - tabBarController.tabBar.frame.size.height
                }
            }
            
            // none模式下，短行蓝显示时不用考虑安全区域
//            if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
//                rect.origin.y = 0
//            }
            
        }
        if let navigationController = navigationController, navigationController.isNavigationBarHidden {
            // 导航栏被隐藏时，启用安全区域
            
        }
        
        
        if let navigationBar = fb.navigationBar, !navigationBar.isHidden {
            // 自定义导航栏未隐藏时，设置导航栏frame
            navigationBar.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: navigationBar.bounds.size.height)
            
            view.bringSubviewToFront(navigationBar)
        }
        
        if let topView = fb.topView, !topView.isHidden {
            
            if let navigationBar = fb.navigationBar, !navigationBar.isHidden {
                rect.origin.y = navigationBar.frame.maxY
            }
            
            // 存在fillView时，设置fillView的frame
            if let fillView = fb.topFillView {
                fillView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: rect.origin.y)
            }
            
            // 利用上面改过的content_y（content顶部的实际可布局位置）
            topView.frame = CGRect.init(x: 0, y: rect.origin.y, width: view.frame.size.width, height: topView.bounds.size.height)
            // 再次调整rect的位置
            rect.origin.y = topView.frame.maxY
            
        }
        rect.size.height = rect.size.height - rect.origin.y
        if let bottomView = fb.bottomView, !bottomView.isHidden {
            
            rect.size.height = rect.size.height - bottomView.frame.size.height - fb.safeAeraInsets.bottom
            bottomView.frame = CGRect.init(x: 0, y: rect.maxY, width: view.frame.size.width, height: bottomView.frame.size.height)
            
            // 存在fillView时，设置fillView的frame
            if let fillView = fb.bottomFillView {
                fillView.frame = CGRect(x: 0, y: bottomView.frame.maxY, width: view.frame.size.width, height: fb.safeAeraInsets.bottom)
            }
        }
        
        
        guard let contentView = fb.contentView else { return }
        
        contentView.frame = rect
        
    }
    
    public var fb: FunBox.FunController {
        set {
            
            objc_setAssociatedObject(self, &funControllerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        
        get {
            
            if let observations = objc_getAssociatedObject(self, &funControllerKey) {
                return observations as! FunBox.FunController
            } else {
                objc_setAssociatedObject(self, &funControllerKey, FunBox.FunController(target: self), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return self.fb
        }
    }
    
}


public extension FunBox {
    class FunController: NSObject {
        
        private var observations: [NSKeyValueObservation]
        
        public var contentInsets: UIEdgeInsets = .zero
        
        public var touchDismissKeyboard: Bool = FunBox.manager.config.keyboardAutoDismiss
        
        private weak var viewController: UIViewController?
        
        public var isNavigationBarHidden: Bool = FunBox.manager.config.navigationBarHidden
        
        public private(set) var keyboardShow: Bool = false
        
        public var firstResponder: UIView? {

            return viewController?.view.fb.firstResponder
            
        }

        fileprivate func addObservations() {
            
            observations.removeAll()
            
            if let target = viewController {
                
                // 监听hidden，方便后面调整frame
                observations.append(target.observe(\UIViewController.hidesBottomBarWhenPushed) { (_, change) in
                    target.view.setNeedsLayout()
                })
            }
            
            if let navigationBar = navigationBar {
                observations.append(navigationBar.observe(\UIView.isHidden) { [weak viewController] (_, change) in
                    viewController?.view.setNeedsLayout()
                    
                })
            }
            
            if let topView = topView {
                observations.append(topView.observe(\UIView.isHidden) { [weak viewController] (_, change) in
                    viewController?.view.setNeedsLayout()
                    
                })
                observations.append(topView.observe(\UIView.backgroundColor) { [weak self] (_, change) in
                    //                    viewController?.view.setNeedsLayout()
                    self?.topFillView?.backgroundColor = topView.backgroundColor
                })
            }
            
            if let bottomView = bottomView {
                observations.append(bottomView.observe(\UIView.isHidden) { [weak viewController] (_, change) in
                    viewController?.view.setNeedsLayout()
                    
                })
                observations.append(bottomView.observe(\UIView.backgroundColor) { [weak self] (_, change) in
                    //                    viewController?.view.setNeedsLayout()
                    self?.bottomFillView?.backgroundColor = bottomView.backgroundColor
                })
            }
            
        }
        
        fileprivate func removeObservations() {
            observations.removeAll()
            //            observations = nil
        }
        
        init(target: UIViewController?) {
            UIViewController.swizzleMethod()
            observations = [NSKeyValueObservation]()
            super.init()
            if let target = target {
                viewController = target
                
                
                // 监听hidden，方便后面调整frame
                //                observations?.append(target.observe(\UIViewController.hidesBottomBarWhenPushed) { (_, change) in
                //                    target.view.setNeedsLayout()
                //                })
                
                // 监听键盘弹出
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
                // 监听键盘隐藏
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
                
                
            }
            
        }
        
        public var isNeedLayout = true
        //        public lazy var observer = Observer()
        
        public var safeAeraInsets: UIEdgeInsets {
            var safeAeraInsets = UIEdgeInsets.zero
            guard let viewController = viewController else { return safeAeraInsets }
            if UIDevice.current.fb.isInfinity {
                
                
                
                /*
                 None     不做任何扩展,如果有navigationBar和tabBar时,self.view显示区域在二者之间
                 Top      扩展顶部,self.view显示区域是从navigationBar顶部计算面开始计算一直到屏幕tabBar上部
                 Left     扩展左边,上下都不扩展,显示区域和UIRectEdgeNone是一样的
                 Bottom   扩展底部,self.view显示区域是从navigationBar底部到tabBar底部
                 Right    扩展右边,上下都不扩展,显示区域和UIRectEdgeNone是一样的
                 All      上下左右都扩展,及暂满全屏,是默认选项
                 */
                if viewController.edgesForExtendedLayout != .init(rawValue: 0) {
                    
                    // view不是从navigationBar的底部开始计算，就存在安全区域
                    if viewController.edgesForExtendedLayout != .bottom {
                        safeAeraInsets.top = 24
                    }
                    
                    // 导航栏在显示状态，且导航栏不透明时，忽略安全范围（此时view是从导航栏下半部分开始计算的）
                    if let navigationBar = viewController.navigationController?.navigationBar, !navigationBar.isTranslucent, !navigationBar.isHidden {
                        
                        safeAeraInsets.top = 0
                    }
                    
                    // view不是从tabBar的顶端开始计算时，考虑安全区域
                    if viewController.edgesForExtendedLayout != .top {
                        
                        if let tabBarController = viewController.tabBarController {
                            if tabBarController.tabBar.isHidden { // tabBar隐藏状态加偏移
                                safeAeraInsets.bottom = 34
                            }
                            
                            if viewController.hidesBottomBarWhenPushed || viewController.parent?.hidesBottomBarWhenPushed == true {
                                safeAeraInsets.bottom = 34
                            }
                            
                        } else {
                            
                            safeAeraInsets.bottom = 34
                        }
                    }
                    
                    
                }
                
                
            }
            
            if contentInsets.top != 0 {
                safeAeraInsets.top = contentInsets.top
            }
            if contentInsets.bottom != 0 {
                safeAeraInsets.bottom = contentInsets.bottom
            }
            return safeAeraInsets
        }
        
        public var backgroundView: UIView?
        
        public var navigationBar: UIView? {
            willSet {
                if navigationBar == newValue {
                    // 输入相同对象时直接忽略
                    return
                }
                
                if let navigationBar = navigationBar {
                    // 存在旧对象时，先移除
                    navigationBar.frame = CGRect.init(x: 0, y: -navigationBar.frame.size.height, width: navigationBar.frame.size.width, height: navigationBar.frame.size.height)
                    navigationBar.removeFromSuperview()
                    
                }
            }
            didSet {
                if let navigationBar = navigationBar, let viewController = viewController {
                    //用了自定义的navigationBar就隐藏系统的导航栏
                    viewController.navigationController?.setNavigationBarHidden(true, animated: false)
                    var size = navigationBar.frame.size
                    if size == .zero {
                        size = navigationBar.sizeThatFits(viewController.view.bounds.size)
                    }
                    navigationBar.frame = CGRect.init(x: 0, y: 0, width: viewController.view.frame.size.width, height: size.height)
                    viewController.view.addSubview(navigationBar)
                    
                    addObservations()
                }
            }
        }
        
        fileprivate var topFillView: UIView?
        public var topView: UIView? {
            willSet {
                if topView == newValue {
                    // 输入相同对象时直接忽略
                    return
                }
                
                if let topView = topView {
                    // 存在旧对象时，先移除
                    topView.frame = CGRect.init(x: 0, y: -topView.frame.size.height, width: topView.frame.size.width, height: topView.frame.size.height)
                    topView.removeFromSuperview()
                    
                }
            }
            didSet {
                if let topView = topView, let viewController = viewController {
                    var topView_y: CGFloat = 0.0
                    var size = topView.frame.size
                    if size == .zero {
                        size = topView.sizeThatFits(viewController.view.bounds.size)
                    }
                    // 有navigationBar时，调整topView的frame
                    if let navigationBar = navigationBar {
                        topView_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                    }
                    if safeAeraInsets.top > 0 {
                        let fillView = UIView(frame: CGRect(x: 0, y: topView_y, width: topView.frame.width, height: safeAeraInsets.top))
                        fillView.backgroundColor = topView.backgroundColor
                        topFillView = fillView
                        
                        viewController.view.addSubview(fillView)
                    }
                    topView_y = topView_y + safeAeraInsets.top
                    topView.frame = CGRect.init(x: 0.0, y: topView_y, width: viewController.view.frame.size.width, height: size.height)
                    viewController.view.addSubview(topView)
                    
                    addObservations()
                }
            }
        }
        
        // 原理与topView相同
        public var contentView: UIView? {
            willSet {
                
                if contentView == newValue {
                    
                    return
                }
                
                if let contentView = contentView {
                    
                    contentView.removeFromSuperview()
                    
                }
                
            }
            didSet {
                if let contentView = contentView, let viewController = viewController {
                    
                    contentView.frame = viewController.view.bounds
                    
                    viewController.view.addSubview(contentView)
                    
                }
            }
            
        }
        fileprivate var bottomFillView: UIView?
        // 原理与topView相同
        public var bottomView: UIView? {
            willSet {
                if bottomView == newValue {
                    
                    return
                }
                
                if let bottomView = bottomView, let viewController = viewController {
                    
                    bottomView.frame = CGRect.init(x: 0, y: viewController.view.frame.size.height, width: viewController.view.frame.size.width, height: bottomView.frame.size.height)
                    bottomView.removeFromSuperview()
                    bottomFillView?.removeFromSuperview()
                }
                
            }
            
            didSet {
                if let bottomView = bottomView, let viewController = viewController {
                    var size = bottomView.frame.size
                    if size == .zero {
                        size = bottomView.sizeThatFits(viewController.view.bounds.size)
                    }
                    let bottom_y = viewController.view.frame.height - size.height - safeAeraInsets.bottom
                    bottomView.frame = CGRect.init(x: 0, y: bottom_y, width: viewController.view.frame.size.width, height: bottomView.frame.size.height)
                    
                    viewController.view.addSubview(bottomView)
                    
                    if safeAeraInsets.bottom > 0 {
                        let fillView = UIView(frame: CGRect(x: 0, y: bottomView.frame.maxY, width: bottomView.frame.width, height: safeAeraInsets.bottom))
                        fillView.backgroundColor = bottomView.backgroundColor
                        bottomFillView = fillView
                        
                        viewController.view.addSubview(fillView)
                    }
                    
                    addObservations()
                }
            }
        }
        
        public var visableController: UIViewController?
        
        public func change2Child(_ childVC: UIViewController?, options: UIView.AnimationOptions?=nil) {
            guard let childVC = childVC else { return }
            guard let viewController = viewController else { return }
            if visableController == childVC {
                return
            }
            if !viewController.children.contains(childVC) {
                viewController.addChild(childVC)
            }
            
            if let current = visableController, let options = options {
                viewController.transition(from: current, to: childVC, duration: 0.45, options: options, animations: {
                    
                }) { (finished) in
                    self.visableController = childVC
                }
            } else {
                childVC.beginAppearanceTransition(true, animated: true)
                childVC.view.frame = viewController.view.frame
                viewController.view.addSubview(childVC.view)
                childVC.endAppearanceTransition()
                childVC.didMove(toParent: viewController)
                visableController = childVC
            }
            
        }
        
        fileprivate lazy var dismissPan: FunPan = {
            let pan = FunPan()
//            view.addGestureRecognizer(pan)
            pan.delegate = self
            pan.touchesBegan { [weak self] (touches, event) in

                if let firstResponder = self?.firstResponder,
                   let contentView = self?.viewController?.view,
                   let position = touches.first?.location(in: contentView),
                   let target = contentView.hitTest(position, with: event) {
                    
                    if target is UITextView || target is UITextField {
                        
                    } else if firstResponder != target {
                        firstResponder.endEditing(true)
                    }

                }
            }
            return pan
        }()
        
        @objc fileprivate func keyboardWillShow(notification: Notification) {
            keyboardShow = true
            if touchDismissKeyboard {
                viewController?.view.addGestureRecognizer(dismissPan)
            }
        }
        
        @objc fileprivate func keyboardWillHidden(notification: Notification) {
            keyboardShow = false
            if viewController?.view.gestureRecognizers?.contains(dismissPan) == true {
                viewController?.view.removeGestureRecognizer(dismissPan)
            }
        }
        
        deinit {
            debugPrint("funController die")
            NotificationCenter.default.removeObserver(self)
            navigationBar = nil
            bottomView = nil
            contentView = nil
            topView = nil
        }
    }
    
    
}

extension FunBox.FunController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let navigationController = viewController?.navigationController, gestureRecognizer == navigationController.interactivePopGestureRecognizer {
            
            return navigationController.viewControllers.count > 1
            
        }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer == dismissPan {
            if touch.view is UIControl {
                return false
            } else if touch.view?.gestureRecognizers != nil {
                return false
            }
        }
        
        return true
    }
}
