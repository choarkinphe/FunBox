//
//  FunTool.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/22.
//

import UIKit
import Photos

// MARK: - Observer
public extension FunBox {
    
    static var observer: Observer {
        return Observer.Static.instance
    }
    class Observer: NSObject {
        fileprivate struct Static {
            
            static var instance: Observer = Observer()
        }
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

        public var keyboardShow: Bool = false
        
        private var keyboardHandler: (((isShow: Bool, rect: CGRect))->Void)?
        public func keyboardShow(_ handler: (((isShow: Bool, rect: CGRect))->Void)?) {
            keyboardHandler = handler
        }
        
        private var keyboardWillShowHandler: (((isShow: Bool, duration: Double, rect: CGRect))->Void)?
        public func keyboardWillShow(_ handler: (((isShow: Bool, duration: Double, rect: CGRect))->Void)?) {
            keyboardWillShowHandler = handler
        }
        
        @objc fileprivate func keyboardWillShow(notification: Notification) {
            keyboardShow = true
            keyboardChanged(notification: notification)
        }
        
        @objc fileprivate func keyboardWillHidden(notification: Notification) {
            keyboardShow = false
            keyboardChanged(notification: notification)
        }
        
        private func keyboardChanged(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                
            //获取动画执行的时间(没有的话默认0.25s)
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
            
            if let handler = self.keyboardWillShowHandler {
                handler((keyboardShow,duration,keyboardRect))
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: .allowAnimatedContent, animations: {
                if let handler = self.keyboardHandler {
                    handler((self.keyboardShow,keyboardRect))
                }
            }) { (complete) in
                
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

public extension FunNamespaceWrapper where T: NSObject {
    
    var observer: FunBox.Observer {
        if let observer = objc_getAssociatedObject(wrappedValue, &FunKey.observer) as? FunBox.Observer {
            return observer
        }
        
        let observer = FunBox.Observer()
        
        objc_setAssociatedObject(wrappedValue, &FunKey.observer, observer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return observer
    }
}

// MARK: - Refresher
extension FunBox {
    public class Refresher: UIRefreshControl {
        private var handler: ((UIRefreshControl)->Void)?
        private var timeOut: TimeInterval = FunBox.Refresher.Config.timeOut
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

public extension FunNamespaceWrapper where T: UIScrollView {
    var refresher: FunBox.Refresher {
        let refresher = FunBox.Refresher()
        wrappedValue.refreshControl = refresher
        return refresher
    }
}

extension FunBox.Refresher {
    struct Config {
        static var timeOut: TimeInterval = 15
    }
}


// MARK: - WeakProxy
protocol FunWeakProxyProtocol: NSObjectProtocol {
    func targetDidRelease()
}
extension FunWeakProxyProtocol {
    func targetDidRelease() {}
}

public class FunWeakProxy: NSObject {
    
    var target: NSObjectProtocol?
    
    var sel: Selector?

    weak var timer: FunWeakProxyProtocol?

    public required init(target: NSObjectProtocol?, sel:Selector?) {
        self.target = target
        self.sel = sel
        super.init()

        guard target?.responds(to: sel) == true else {
            return
        }
   
        let method = class_getInstanceMethod(self.classForCoder, #selector(FunWeakProxy.redirectionMethod))!
        class_replaceMethod(self.classForCoder, sel!, method_getImplementation(method), method_getTypeEncoding(method))
    }
    
    @objc func redirectionMethod () {
        
        if let _target = target {
            _target.perform(sel, with: timer)
        } else {
            timer?.targetDidRelease()
            print("CKWeakProxy: invalidate timer.")
        }
    }
}

extension Timer: FunWeakProxyProtocol {
    
    public class func weak_timer(timeInterval ti: TimeInterval, target aTarget: NSObjectProtocol, selector aSelector: Selector, userInfo aInfo: Any?, repeats yesOrNo: Bool) -> Timer {
        let proxy = FunWeakProxy.init(target: aTarget, sel: aSelector)
        let timer = Timer.scheduledTimer(timeInterval: ti, target: proxy, selector: aSelector, userInfo:aInfo, repeats: yesOrNo)
        proxy.timer = timer
        return timer
    }
    
    func targetDidRelease() {
        invalidate()
    }
}


extension CADisplayLink: FunWeakProxyProtocol {
    
    public class func weak_linker(target aTarget: NSObjectProtocol, selector aSelector: Selector) -> CADisplayLink {
        let proxy = FunWeakProxy.init(target: aTarget, sel: aSelector)
        let linker = CADisplayLink.init(target: proxy, selector: aSelector)
        proxy.timer = linker
        return linker
    }
    
    func targetDidRelease() {
        invalidate()
    }
}




extension FunBox {
    /// Haptic Generator Helper.
    public enum Haptic {
        
        /// Impact style.
        @available(iOS 10.0, *)
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        
        /// Notification style.
        @available(iOS 10.0, *)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        
        /// Selection style.
        case selection
        
        /// Trigger haptic generator.
        public func generate() {
            guard #available(iOS 10, *) else { return }
            
            switch self {
            case .impact(let style):
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
            case .notification(let type):
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(type)
            case .selection:
                let generator = UISelectionFeedbackGenerator()
                generator.prepare()
                generator.selectionChanged()
            }
        }
    }
}
