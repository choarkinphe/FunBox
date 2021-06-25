//
//  CKNavigationBar.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/8.
//

import UIKit
import FunBox
import FunModules


public protocol CKNavigatorItem {
    var realView: UIView? {get}
}

extension UIView: CKNavigatorItem {
    public var realView: UIView? {return self}
}
extension UIBarButtonItem: CKNavigatorItem {
    public var realView: UIView? {return self.customView}
}

public protocol CKNavigator {
    var leftItem: CKNavigatorItem? { get }
    var rightItem: CKNavigatorItem? { get }
    func set(leftItem: CKNavigatorItem)
    func set(rightItem: CKNavigatorItem)
    var clipBar: CKNavigationBar.ClipBar? { get }
}

extension CKNavigator {
    public var clipBar: FunNavigationBar.ClipBar? {
        return rightItem as? FunNavigationBar.ClipBar
    }
}

extension UINavigationItem: CKNavigator {
    public var leftItem: CKNavigatorItem? {
        return leftBarButtonItem
    }
    public func set(leftItem: CKNavigatorItem) {
        if let newValue = leftItem as? UIView {
            fb.set(leftItem: newValue)
        } else if let newValue = leftItem as? UIBarButtonItem {
            rightBarButtonItem = newValue
        }
    }
    
    public var rightItem: CKNavigatorItem? {
        
        return rightBarButtonItem
        
    }
    public func set(rightItem: CKNavigatorItem) {
        if let newValue = rightItem as? UIView {
            fb.set(rightItem: newValue)
        } else if let newValue = rightItem as? UIBarButtonItem {
            rightBarButtonItem = newValue
        }
    }
    
    
    
}

extension CKNavigationBar: CKNavigator {
    
    public var leftItem: CKNavigatorItem? {
        
        return leftView
        
    }
    public func set(leftItem: CKNavigatorItem) {
        leftView = leftItem.realView
    }
    
    
    public var rightItem: CKNavigatorItem? {
        
        return rightView
        
    }
    public func set(rightItem: CKNavigatorItem) {
        rightView = rightItem.realView
    }
    
}

open class CKNavigationBar: FunNavigationBar {

    public override init(template: FunNavigationBar.Template = .default, frame: CGRect = .zero) {
        super.init(template: template, frame: frame)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var flag: Bool = false
    // dynomic lock
    public var lock: Bool = false
    public func set(hidden: Bool, animated: Bool?=true) {
        if lock { return }
        if flag == hidden { return }
        flag = hidden

        UIView.animate(withDuration: animated ?? true ? 0.25 : 0.0, animations: {
              self.leftView?.alpha = hidden ? 0 : 1
                self.titleView?.alpha = hidden ? 0 : 1
                self.rightView?.alpha = hidden ? 0 : 1
                //                }
                
                if hidden {
                    self.frame = CGRect(x: 0, y: 0, width: CKScreen.width, height: UIDevice.current.fb.isInfinity ? 44 : 20)
                } else {
                    self.frame = CGRect(x: 0, y: 0, width: CKScreen.width, height: UIDevice.current.fb.isInfinity ? 88 : 64)
                }
            })
        
        }
        
    }
    
private var navigationBarKey = "com.hccontroller.navigationbar"
public extension CKNamespaceWrapper where T : UIViewController {
    var navigationBar: CKNavigationBar? {
        get {
            
            return wrappedValue.fb.navigationBar as? CKNavigationBar
        }
        set {
            wrappedValue.fb.navigationBar = newValue
        }
    }
    
    func set(navigationBar: CKNavigationBar) {
        objc_setAssociatedObject(wrappedValue, &navigationBarKey, navigationBar, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}
