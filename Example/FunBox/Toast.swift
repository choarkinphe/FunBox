//
//  FunToast.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/22.
//
/*
import UIKit

public extension FunBox {
    class HUD {
        
        fileprivate var config = Config()
        
        public static var `default`: Toast {
            let toast = Toast()
            Manager.shared.isTapToDismissEnabled = true
            return toast
        }
        
        public init() {}
        
        public func title(_ title: String?) -> Self {
            config.title = title
            
            return self
        }
        
        public func message(_ message: String?) -> Self {
            config.message = message
            
            return self
        }
        
        public func inView(_ inView: UIView?) -> Self {
            config.inView = inView
            
            return self
        }
        
        public func duration(_ duration: TimeInterval) -> Self {
            config.duration = duration
            
            return self
        }
        
        public func position(_ position: Position) -> Self {
            config.position = position
            
            return self
        }
        
        public func point(_ point: CGPoint?) -> Self {
            config.point = point
            
            return self
        }
        
        public func image(_ image: UIImage?) -> Self {
            config.image = image
            
            return self
        }
        
        public func style(_ style: Style) -> Self {
            config.style = style
            
            return self
        }
        
        public func isTapToDismissEnabled(_ isTapToDismissEnabled: Bool) -> Self {
            HUD.manager.isTapToDismissEnabled = isTapToDismissEnabled
            
            return self
        }
        
        public static var manager = Manager.shared

        // 活跃的toast
        fileprivate var activeToasts = [UIView]()

        // toast队列
        fileprivate var queue = [Config]()
        
        
    }

}

public extension FunBox.HUD {
    
    
    func showToast() {
        do {
            let toast = try self.config.buildToast()
            
//            var point = config.position.centerPoint(forToast: toast, inSuperview: config.inView)
//            if let a_point = config.point {
//                point = a_point
//            }
//            showToast(toast, duration: config.duration, point: point, completion: config.completion)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Events
    
    @objc private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        guard let toast = recognizer.view else { return }
        hideToast(toast, fromTap: true)
    }
    
    @objc private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        hideToast(toast)
    }
    
    // MARK: - Hide Toast Methods
    
    func hideToast() {
        guard let activeToast = activeToasts.first else { return }
        hideToast(activeToast)
    }
    
    func hideToast(_ toast: UIView) {
        guard activeToasts.contains(toast) else { return }
        hideToast(toast, fromTap: false)
    }
    
    func hideAllToasts(includeActivity: Bool = false, clearQueue: Bool = true) {
        if clearQueue {
            clearToastQueue()
        }
        
//        activeToasts.compactMap { $0 as? UIView }
//            .forEach { hideToast($0) }
//        
//        if includeActivity {
//            hideToastActivity()
//        }
    }
    
    private func hideToast(_ toast: UIView, fromTap: Bool) {
//        if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
//            timer?.invalidate()
//        }
        
        UIView.animate(withDuration: FunBox.Toast.Manager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0.0
        }) { _ in
            toast.removeFromSuperview()
//            self.activeToasts.remove(toast)
            if let index = self.activeToasts.firstIndex(of: toast) {
                self.activeToasts.remove(at: index)
            }
            
//            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
//                completion(fromTap)
//            }
//            
//            if let nextToast = self.queue.firstObject as? UIView, let duration = objc_getAssociatedObject(nextToast, &ToastKeys.duration) as? NSNumber, let point = objc_getAssociatedObject(nextToast, &ToastKeys.point) as? NSValue {
//                self.queue.removeObject(at: 0)
//                self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
//            }
        }
    }
    
    func clearToastQueue() {
        queue.removeAll()
    }
    
    private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
        toast.center = point
        toast.alpha = 0.0
        
        if FunBox.HUD.manager.isTapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        activeToasts.append(toast)
        config.inView?.addSubview(toast)
        
        UIView.animate(withDuration: FunBox.HUD.manager.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            toast.alpha = 1.0
        }) { _ in
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(self.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
//            objc_setAssociatedObject(toast, &ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
}

extension FunBox.HUD.Config {
    mutating func buildToast() throws -> UIView {
        guard let superView = inView else { throw FunError(description: "FunToast: missingSuperView") }
        // sanity
        guard message != nil || title != nil || image != nil else {
            throw FunError(description: "FunToast: missingParameters")
        }

        var messageLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
        
        if let image = image {
            style.verticalPadding = max(style.verticalPadding, 20)
            imageView = UIImageView(image: image)
            imageView?.contentMode = .scaleAspectFit
            imageView?.frame = CGRect(x: style.verticalPadding, y: style.verticalPadding, width: style.imageSize.width, height: style.imageSize.height)
        }
        
        var imageRect = CGRect.zero
        
        if let imageView = imageView {
            imageRect.origin.x = style.verticalPadding
            imageRect.origin.y = style.verticalPadding
            imageRect.size.width = imageView.bounds.size.width
            imageRect.size.height = imageView.bounds.size.height
        }
        
        if let title = title {
            titleLabel = UILabel()
            titleLabel?.numberOfLines = style.titleNumberOfLines
            titleLabel?.font = style.titleFont
            titleLabel?.textAlignment = style.titleAlignment
            titleLabel?.lineBreakMode = .byTruncatingTail
            titleLabel?.textColor = style.titleColor
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.text = title;
            
            let maxTitleSize = CGSize(width: (superView.bounds.size.width * style.maxWidthPercentage), height: superView.bounds.size.height * style.maxHeightPercentage)
            let titleSize = titleLabel?.sizeThatFits(maxTitleSize)
            if let titleSize = titleSize {
                titleLabel?.frame = CGRect(x: 0.0, y: 0.0, width: titleSize.width, height: titleSize.height)
            }
        }
        
        if let message = message {
            messageLabel = UILabel()
            messageLabel?.text = message
            messageLabel?.numberOfLines = style.messageNumberOfLines
            messageLabel?.font = style.messageFont
            messageLabel?.textAlignment = style.messageAlignment
            messageLabel?.lineBreakMode = .byTruncatingTail;
            messageLabel?.textColor = style.messageColor
            messageLabel?.backgroundColor = UIColor.clear
            
            let maxMessageSize = CGSize(width: (superView.bounds.size.width * style.maxWidthPercentage), height: superView.bounds.size.height * style.maxHeightPercentage)
            let messageSize = messageLabel?.sizeThatFits(maxMessageSize)
            if let messageSize = messageSize {
                let actualWidth = min(messageSize.width, maxMessageSize.width)
                let actualHeight = min(messageSize.height, maxMessageSize.height)
                messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
            }
        }
        
        var titleRect = CGRect.zero
        
        if let titleLabel = titleLabel {
            titleRect.origin.x = style.horizontalPadding
            titleRect.origin.y = imageRect.origin.y + imageRect.size.height + style.margin
            titleRect.size.width = titleLabel.bounds.size.width
            titleRect.size.height = titleLabel.bounds.size.height
        }
        
        var messageRect = CGRect.zero
        
        if let messageLabel = messageLabel {
            messageRect.origin.x = style.horizontalPadding
            messageRect.origin.y = imageRect.origin.y + imageRect.size.height + style.margin + titleRect.size.height + style.verticalPadding
            messageRect.size.width = messageLabel.bounds.size.width
            messageRect.size.height = messageLabel.bounds.size.height
        }
        
        var longerWidth = max(titleRect.size.width, messageRect.size.width)
        let longerX = max(titleRect.origin.x, messageRect.origin.x)
        var wrapperWidth = max(imageRect.size.width, (longerX + longerWidth + style.horizontalPadding))
        var wrapperHeight = messageRect.origin.y + messageRect.size.height + style.verticalPadding
        
        if let imageView = imageView {
            wrapperWidth = max(wrapperWidth, 120)
            wrapperHeight = max(wrapperHeight, 120)
            longerWidth = wrapperWidth - style.horizontalPadding * 2
            imageRect.origin.x = (wrapperWidth - imageView.bounds.size.width) / 2.0
            messageRect.origin.y = wrapperHeight - style.verticalPadding - messageRect.size.height
            titleRect.origin.y = wrapperHeight - style.verticalPadding * 2 - messageRect.size.height - titleRect.size.height
            imageView.frame = imageRect
            wrapperView.addSubview(imageView)
        }
        
        if let titleLabel = titleLabel {
            titleRect.size.width = longerWidth
            titleLabel.frame = titleRect
            wrapperView.addSubview(titleLabel)
        }
        
        if let messageLabel = messageLabel {
            messageRect.size.width = longerWidth
            messageLabel.frame = messageRect
            wrapperView.addSubview(messageLabel)
        }
        
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        return wrapperView
    }
}

public extension FunBox.HUD {
    
    struct Config {
        var title: String?
        var message: String?
        var inView: UIView?
        var duration: TimeInterval = 1.5
        var point: CGPoint?
        var position: Position = .bottom
        var image: UIImage?
        var style: Style = manager.style
        var completion: ((_ didTap: Bool) -> Void)?
        fileprivate var timer: Timer?
    }
    
    class Manager {
        
        fileprivate static let shared = Manager()
        
        public var style = Style()
        
        public var isTapToDismissEnabled = true
        
        public var isQueueEnabled = true
        
        public var duration: TimeInterval = 3.0
        
        public var position: Position = .center
        
    }
    
    struct Style {
        
        public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
        
        public var titleColor: UIColor = .white
        
        public var messageColor: UIColor = .white
        
        public var maxWidthPercentage: CGFloat = 0.8 {
            didSet {
                maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
            }
        }
        
        public var maxHeightPercentage: CGFloat = 0.8 {
            didSet {
                maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
            }
        }
        
        public var horizontalPadding: CGFloat = 10.0
        
        public var verticalPadding: CGFloat = 10.0
        
        public var margin: CGFloat = 10.0
        
        public var cornerRadius: CGFloat = 10.0;
        
        public var titleFont: UIFont = .boldSystemFont(ofSize: 16.0)
        
        public var messageFont: UIFont = .systemFont(ofSize: 16.0)
        
        public var titleAlignment: NSTextAlignment = .center
        
        public var messageAlignment: NSTextAlignment = .center
        
        public var titleNumberOfLines = 0
        
        public var messageNumberOfLines = 0
        
        public var displayShadow = false
        
        public var shadowColor: UIColor = .black
        
        public var shadowOpacity: Float = 0.8 {
            didSet {
                shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
            }
        }
        
        public var shadowRadius: CGFloat = 6.0
        
        public var shadowOffset = CGSize(width: 4.0, height: 4.0)
        
        public var imageSize = CGSize(width: 40.0, height: 40.0)
        
        public var activitySize = CGSize(width: 100.0, height: 100.0)
        
        public var fadeDuration: TimeInterval = 0.2
        
        public var activityIndicatorColor: UIColor = .white
        
        public var activityBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    enum Position {
        case top
        case center
        case bottom
        
        fileprivate func centerPoint(forToast toast: UIView, inSuperview superview: UIView) -> CGPoint {
            let topPadding: CGFloat = manager.style.verticalPadding + superview.csSafeAreaInsets.top
            let bottomPadding: CGFloat = manager.style.verticalPadding + superview.csSafeAreaInsets.bottom
            
            switch self {
            case .top:
                return CGPoint(x: superview.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
            case .center:
                return CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
            case .bottom:
                return CGPoint(x: superview.bounds.size.width / 2.0, y: (superview.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding)
            }
        }
    }
    
    
}

private extension UIView {
    
    var csSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
}

*/
