//
//  UIViewController+CKAdd.swift
//  SelfService
//
//  Created by Choarkinphe on 2019/6/28.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import UIKit
private var funControllerKey = "funControllerKey"
extension UIViewController: FunSwizz {
    
    fileprivate static func swizzleMethod() {
        DispatchQueue.fb.once {

            swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidLoad), swizzledSelector: #selector(swizzled_viewDidLoad))
            swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidAppear(_:)), swizzledSelector: #selector(swizzled_viewDidAppear(animated:)))
            swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidDisappear(_:)), swizzledSelector: #selector(swizzled_viewDidDisappear(animated:)))
            swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidLayoutSubviews), swizzledSelector: #selector(swizzled_viewDidLayoutSubviews))
        }
    }
    

    @objc func swizzled_viewDidLoad() {
        swizzled_viewDidLoad()
        
        
    }
    
    
    @objc func swizzled_viewDidAppear(animated: Bool) {
        swizzled_viewDidAppear(animated: animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
    
    
    @objc func swizzled_viewDidDisappear(animated: Bool) {
        swizzled_viewDidDisappear(animated: animated)
        
        
    }
    
    @objc func swizzled_viewDidLayoutSubviews() {
        swizzled_viewDidLayoutSubviews()
        
        guard let contentView = fb.contentView else { return }
        
        var rect = view.bounds
        
//        let content_x: CGFloat = 0.0
//        var content_y: CGFloat = 0.0
//        let content_w: CGFloat = view.frame.size.width
//        var content_h: CGFloat = view.frame.size.height
        
        if let navigationController = navigationController {
            /*
             None     不做任何扩展,如果有navigationBar和tabBar时,self.view显示区域在二者之间
             Top      扩展顶部,self.view显示区域是从navigationBar顶部计算面开始计算一直到屏幕tabBar上部
             Left     扩展左边,上下都不扩展,显示区域和UIRectEdgeNone是一样的
             Bottom   扩展底部,self.view显示区域是从navigationBar底部到tabBar底部
             Right    扩展右边,上下都不扩展,显示区域和UIRectEdgeNone是一样的
             All      上下左右都扩展,及暂满全屏,是默认选项
             */
            
            // edgesForExtendedLayout == UIRectEdgeNone || UIRectEdgeBottom时，view本身就是从navigationBar的下面开始计算坐标的
            // 导航栏半透明的时候，才需要把contentView向下偏移
            if !navigationController.isNavigationBarHidden && edgesForExtendedLayout.rawValue != 0 && edgesForExtendedLayout != .bottom && navigationController.navigationBar.isTranslucent {
                // 系统导航栏未隐藏，从导航栏地步开始计算坐标
//                content_y = navigationController.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height;
                rect.origin.y = navigationController.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height;
                
            }
        }
        
        if let tabBarController = tabBarController {
            if (tabBarController.tabBar.isHidden && tabBarController.tabBar.isTranslucent) {
                // tabBar没有隐藏，且tabBar是半透明状态
//                content_h = content_h - tabBarController.tabBar.frame.size.height;
                rect.size.height = rect.size.height - tabBarController.tabBar.frame.size.height
            }
        }
        
        // 获取当前可用的content高度
//        content_h = content_h - content_y;
        rect.size.height = rect.size.height - rect.origin.y;
        
        if let navigationBar = fb.navigationBar {
            if !navigationBar.isHidden {
                navigationBar.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: navigationBar.bounds.size.height)
//                content_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
//                content_h = content_h - navigationBar.frame.size.height
                rect.origin.y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                rect.size.height = rect.size.height - navigationBar.frame.size.height
            }
        }
        
        if let topView = fb.topView {
            if !topView.isHidden {
                if let navigationBar = fb.navigationBar, navigationBar.isHidden {
//                    content_y = self.fb.safeAeraInsets.top
                    rect.origin.y = self.fb.safeAeraInsets.top
                }
                
                // 利用上面改过的content_y（content顶部的实际可布局位置）
//                topView.frame = CGRect.init(x: 0, y: content_y, width: view.frame.size.width, height: topView.bounds.size.height)
                topView.frame = CGRect.init(x: 0, y: rect.origin.y, width: view.frame.size.width, height: topView.bounds.size.height)
                // 再次调整contentView的位置
//                content_y = topView.frame.origin.y + topView.frame.size.height
//                content_h = content_h - topView.frame.size.height
                rect.origin.y = topView.frame.origin.y + topView.frame.size.height
                rect.size.height = rect.size.height - topView.frame.size.height
            }
            
        }
        
        if let bottomView = fb.bottomView {
            if !bottomView.isHidden {
                
//                content_h = content_h - bottomView.frame.size.height - fb.safeAeraInsets.bottom;
//
//                bottomView.frame = CGRect.init(x: 0, y: content_h + content_y, width: view.frame.size.width, height: bottomView.frame.size.height)
                
                rect.size.height = rect.size.height - bottomView.frame.size.height - fb.safeAeraInsets.bottom;
                
                bottomView.frame = CGRect.init(x: 0, y: rect.size.height + rect.origin.y, width: view.frame.size.width, height: bottomView.frame.size.height)
            }
        }
        
//        contentView.frame = CGRect.init(x: content_x, y: content_y, width: content_w, height: content_h)
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
    class FunController {

        lazy var observations: [NSKeyValueObservation] = {
            let observations = [NSKeyValueObservation]()
            
            return observations
        }()
        private weak var viewController: UIViewController?
        
        init(target: UIViewController?) {
            UIViewController.swizzleMethod()
            if let target = target {
                viewController = target
            }
        }
        
        public var safeAeraInsets: UIEdgeInsets {
            var safeAeraInsets = UIEdgeInsets.zero
            if FunBox.device.fb.iPhoneXSeries {
                safeAeraInsets.top = 24
                
//                if viewController?.hidesBottomBarWhenPushed == true || viewController?.parent?.hidesBottomBarWhenPushed == true {
//                    safeAeraInsets.bottom = 34
//                }
                
                if viewController?.tabBarController?.tabBar.isHidden != true {
                    safeAeraInsets.bottom = 34
                }
            }
            return safeAeraInsets
        }
        
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
                    navigationBar.frame = CGRect.init(x: 0, y: 0, width: viewController.view.frame.size.width, height: navigationBar.bounds.size.height)
                    viewController.view.addSubview(navigationBar)
                    // 监听hidden，方便后面调整frame
                    observations.append(navigationBar.observe(\UIView.isHidden) { (_, change) in
                        viewController.view.setNeedsLayout()
                        
                    })
                    
                }
            }
        }
        
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
                    // 有navigationBar时，调整topView的frame
                    if let navigationBar = navigationBar {
                        topView_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                    }
                    topView.frame = CGRect.init(x: 0.0, y: topView_y, width: viewController.view.frame.size.width, height: topView.bounds.size.height)
                    viewController.view.addSubview(topView)
                    // 监听hidden，方便后面调整frame
                    
                    observations.append(topView.observe(\UIView.isHidden) { (_, change) in
                        viewController.view.setNeedsLayout()
                        
                    })
                    
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
        
        // 原理与topView相同
        public var bottomView: UIView? {
            willSet {
                if bottomView == newValue {
                    
                    return
                }
                
                if let bottomView = bottomView, let viewController = viewController {
                    
                    bottomView.frame = CGRect.init(x: 0, y: viewController.view.frame.size.height, width: viewController.view.frame.size.width, height: bottomView.frame.size.height)
                    bottomView.removeFromSuperview()
                    
                }
                
            }
            
            didSet {
                if let bottomView = bottomView, let viewController = viewController {
                    
                    bottomView.frame = CGRect.init(x: 0, y: viewController.view.frame.size.height - bottomView.frame.size.height - safeAeraInsets.bottom, width: viewController.view.frame.size.width, height: bottomView.frame.size.height)
                    
                    viewController.view.addSubview(bottomView)

                    observations.append(bottomView.observe(\UIView.isHidden) { (_, change) in
                        viewController.view.setNeedsLayout()
                        
                    })
                    
                }
            }
        }
        
        public func setTopViewHidden(_ hidden: Bool, animated: Bool) {
            guard let topView = topView, let viewController = viewController else { return }
            if !hidden { topView.isHidden = hidden }
            UIView.animate(withDuration: animated ? 0.35 : 0, animations: {

                var topView_y: CGFloat = 0.0
                if hidden {
                    topView_y = -topView.bounds.size.height
                    // 有navigationBar时，调整topView的frame
                    if let navigationBar = self.navigationBar {
                        topView_y = navigationBar.frame.maxY - topView.bounds.size.height
                    }
                } else {
                    // 有navigationBar时，调整topView的frame
                    if let navigationBar = self.navigationBar {
                        topView_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                    }

                }
                topView.frame = CGRect.init(x: 0.0, y: topView_y, width: viewController.view.frame.size.width, height: topView.bounds.size.height)
            }) { (complete) in
                topView.isHidden = hidden
            }
        }
        
        public func setBottomViewHidden(_ hidden: Bool, animated: Bool) {
            guard let bottomView = bottomView, let viewController = viewController else { return }
            if !hidden { bottomView.isHidden = hidden }
            UIView.animate(withDuration: animated ? 0.35 : 0, animations: {
                if hidden {
                    bottomView.frame = CGRect.init(x: 0, y: viewController.view.frame.size.height, width: viewController.view.frame.size.width, height: bottomView.frame.size.height)
                } else {
                    bottomView.frame = CGRect.init(x: 0, y: viewController.view.frame.size.height - bottomView.frame.size.height - self.safeAeraInsets.bottom, width: viewController.view.frame.size.width, height: bottomView.frame.size.height)
                }
            }) { (complete) in
                bottomView.isHidden = hidden
            }
            
        }
        
        fileprivate func resetBackgrounerColor() {
            if let viewController = viewController {
                var fromColor = UIColor.white
                var toColor = UIColor.white
                
                if let topColor = topView?.backgroundColor {
                    fromColor = topColor
                }
                
                if let bottomColor = bottomView?.backgroundColor {
                    toColor = bottomColor
                }
                //CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = viewController.view.bounds
                
                //  创建渐变色数组，需要转换为CGColor颜色
                gradientLayer.colors = [fromColor.cgColor,toColor.cgColor]
                
                //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
                gradientLayer.startPoint = CGPoint.init(x: 1, y: 0)
                gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
                
                // 确定渐变的起点和终点
                let topPosition = Double(safeAeraInsets.top / viewController.view.frame.size.height)
                let bottomPosition = Double(1.0 - safeAeraInsets.bottom / viewController.view.frame.size.height)
                
                //  设置颜色变化点，取值范围 0.0~1.0
                gradientLayer.locations = [NSNumber(floatLiteral: topPosition),NSNumber(floatLiteral: bottomPosition)]
                
                // 将渐变色图层压倒最下
                viewController.view.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
        

        private var visableController: UIViewController?
        
        public func change2Child(_ childVC: UIViewController?, options: UIView.AnimationOptions?=nil) {
                guard let childVC = childVC else { return }
                guard let viewController = viewController else { return }
                if !viewController.children.contains(childVC) {
                    viewController.addChild(childVC)
                }

//                var current = viewController.children.first
//                for item in viewController.children {
//                    if viewController.view.subviews.contains(item.view) {
//                        current = item
//                    }
//                }
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
        
        
        deinit {
            debugPrint("funController die")
            
            bottomView = nil
            contentView = nil
            topView = nil
        }
    }
    
    
}


