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

protocol FunWeakProxyProtocol: NSObjectProtocol {
    func targetDidRelease()
}
extension FunWeakProxyProtocol {
    func targetDidRelease() {}
}

public class FunWeakProxy: NSObject {
    
    var target: NSObjectProtocol?
    
    var sel: Selector?

//    public weak var linker: CADisplayLink?
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
}

extension FunBox {
    public class FPS: NSObject {

        private var count: Int = 0
        private var lastTime: TimeInterval = 0
        private var isShow: Bool = false
        private var font: UIFont?
        private var subFont: UIFont?
        private var frame: CGRect = CGRect.init(x: UIScreen.main.bounds.size.width - 68, y: UIScreen.main.bounds.size.height - 84, width: 60, height: 24)
        private var targetView: UIView?

        
        private lazy var fpsLabel: UILabel = {
            font = UIFont.init(name: "Menlo", size: 14)
            if font != nil {
                subFont = UIFont.init(name: "Menlo", size: 4)
            } else {
                font = UIFont.init(name: "Courier", size: 14)
                subFont = UIFont.init(name: "Courier", size: 4)
            }
            
            let _fpsLabel = UILabel.init(frame: frame)
            _fpsLabel.textColor = .white
            _fpsLabel.layer.cornerRadius = 5
            _fpsLabel.layer.masksToBounds = true
            _fpsLabel.textAlignment = .center
            _fpsLabel.isUserInteractionEnabled = false
            _fpsLabel.backgroundColor = UIColor.init(white: 0.0, alpha: 0.7)
            _fpsLabel.font = UIFont.systemFont(ofSize: 17)
            return _fpsLabel
        }()
        
        public static var `default`: FPS {
            
            return Static.instance
        }
        
        private struct Static {
            static let instance = FPS()
        }
        
        public func set(frame: CGRect) -> Self {
            self.frame = frame
            
            return self
        }
        
        public func show(inView: UIView? = nil) {
            
            isShow = true
            
            targetView = inView ?? UIApplication.shared.keyWindow
            
            targetView?.addSubview(fpsLabel)
            
            start()
        }
        
        private func start() {
            
            let link = CADisplayLink.weak_linker(target: self, selector: #selector(tick(linker:)))
            link.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        }
        
        @objc private func tick(linker: CADisplayLink) {
            
            if lastTime == 0 {
                lastTime = linker.timestamp
                
                return
            }
            
            count = count + 1
            
            let delta = linker.timestamp - lastTime

            if delta < 1.0 {
                return
            }
            
            lastTime = linker.timestamp
            let fps = Double(count) / delta
            count = 0
            
            let progress = fps / 60.0
            let fpsText = "\(Int(round(fps))) FPS"
            
            if isShow {
                
                let color = UIColor.init(hue: CGFloat(0.27 * (progress - 0.2)), saturation: 1.0, brightness: 0.9, alpha: 1.0)
                let text = NSMutableAttributedString.init(string: fpsText)
                text.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange.init(location: 0, length: text.length - 3))
                text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange.init(location: text.length - 3, length: 3))
                text.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange.init(location: 0, length: text.length))
                text.addAttribute(NSAttributedString.Key.font, value: subFont!, range: NSRange.init(location: text.length - 4, length: 1))
                self.fpsLabel.attributedText = text
                self.targetView?.bringSubviewToFront(self.fpsLabel)

            } else {
                print(fpsText)
            }
            
            
        }
    }
}


