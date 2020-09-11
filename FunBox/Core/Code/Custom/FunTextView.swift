//
//  FunTextView.swift
//  HZCoreKit_Example
//
//  Created by choarkinphe on 2020/9/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

public typealias FunTextView = FunBox.TextView
extension FunBox {
    open class TextView: UITextView {
        public var placeholder: String?
        public let placeholderLabel: UILabel
        
        override init(frame: CGRect, textContainer: NSTextContainer?) {
            placeholderLabel = UILabel()
            super.init(frame: frame, textContainer: textContainer)
         
            if #available(iOS 13.0, *) {
                placeholderLabel.textColor = UIColor.placeholderText
            } else {
                // Fallback on earlier versions
                placeholderLabel.textColor = UIColor(white: 0.75, alpha: 0)
            }
            placeholderLabel.numberOfLines = 0
            placeholderLabel.font = font
            placeholderLabel.alpha = 0
            addSubview(placeholderLabel)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleTextChanged(notic:)), name: UITextView.textDidChangeNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleTextChanged(notic:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        @objc private func handleTextChanged(notic: Notification) {
            // 输入字符的时候，placeholder隐藏
            if let placeholder = placeholder, !placeholder.isEmpty {
                updatePlaceholderLabelHidden()
            }
            
            if let textView = notic.object as? FunTextView {
                if !textView.isEditable {
                    return// 不可编辑的 textView 不会显示光标
                }
                
                // 计算高度
                let resultHeight = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat(MAXFLOAT))).height
                
                // 回调通知更新textView的高度
                if resultHeight != textView.bounds.height {

                    newHeightAfterTextChanged?(resultHeight)
                }

            }
        }
        
        private var newHeightAfterTextChanged: ((CGFloat)->Void)?
        public func newHeightAfterTextChanged(_ handler: ((CGFloat)->Void)?) {
            newHeightAfterTextChanged = handler
        }
        
        func updatePlaceholderLabelHidden() {
            if text.count == 0, let placeholder = placeholder, !placeholder.isEmpty {
                placeholderLabel.alpha = 1
            } else {
                // 用alpha来让placeholder隐藏，从而尽量避免因为显隐 placeholder 导致 layout
                placeholderLabel.alpha = 0
            }
        }
        
        public var placeholderMargins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            if placeholderLabel.alpha == 1 {
                let labelMargins = textContainerInset.fb.contect(placeholderMargins)
                
                let limitWidth = bounds.width - contentInset.fb.horizontalValue - labelMargins.fb.horizontalValue
                let limitHeight = bounds.height - contentInset.fb.horizontalValue - labelMargins.fb.horizontalValue
                var labelSize = placeholderLabel.sizeThatFits(CGSize(width: limitWidth, height: limitHeight))
                labelSize.height = min(limitHeight, labelSize.height)
                
                placeholderLabel.frame = CGRect(x: labelMargins.left, y: labelMargins.top, width: labelSize.width, height: labelSize.height)
            }
        }
        
        open override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            updatePlaceholderLabelHidden()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}


