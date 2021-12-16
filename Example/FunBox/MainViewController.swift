//
//  MainViewController.swift
//  FunBox_Example
//
//  Created by 肖华 on 2021/12/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController

class MainViewController: RAMAnimatedTabBarController {
    
    override func viewDidLoad() {
        commitInitView()
        addAllChildsControllors();
        super.viewDidLoad()
        delegate = self
//        var tabs = [NavigationController]()
//        for i in 0...3 {
//            let nav = NavigationController(rootViewController: WorkViewController())
//            tabs.append(nav)
//        }
//
//        setViewControllers(tabs, animated: true)
    }
    
    
    func addAllChildsControllors() {
        ///首页
        addOneChildVC(childVC:WorkViewController(), title:"首页", imageName: "home")
        ///淳豆
        addOneChildVC(childVC:WorkViewController(), title:"工作台", imageName: "work")
        ///购物车
        addOneChildVC(childVC:WorkViewController(), title:"浏览器", imageName: "explore")
        //我的
        addOneChildVC(childVC:WorkViewController(), title:"我", imageName: "myup")
    }
    
    func addOneChildVC(childVC: UIViewController, title: String, imageName: String) {
        let navVC = NavigationController(rootViewController: childVC)
        let item = RAMAnimatedTabBarItem(title: title, image: UIImage(named:"ic_tabbar_\(imageName)_normal"), selectedImage: UIImage(named:"ic_tabbar_\(imageName)_select"))
        //  你这个选择这其中的一个RAMFumeAnimation, RAMBounceAnimation, RAMRotationAnimation, RAMFrameItemAnimation, RAMTransitionAnimation
       // 你也可以为你的每一个item加载不同的动画，可以根据自己需求添加
        let animation = RAMBounceAnimation()
        item.animation = animation
        //  这里需要先把导航控制器，加入tabbar控制器上，然后添加item，这个顺序错了，也是没有动画效果的。
//        addChildViewController(navVC);
        addChild(navVC)
        navVC.tabBarItem = item
//        item.imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func commitInitView() {
        view.backgroundColor = UIColor.white
        tabBar.isTranslucent = false
//        tabBar.tintColor = UIColor(hex: "1296db")
        tabBar.barTintColor = .white
    }
    
}

extension MainViewController: UITabBarControllerDelegate {
    
}
