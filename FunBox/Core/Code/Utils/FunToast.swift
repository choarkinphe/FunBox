//
//  FunToast.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/22.
//

import UIKit
public typealias FunToast = FunBox.Toast

public extension FunBox {
    static var toast: Toast {
        return Toast.default
    }
    class Toast {
        
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
        
        public func mode(_ mode: FunBox.Toast.Mode) -> Self {
            config.mode = mode
            
            return self
        }
        public func progress(_ progress: CGFloat) -> Self {
            config.progress = progress
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
            if style == .system {
                config.position = .top
            }
            return self
        }
        
        public func template(_ template: Template) -> Self {
            config = template.config
            
            return self
        }
        
        public func isTapToDismissEnabled(_ isTapToDismissEnabled: Bool) -> Self {
            Manager.shared.isTapToDismissEnabled = isTapToDismissEnabled
            
            return self
        }
        
        public func show(_ completion: ((Bool)->Void)? = nil) {
            
            config.completion = completion
            
            let targetView = config.inView ?? UIApplication.shared.fb.frontController?.view ?? UIApplication.shared.fb.currentWindow
            
            targetView?.makeToast(config: config)
            
        }
        
        public func dismiss(inView: UIView? = nil) {
            let targetView = inView ?? UIApplication.shared.fb.frontController?.view ?? UIApplication.shared.fb.currentWindow
            
            targetView?.hideToast()
        }
        
        public func dismissAll(includeActivity: Bool = false, inView: UIView? = nil) {
            let targetView = inView ?? UIApplication.shared.fb.frontController?.view ?? UIApplication.shared.fb.currentWindow
            
            targetView?.hideAllToasts(includeActivity: includeActivity, clearQueue: true)
        }
        
        public func dismissActivity(inView: UIView? = nil) {
            let targetView = inView ?? UIApplication.shared.fb.frontController?.view ?? UIApplication.shared.fb.currentWindow
            targetView?.hideToastActivity()
        }
        
        fileprivate enum ToastError: Error {
            case missingParameters
            case missingSuperView
        }
        
        public static var manager = Manager.shared
        
    }
    
    
}

public extension FunBox.Toast {
    
    
    class ProgressView: UIView {
        
        var lineWidth: CGFloat = 5.0//线宽
        
        var strokeColor: UIColor = .lightGray //底线
        
        var fillColor: UIColor = .white //progress线条
        
        var startAngle: CGFloat = 0 //起始
        
        var endAngle: CGFloat = 0 //结束
        
        var progress: CGFloat = 0.0 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        private lazy var strokeLayer: CAShapeLayer = {
            
            let strokeLayer = CAShapeLayer()
            
            strokeLayer.fillColor = UIColor.clear.cgColor
            
            layer.addSublayer(strokeLayer)
            
            return strokeLayer
            
        }()
        
        private lazy var fillLayer: CAShapeLayer = {
            
            let fillLayer = CAShapeLayer()
            
            fillLayer.lineCap = .round
            
            fillLayer.fillColor = UIColor.clear.cgColor
            
            layer.addSublayer(fillLayer)
            
            return fillLayer
            
        }()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .clear
            tag = 10180
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            let radius = bounds.size.width / 2.0
            
            let strokePath = UIBezierPath(arcCenter:center, radius:radius, startAngle:0, endAngle:CGFloat(Double.pi*2), clockwise:true)
            
            strokeLayer.path = strokePath.cgPath
            
            strokeLayer.strokeColor = strokeColor.cgColor
            
            fillLayer.strokeColor = fillColor.cgColor
            
            fillLayer.lineWidth = lineWidth
            
            strokeLayer.lineWidth = lineWidth
            
            startAngle = -CGFloat(Double.pi/2.0)
            
            endAngle = startAngle + progress * CGFloat(Double.pi*2)
            
            let fillPath = UIBezierPath(arcCenter:center, radius:radius, startAngle:startAngle, endAngle:endAngle, clockwise:true)
            
            fillLayer.path = fillPath.cgPath//添加路径
            
            
        }
        
        
    }
}

extension FunBox.Toast.Config {
    fileprivate func buildToast() throws -> UIView {
        
        guard let superView = inView else { throw FunBox.Toast.ToastError.missingSuperView }
        // sanity
        guard message != nil || title != nil || image != nil else {
            throw FunBox.Toast.ToastError.missingParameters
        }
        
//        var style = self.style
        
        var imageView: UIImageView?
        var imageRect = CGRect.zero
        var titleLabel: UILabel?
        var titleRect = CGRect.zero
        var messageLabel: UILabel?
        var messageRect = CGRect.zero
        
        let contentView = UIView()
        contentView.backgroundColor = style.backgroundColor
        contentView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        contentView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowOpacity = style.shadowOpacity
            contentView.layer.shadowRadius = style.shadowRadius
            contentView.layer.shadowOffset = style.shadowOffset
        }
        
        // 设置图片
        if let image = image {
//            style.verticalPadding = max(style.verticalPadding, 20)
            imageView = UIImageView(image: image.withRenderingMode(style.imageRenderingMode))
            imageView?.tintColor = style.imageColor
            imageView?.contentMode = .scaleAspectFit
            imageRect.size.width = style.imageSize.width
            imageRect.size.height = style.imageSize.height
        }
        
        // activity不允许和image共存
        if mode == .activity {
//            style.verticalPadding = max(style.verticalPadding, 20)
            imageView = UIImageView(image: UIImage.fb.color(.clear, size: style.activitySize))
            
            imageRect.size.width = style.activitySize.width
            imageRect.size.height = style.activitySize.height
            let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
            activityIndicatorView.center = CGPoint(x: imageRect.width / 2.0, y: imageRect.height / 2.0)
            
            imageView?.addSubview(activityIndicatorView)
            activityIndicatorView.color = style.activityIndicatorColor
            activityIndicatorView.startAnimating()
        }
        
        if mode == .progress {
//            style.verticalPadding = max(style.verticalPadding, 20)
            imageView = UIImageView(image: UIImage.fb.color(.clear, size: style.progressSize))
            imageRect.size.width = style.progressSize.width
            imageRect.size.height = style.progressSize.height
            
            let progressView = FunBox.Toast.ProgressView(frame: imageRect)
            progressView.center = CGPoint(x: imageRect.width / 2.0, y: imageRect.height / 2.0)
            imageView?.addSubview(progressView)
        }
        
        // 设置标题
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
                titleRect.origin.x = style.horizontalPadding
                titleRect.size.width = titleSize.width
                titleRect.size.height = titleSize.height
                
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
                messageRect.origin.x = style.horizontalPadding
                messageRect.size.width = actualWidth
                messageRect.size.height = actualHeight
            }
        }
        
        
        var textWidth = max(titleRect.width, messageRect.width)
//        let longerX = max(titleRect.origin.x, messageRect.origin.x)
        var position = CGPoint(x: max(titleRect.origin.x, messageRect.origin.x), y: style.verticalPadding)
        var contentWidth = max(imageRect.width, (position.x + textWidth + style.horizontalPadding))
        var contentHeight = position.y + style.verticalPadding
        
        if style == .system {
            contentHeight = position.y + titleRect.size.height + style.margin + messageRect.size.height + style.verticalPadding
            contentWidth = min(imageRect.width + style.margin * 2 + textWidth + contentHeight, superView.frame.width - 2 * style.horizontalPadding)
            position.x = contentHeight / 2.0
        }
        
        if let imageView = imageView {
            
            if style == .system {
                imageRect.origin.x = style.horizontalPadding
                imageRect.origin.y = (contentHeight - imageRect.size.height) / 2.0
                position.x = imageRect.maxX + style.margin * 2
                
            } else {
                contentWidth = max(contentWidth, 120)
                textWidth = contentWidth - style.horizontalPadding * 2
                imageRect.origin.x = (contentWidth - imageView.bounds.size.width) / 2.0
                imageRect.origin.y = position.y
                position.y = imageRect.maxY + style.margin
            }
            
            imageView.frame = imageRect
            contentView.addSubview(imageView)
        }
        
        if let titleLabel = titleLabel {
            titleRect.size.width = textWidth
            if style == .system {
                
                titleRect.origin = position
                position.y = titleRect.maxY + style.margin
            } else {
            
            titleRect.origin.y = position.y
                position.y = titleRect.maxY + style.margin
            }
            titleLabel.frame = titleRect
            contentView.addSubview(titleLabel)
        }
        
        if let messageLabel = messageLabel {
            messageRect.size.width = textWidth
            if style == .system {
                messageRect.origin = position
            } else {
            messageRect.origin.y = position.y
            position.y = messageRect.maxY
            }
            messageLabel.frame = messageRect
            contentView.addSubview(messageLabel)
        }
        
        
        if style == .system {
            contentView.layer.cornerRadius = contentHeight / 2.0
        } else {
            contentHeight = position.y + style.verticalPadding
        }
        
        contentView.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: contentHeight)
        
        return contentView
    }
    
    
}

public extension UIView {
    
    /**
     Keys used for associated objects.
     */
    private struct Keys {
        static var timer        = "com.funbox.toast.timer"
        static var duration     = "com.funbox.toast.duration"
        static var point        = "com.funbox.toast.point"
        static var completion   = "com.funbox.toast.completion"
        static var activeToasts = "com.funbox.toast.activeToasts"
        static var activityView = "com.funbox.toast.activityView"
        static var queue        = "com.funbox.toast.queue"
    }
    
    private class CompletionWrapper {
        let completion: ((Bool) -> Void)?
        
        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    private var activityView: UIView? {
        get {
            return objc_getAssociatedObject(self, &Keys.activityView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &Keys.activityView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var activeToasts: [UIView] {
        get {
            if let activeToasts = objc_getAssociatedObject(self, &Keys.activeToasts) as? [UIView] {
                return activeToasts
            } else {
                objc_setAssociatedObject(self, &Keys.activeToasts, [UIView](), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return self.activeToasts
        }
        set {
            objc_setAssociatedObject(self, &Keys.activeToasts, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var queue: [UIView] {
        get {
            if let queue = objc_getAssociatedObject(self, &Keys.queue) as? [UIView] {
                return queue
            } else {
                objc_setAssociatedObject(self, &Keys.queue, [UIView](), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return self.queue
        }
        set {
            objc_setAssociatedObject(self, &Keys.queue, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Make Toast Methods
    func makeToast(config: FunBox.Toast.Config) {
        do {
            // 默认样式执行无限创建
            if config.mode == .default {
                let toast = try config.buildToast()
                let point = config.point ?? config.position.centerPoint(forToast: toast, style: config.style, inSuperview: self)
                showToast(toast, duration: config.duration, point: point, completion: config.completion)
            } else {
                // 动态样式，先判断有没有活动中的activity
                if let toast = activityView, let progressView = toast.viewWithTag(10180) as? FunToast.ProgressView {
                    // 动态设置进度条
                    progressView.progress = config.progress
                    
                    if config.progress >= 1.0 {
                        // 回调出去
                        config.completion?(true)
                        // 进度完成时，隐藏进度条
                        
                        hideToastActivity()
                    }
                } else {
                    // 创建activity
                    let toast = try config.buildToast()
                    let point = config.point ?? config.position.centerPoint(forToast: toast, style: config.style, inSuperview: self)
                    showActivity(toast, point: point)
                }
            }
            
        } catch FunBox.Toast.ToastError.missingParameters {
            print("Error: message, title, and image are all nil")
        } catch FunBox.Toast.ToastError.missingSuperView {
            print("Error: missing superView")
        } catch {}
    }
    
    func showToast(_ toast: UIView, duration: TimeInterval = FunBox.Toast.manager.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil) {
        objc_setAssociatedObject(toast, &Keys.completion, CompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if FunBox.Toast.manager.isQueueEnabled, activeToasts.count > 0 {
            objc_setAssociatedObject(toast, &Keys.duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(toast, &Keys.point, NSValue(cgPoint: point), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            queue.append(toast)
        } else {
            showToast(toast, duration: duration, point: point)
        }
    }
    
    
    // MARK: - Private Activity Methods
    
    private func showActivity(_ toast: UIView, point: CGPoint) {
        // activity的话 只允许弹一个
        guard activityView == nil else {
            return
        }
        
        toast.alpha = 0.0
        
        
        activityView = toast
        
        self.addSubview(toast)
        
        if point.y - toast.frame.height < csSafeAreaInsets.top {
            toast.center = CGPoint(x: point.x, y: point.y - toast.frame.height)
        } else if point.y + toast.frame.height > self.frame.maxY {
            toast.center = CGPoint(x: point.x, y: point.y + toast.frame.height)
        } else {
            toast.center = point
        }
        
        UIView.animate(withDuration: FunBox.Toast.manager.fadeDuration, delay: 0.0, options: .curveEaseOut, animations: {
            toast.alpha = 1.0
            toast.center = point
        })
    }
    
    // MARK: - Private Show/Hide Methods
    
    private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
        
        toast.alpha = 0.0
        
        if FunBox.Toast.Manager.shared.isTapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        activeToasts.append(toast)
        
        //        activeToasts.add(toast)
        self.addSubview(toast)
        if point.y - toast.frame.height < csSafeAreaInsets.top {
            toast.center = CGPoint(x: point.x, y: point.y - toast.frame.height)
        } else if point.y + toast.frame.height > self.frame.maxY {
            toast.center = CGPoint(x: point.x, y: point.y + toast.frame.height)
        } else {
            toast.center = point
        }
//
        UIView.animate(withDuration: FunBox.Toast.manager.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            toast.alpha = 1.0
            toast.center = point
        }) { _ in
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            objc_setAssociatedObject(toast, &Keys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
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
        
        activeToasts.forEach { (item) in
            hideToast(item)
        }
        
        if includeActivity {
            hideToastActivity()
        }
    }
    
    func hideToastActivity() {
        if let toast = activityView {
            
            UIView.animate(withDuration: FunBox.Toast.manager.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                if toast.center.y - toast.frame.height < self.csSafeAreaInsets.top {
                    toast.center = CGPoint(x: toast.center.x, y: toast.center.y - toast.frame.height)
                } else if toast.center.y + toast.frame.height > self.frame.maxY {
                    toast.center = CGPoint(x: toast.center.x, y: toast.center.y + toast.frame.height)
                }
//                else {
//                    toast.center = toast.center
//                }
                toast.alpha = 0.0
            }) { _ in
                toast.removeFromSuperview()
                self.activityView = nil
            }
        }
    }
    
    func clearToastQueue() {
        queue.removeAll()
    }
    
    private func hideToast(_ toast: UIView, fromTap: Bool) {
        if let timer = objc_getAssociatedObject(toast, &Keys.timer) as? Timer {
            timer.invalidate()
        }
        
        UIView.animate(withDuration: FunBox.Toast.manager.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            if toast.center.y - toast.frame.height < self.csSafeAreaInsets.top {
                toast.center = CGPoint(x: toast.center.x, y: toast.center.y - toast.frame.height)
            } else if toast.center.y + toast.frame.height > self.frame.maxY {
                toast.center = CGPoint(x: toast.center.x, y: toast.center.y + toast.frame.height)
            }
            toast.alpha = 0.0
        }) { _ in
            toast.removeFromSuperview()
            
            if let index = self.activeToasts.firstIndex(of: toast) {
                self.activeToasts.remove(at: index)
            }
            
            if let wrapper = objc_getAssociatedObject(toast, &Keys.completion) as? CompletionWrapper, let completion = wrapper.completion {
                completion(fromTap)
            }
            
            if let nextToast = self.queue.first, let duration = objc_getAssociatedObject(nextToast, &Keys.duration) as? NSNumber, let point = objc_getAssociatedObject(nextToast, &Keys.point) as? NSValue {
                self.queue.remove(at: 0)
                self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
            }
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
    
}

public extension FunBox.Toast {
    
    struct Config {
        var title: String?
        var message: String?
        var inView: UIView?
        var duration: TimeInterval = 2.5
        var point: CGPoint?
        var position: Position = .bottom
        var image: UIImage?
        
        var style: Style = Style.default
        // dismiss后的回调
        var completion: ((Bool) -> Void)?
        var progress: CGFloat = 0.0
        var mode: Mode = .default
    }
    
    enum Mode: Equatable {
        case `default`
        case activity
        case progress
    }
    
    struct Template {
        fileprivate let config: Config
        public init(config: Config) {
            self.config = config
        }
        public static let error = Template(config: Config(image: UIImage(named: "fb_tips_error", in: FunBox.bundle, compatibleWith: nil)))
        public static let done = Template(config: Config(image: UIImage(named: "fb_tips_done", in: FunBox.bundle, compatibleWith: nil)))
        public static let info = Template(config: Config(image: UIImage(named: "fb_tips_info", in: FunBox.bundle, compatibleWith: nil)))
    }

    // MARK: - Toast Style
    
    struct Style: Equatable {
        
        public static var `default` = Style(identifier: "default")
        
        public static var system = Style(identifier: "system")
        
        private let identifier: String?
        
        public init(identifier: String?=nil) {
            self.identifier = identifier
            if identifier == "system" {
                backgroundColor = .white
                imageColor = .init(white: 0.1, alpha: 1)
                titleColor = .init(white: 0.1, alpha: 1)
                titleFont = .systemFont(ofSize: 12)
                messageFont = .systemFont(ofSize: 12)
                messageColor = .init(white: 0.3, alpha: 1)
                displayShadow = true
                verticalPadding = 5
                margin = 5
                imageSize = CGSize(width: 24, height: 24)
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
        /**
         The background color. Default is `.black` at 80% opacity.
         */
        public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
        
        public var imageColor: UIColor = .white
        
        public var imageRenderingMode: UIImage.RenderingMode = .alwaysTemplate
        
        /**
         The title color. Default is `UIColor.whiteColor()`.
         */
        public var titleColor: UIColor = .white
        
        /**
         The message color. Default is `.white`.
         */
        public var messageColor: UIColor = .white
        
        /**
         A percentage value from 0.0 to 1.0, representing the maximum width of the toast
         view relative to it's superview. Default is 0.8 (80% of the superview's width).
         */
        public var maxWidthPercentage: CGFloat = 0.8 {
            didSet {
                maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
            }
        }
        
        /**
         A percentage value from 0.0 to 1.0, representing the maximum height of the toast
         view relative to it's superview. Default is 0.8 (80% of the superview's height).
         */
        public var maxHeightPercentage: CGFloat = 0.8 {
            didSet {
                maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
            }
        }
        
        /**
         The spacing from the horizontal edge of the toast view to the content. When an image
         is present, this is also used as the padding between the image and the text.
         Default is 10.0.
         
         */
        public var horizontalPadding: CGFloat = 10.0
        
        /**
         The spacing from the vertical edge of the toast view to the content. When a title
         is present, this is also used as the padding between the title and the message.
         Default is 10.0. On iOS11+, this value is added added to the `safeAreaInset.top`
         and `safeAreaInsets.bottom`.
         */
        public var verticalPadding: CGFloat = 20.0
        
        public var margin: CGFloat = 10.0
        
        /**
         The corner radius. Default is 10.0.
         */
        public var cornerRadius: CGFloat = 10.0;
        
        /**
         The title font. Default is `.boldSystemFont(16.0)`.
         */
        public var titleFont: UIFont = .boldSystemFont(ofSize: 16.0)
        
        /**
         The message font. Default is `.systemFont(ofSize: 16.0)`.
         */
        public var messageFont: UIFont = .systemFont(ofSize: 16.0)
        
        /**
         The title text alignment. Default is `NSTextAlignment.Left`.
         */
        public var titleAlignment: NSTextAlignment = .center
        
        /**
         The message text alignment. Default is `NSTextAlignment.Left`.
         */
        public var messageAlignment: NSTextAlignment = .center
        
        /**
         The maximum number of lines for the title. The default is 0 (no limit).
         */
        public var titleNumberOfLines = 0
        
        /**
         The maximum number of lines for the message. The default is 0 (no limit).
         */
        public var messageNumberOfLines = 0
        
        /**
         Enable or disable a shadow on the toast view. Default is `false`.
         */
        public var displayShadow = false
        
        /**
         The shadow color. Default is `.black`.
         */
        public var shadowColor: UIColor = .black
        
        /**
         A value from 0.0 to 1.0, representing the opacity of the shadow.
         Default is 0.8 (80% opacity).
         */
        public var shadowOpacity: Float = 0.4 {
            didSet {
                shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
            }
        }
        
        /**
         The shadow radius. Default is 6.0.
         */
        public var shadowRadius: CGFloat = 5.0
        
        /**
         The shadow offset. The default is 4 x 4.
         */
        public var shadowOffset = CGSize(width: 2.0, height: 2.0)
        
        
        
        /**
         The image size. The default is 80 x 80.
         */
        public var imageSize = CGSize(width: 40.0, height: 40.0)
        
        public var activitySize = CGSize(width: 40.0, height: 40.0)
        
        public var progressSize = CGSize(width: 50.0, height: 50.0)
        
        /**
         The fade in/out animation duration. Default is 0.2.
         */
//        public var fadeDuration: TimeInterval = 0.2
        
        /**
         Activity indicator color. Default is `.white`.
         */
        public var activityIndicatorColor: UIColor = .white
        
        /**
         Activity background color. Default is `.black` at 80% opacity.
         */
        public var activityBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
        
    }
    
    // MARK: - Toast Manager
    
    class Manager {
        
        /**
         默认管理器单利
         */
        fileprivate static let shared = Manager()
        
        /**
         通用的样式
         */
//        public var style = Style()
        
        /**
         是否点击屏幕关闭toast
         */
        public var isTapToDismissEnabled = true
        
        /**
         默认开启显示队列
         */
        public var isQueueEnabled = true
        
        /**
         默认显示3秒
         */
        public var duration: TimeInterval = 3.0
        /**
         动画时长
         */
        public var fadeDuration: TimeInterval = 0.2
        
        /**
         默认显示在屏幕中央
         */
        public var position: Position = .center
        
    }
    
    // MARK: - ToastPosition
    enum Position {
        case top
        case center
        case bottom
        
        fileprivate func centerPoint(forToast toast: UIView, style: Style, inSuperview superview: UIView) -> CGPoint {
            let topPadding: CGFloat = style.verticalPadding + superview.csSafeAreaInsets.top
            let bottomPadding: CGFloat = style.verticalPadding + superview.csSafeAreaInsets.bottom
            
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

// MARK: - Private UIView Extensions

private extension UIView {
    
    var csSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
}

