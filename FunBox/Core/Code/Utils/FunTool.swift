//
//  FunTool.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/22.
//

import Foundation

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

        private var keyboardHandler: (((isShow: Bool, rect: CGRect))->Void)?
        public func keyboardShow(_ handler: (((isShow: Bool, rect: CGRect))->Void)?) {
            keyboardHandler = handler
        }
        
        private var keyboardWillShowHandler: (((isShow: Bool, duration: Double, rect: CGRect))->Void)?
        public func keyboardWillShow(_ handler: (((isShow: Bool, duration: Double, rect: CGRect))->Void)?) {
            keyboardWillShowHandler = handler
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
            
            if let handler = self.keyboardWillShowHandler {
                handler((isShow,duration,keyboardRect))
            }
            
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

extension FunBox.Refresher {
    struct Config {
        static var timeOut: TimeInterval = 15
    }
}



