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
    
    public override init(frame: CGRect) {
        contentInsets = UIEdgeInsets(top: UIDevice.current.fb.iPhoneXSeries ? 24 : 22, left: 0, bottom: 0, right: 0)
        contentView = UIView()
        backItem = UIButton()
        super.init(frame: frame)
        
        
        
        addSubview(contentView)
        
        contentView.addSubview(backItem)
        
        setUp()
        
    }
    
    private func setUp() {
        backItem.addTarget(self, action: #selector(backItemAction(sender:)), for: .touchUpInside)
        backgroundColor = FunNavigationBar.style.backgroundColor
        backgroundImage = FunNavigationBar.style.backgroundImage
        backItemImage = FunNavigationBar.style.backItemImage
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func backItemAction(sender: UIButton) {
        
        backHandle?(sender)
        if isBackEnable {
            fb.controller?.navigationController?.popViewController(animated: true)
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
                
                titleView.frame = CGRect(x: (contentView.frame.width - size.width / 2.0), y: contentView.bounds.height - size.height, width: size.width, height: size.height)
                
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
    
    open var attributedText: NSAttributedString? {
        didSet {
            titleLabel.attributedText = attributedText
            setNeedsLayout()
        }
    }
    
    private lazy var titleLabel: FunLabel = {
        let titleLabel = FunLabel()
        titleLabel.verticalAlignment = .center
        titleLabel.textColor = FunNavigationBar.style.textColor
        titleLabel.font = FunNavigationBar.style.font
        titleLabel.textAlignment = .center
        //        self.titleView = titleLabel
        self.contentView.addSubview(titleLabel)
        return titleLabel
    }()
    
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
            titleView.frame = CGRect(x: max(rect.origin.x, titleView.frame.origin.x), y: rect.height - titleView.bounds.height, width: rect.width, height: titleView.bounds.height)
            titleLabel.alpha = 0
        } else {
            titleLabel.alpha = 1
            //            let textSize = titleLabel.text?.fb.textSize(font: titleLabel.font, maxWidth: rect.width) ?? .zero
            
            //            let offset = (contentView.bounds.height - textSize.height) / 2.0
            //            titleLabel.sizeToFit()
            //            titleLabel.center = CGPoint(x: contentView.center.x, y: contentView.bounds.height / 2.0 - offset)
            titleLabel.frame = CGRect(x: rect.origin.x, y: rect.height - 44, width: rect.width, height: 44)
        }
    }
    
}

//}
