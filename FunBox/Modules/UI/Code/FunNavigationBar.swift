//
//  FunNavigationBar.swift
//  FunBox
//
//  Created by 肖华 on 2020/9/14.
//

import UIKit
//public typealias FunNavigationBar = FunBox.NavigationBar
//extension FunBox {
open class FunNavigationBar: UIView {
    
    public struct Style {
        public var backgroundColor: UIColor = .init(white: 0.97, alpha: 0.98)
        public var backgroundImage: UIImage?
        public var font: UIFont = .systemFont(ofSize: 18)
        public var textColor: UIColor = .darkText
        public var backItemImage: UIImage?
    }
    public static var style = Style()
    
    public var contentInsets: UIEdgeInsets
    
    public let contentView: UIView
    
    public let backItem: UIButton
    
    private let titleLabel: FunLabel
//    private lazy var titleLabel: FunLabel = {
//        let titleLabel = FunLabel()
//        titleLabel.verticalAlignment = .center
////        titleLabel.textColor = FunNavigationBar.style.textColor
////        titleLabel.font = FunNavigationBar.style.font
//        titleLabel.textAlignment = .center
//        //        self.titleView = titleLabel
//        contentView.addSubview(titleLabel)
//        return titleLabel
//    }()
    
    public lazy var clipBar: ClipBar = {
        let clipBar = ClipBar(frame: CGRect(x: 0, y: 0, width: 81, height: 44))
        return clipBar
    }()
    
    public struct Template: Equatable {
        public static func == (lhs: Template, rhs: Template) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        fileprivate var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public static let `default` = Template(rawValue: "default")
        public static let container = Template(rawValue: "container")
        
        public var height: CGFloat {
            switch self {
            
            default:
                return UIDevice.current.fb.isInfinity ? 88 : 64
            }
        }
    }
    public struct Config {
        
    }
    
    public init(template: Template = .default, frame: CGRect = .zero) {
        var frame = frame
        if frame == .zero {
            frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: max(frame.height, template.height))
        }
        contentInsets = UIEdgeInsets(top: UIDevice.current.fb.isInfinity ? 24 : 22, left: 8, bottom: 0, right: 8)
        contentView = UIView(frame: CGRect(x: contentInsets.left, y: contentInsets.top, width: frame.width - contentInsets.left - contentInsets.right, height: frame.height - contentInsets.bottom - contentInsets.top))
        titleLabel = FunLabel()
        backItem = UIButton()
        titleColor = FunNavigationBar.style.textColor
        titleFont = FunNavigationBar.style.font
        super.init(frame: frame)
        

        
        addSubview(contentView)
        titleLabel.verticalAlignment = .center
        titleLabel.textColor = titleColor
        titleLabel.font = titleFont
        titleLabel.textAlignment = .center
        //        self.titleView = titleLabel
        contentView.addSubview(titleLabel)
        contentView.addSubview(backItem)
        
        setUp(template: template)
        
    }
    
//    public override init(frame: CGRect) {
//        contentInsets = UIEdgeInsets(top: UIDevice.current.fb.isInfinity ? 24 : 22, left: 8, bottom: 0, right: 8)
//        contentView = UIView(frame: CGRect(x: contentInsets.left, y: contentInsets.top, width: frame.width - contentInsets.left - contentInsets.right, height: frame.height - contentInsets.bottom - contentInsets.top))
//        titleLabel = FunLabel()
//        backItem = UIButton()
//        titleColor = FunNavigationBar.style.textColor
//        titleFont = FunNavigationBar.style.font
//        super.init(frame: frame)
//
//
//
//        addSubview(contentView)
//        titleLabel.verticalAlignment = .center
//        titleLabel.textColor = titleColor
//        titleLabel.font = titleFont
//        titleLabel.textAlignment = .center
//        //        self.titleView = titleLabel
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(backItem)
//
//        setUp()
//
//    }
    
    private func setUp(template: Template) {
        backItem.addTarget(self, action: #selector(backItemAction(sender:)), for: .touchUpInside)
        backgroundColor = FunNavigationBar.style.backgroundColor
        backgroundImage = FunNavigationBar.style.backgroundImage
        backItemImage = FunNavigationBar.style.backItemImage
        
        if template == .container {
            
            tintColor = UIColor(white: 0.35, alpha: 1)
            rightView = clipBar
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func backItemAction(sender: UIButton) {
        
        backHandle?(sender)
        if isBackEnable {
            if let nav = fb.controller as? UINavigationController {
                nav.popViewController(animated: true)
            } else {
                fb.controller?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    public var isBackEnable: Bool = true
    private var backHandle: ((UIButton)->Void)?
    public func backAction(_ handle: ((UIButton)->Void)?) {
        backHandle = handle
    }
    
    // 原理与topView相同
    public var leftView: UIView? {
        willSet {
            if leftView == newValue {
                
                return
            }
            
            if let leftView = leftView {
                
                leftView.frame = CGRect.init(x: 0, y: contentView.bounds.height, width: leftView.frame.width, height: leftView.frame.height)
                leftView.removeFromSuperview()
                
            }
            
        }
        
        didSet {
            if let leftView = leftView {
                //                let size = leftView.sizeThatFits(contentView.bounds.size)
                var size = leftView.frame.size
                if size == .zero {
                    
                    size = leftView.sizeThatFits(contentView.bounds.size)
                }
                leftView.frame = CGRect(x: 0, y: contentView.frame.height - size.height, width: size.width, height: size.height)
                
                contentView.addSubview(leftView)
                
            }
        }
    }
    
    // 原理与topView相同
    public var rightView: UIView? {
        willSet {
            if rightView == newValue {
                
                return
            }
            
            if let rightView = rightView {
                
                rightView.frame = CGRect.init(x: contentView.bounds.width - rightView.bounds.width, y: contentView.bounds.height, width: rightView.frame.width, height: rightView.frame.height)
                rightView.removeFromSuperview()
                
            }
            
        }
        
        didSet {
            if let rightView = rightView {
                var size = rightView.frame.size
                if size == .zero {
                    
                    size = rightView.sizeThatFits(contentView.bounds.size)
                }
                rightView.frame = CGRect(x: contentView.bounds.width - size.width, y: contentView.frame.height - size.height, width: size.width, height: size.height)
                
                contentView.addSubview(rightView)
                
            }
        }
    }
    
    // 原理与topView相同
    public var titleView: UIView? {
        willSet {
            
            if titleView == newValue {
                
                return
            }
            
            if let titleView = titleView {
                
                titleView.removeFromSuperview()
                
            }
            
        }
        didSet {
            if let titleView = titleView {
                
                //                let offset = (contentView.frame.height - titleView.frame.height) / 2.0
                //
                //                titleView.center = CGPoint(x: contentView.center.x, y: contentView.center.y + offset)
                var size = titleView.frame.size
                if size == .zero {
                    
                    size = titleView.sizeThatFits(contentView.bounds.size)
                }
                
                titleView.frame = CGRect(x: (contentView.frame.width - size.width) / 2.0, y: contentView.bounds.height - size.height, width: size.width, height: size.height)
                
                contentView.addSubview(titleView)
                
            }
        }
        
    }
    
    open var title: String? {
        didSet {
            titleLabel.text = title
            setNeedsLayout()
        }
    }
    
    open var titleColor: UIColor {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    open var titleFont: UIFont {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    open var attributedText: NSAttributedString? {
        didSet {
            titleLabel.attributedText = attributedText
            setNeedsLayout()
        }
    }
    

    
    public var backgroundImage: UIImage? {
        didSet {
            if let backgroundImage = backgroundImage {
                let backgroundImageView = UIImageView(image: backgroundImage)
                addSubview(backgroundImageView)
                self.backgroundImageView = backgroundImageView
            } else {
                backgroundImageView?.removeFromSuperview()
                backgroundImageView = nil
            }
        }
    }
    private var backgroundImageView: UIImageView?
    
    public var backItemImage: UIImage? {
        didSet {
            backItem.setImage(backItemImage, for: .normal)
            var backItemSize = backItem.sizeThatFits(contentView.bounds.size)
            //                if backItemSize == .zero {
            backItemSize = CGSize(width: max(backItemSize.width, 44), height: max(backItemSize.height, 44))
            //                }
            backItem.frame = CGRect(x: 0, y: 0, width: backItemSize.width, height: backItemSize.height)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let backgroundImageView = backgroundImageView {
            backgroundImageView.frame = bounds
        }
        
        contentView.frame = CGRect(x: contentInsets.left, y: contentInsets.top, width: bounds.width - contentInsets.left - contentInsets.right, height: bounds.height - contentInsets.bottom - contentInsets.top)
        
        var rect: CGRect = contentView.bounds
        
        
        backItem.frame = CGRect(x: 0, y: contentView.frame.size.height - backItem.frame.size.height, width: backItem.frame.width, height: backItem.frame.height)
        
        if let leftView = leftView, !leftView.isHidden {
            backItem.removeFromSuperview()
            leftView.frame = CGRect(x: 0, y: contentView.frame.size.height - leftView.frame.size.height, width: leftView.frame.width, height: leftView.frame.height)
            
            rect.origin.x = leftView.frame.maxX
        }
        
        if let rightView = rightView {
            
            rightView.frame = CGRect(x: contentView.bounds.width - rightView.bounds.width, y: contentView.frame.height - rightView.frame.height, width: rightView.frame.width, height: rightView.frame.height)
            
            rect.size.width = rightView.frame.minX - rect.minX
            
        }
        
        if let titleView = titleView {
            titleView.frame = CGRect(x: max(rect.origin.x, titleView.frame.origin.x), y: rect.height - titleView.bounds.height, width: min(rect.width, titleView.frame.width), height: titleView.bounds.height)
            titleLabel.alpha = 0
        } else {
            titleLabel.alpha = 1
            //            let textSize = titleLabel.text?.fb.textSize(font: titleLabel.font, maxWidth: rect.width) ?? .zero
            
            //            let offset = (contentView.bounds.height - textSize.height) / 2.0
            //            titleLabel.sizeToFit()
            //            titleLabel.center = CGPoint(x: contentView.center.x, y: contentView.bounds.height / 2.0 - offset)
//            titleLabel.sizeThatFits(bounds.size)
//            titleLabel.center = CGPoint(x: center.x, y: rect.size.height - 22)
            titleLabel.frame = CGRect(x: 44, y: rect.height - 44, width: bounds.width-88, height: 44)
        }
    }
    
}

//}
extension FunNavigationBar {
    public class ClipBar: UIView {
        private let container: UIView
        public let moreItem: UIButton
        public let closeItem: UIButton
        private let cutLine: UIView
        override init(frame: CGRect) {
            container = UIView()
            moreItem = UIButton()
            closeItem = UIButton()
            cutLine = UIView()
            super.init(frame: frame)
            
            container.layer.borderWidth = 0.5
            container.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).cgColor
            container.layer.masksToBounds = true
            addSubview(container)
            
            cutLine.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
            container.addSubview(cutLine)
            
            closeItem.setImage(UIImage(named: "fb_nav_close", in: FunBox.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            closeItem.imageEdgeInsets = UIEdgeInsets(top: 5, left: 9, bottom: 5, right: 13)
            closeItem.addTarget(self, action: #selector(itemAction(sender:)), for: .touchUpInside)
            closeItem.setBackgroundImage(UIImage.fb.color(tintColor.fb.contrasting), for: .highlighted)
            container.addSubview(closeItem)

            moreItem.imageEdgeInsets = UIEdgeInsets(top: 5, left: 13, bottom: 5, right: 9)
            moreItem.setImage(UIImage(named: "fb_nav_more", in: FunBox.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            moreItem.addTarget(self, action: #selector(itemAction(sender:)), for: .touchUpInside)
            moreItem.setBackgroundImage(UIImage.fb.color(tintColor.fb.contrasting), for: .highlighted)
            container.addSubview(moreItem)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            container.layer.cornerRadius = 15
            container.frame = CGRect(x: 0, y: (bounds.height - 30) / 2.0, width: bounds.width, height: 30)
            let margin = (bounds.width - container.frame.height * 2.0) / 3.0
            closeItem.frame = CGRect(x: bounds.width / 2.0, y: 0, width: bounds.width / 2.0, height: container.frame.height)
            moreItem.frame = CGRect(x: 0, y: 0, width: bounds.width / 2.0, height: container.frame.height)
            cutLine.frame = CGRect(x: container.frame.midX, y: margin / 2.0, width: 0.5, height: container.frame.height - margin)
        }
        
        @objc private func itemAction(sender: UIButton) {
            
            if sender == closeItem {
                if let closeHandle = closeHandle {
                    closeHandle(sender)
                } else {
                    if let vc = fb.controller?.navigationController {
                        vc.dismiss(animated: true, completion: nil)
                    } else {
                        fb.controller?.dismiss(animated: true, completion: nil)
                    }
                }
            } else if sender == moreItem {
                moreHandle?(sender)
            }

        }
        
        private var closeHandle: ((UIButton)->Void)?
        public func closeAction(_ handle: ((UIButton)->Void)?) {
            closeHandle = handle
        }
        private var moreHandle: ((UIButton)->Void)?
        public func moreAction(_ handle: ((UIButton)->Void)?) {
            moreHandle = handle
        }
        
        public override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            closeItem.fb.effect(.corner).cornerRadius(container.bounds.height / 2.0).rectCornerType([.topRight,.bottomRight]).draw()
            moreItem.fb.effect(.corner).cornerRadius(container.bounds.height / 2.0).rectCornerType([.topLeft,.bottomLeft]).draw()
        }
    }
}

public extension FunNamespaceWrapper where T: UINavigationItem {
//public extension UINavigationItem {
    func set(rightItem newValue: UIView?) {
        if let rightItem = newValue {
            wrappedValue.rightBarButtonItem = UIBarButtonItem(customView: rightItem)
        } else {
            wrappedValue.rightBarButtonItem = nil
        }
    }
    var rightItem: UIView? {
        return wrappedValue.rightBarButtonItem?.customView
    }
    
    func set(leftItem newValue: UIView?) {
        if let leftItem = newValue {
            wrappedValue.leftBarButtonItem = UIBarButtonItem(customView: leftItem)
        } else {
            wrappedValue.leftBarButtonItem = nil
        }
    }
    var leftItem: UIView? {
        return wrappedValue.leftBarButtonItem?.customView
        
    }
//    var titleView: UIView? {
//        get {
//            return rightBarButtonItem?.customView
//        }
//        set {
//            if let rightView = newValue {
//                rightBarButtonItem = UIBarButtonItem(customView: rightView)
//            } else {
//                rightBarButtonItem = nil
//            }
//        }
//    }
}
