//
//  HZEditViewController.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/11/3.
//

import UIKit
import FunBox
extension HZEditor {
    class ContentView: UIView, UITextViewDelegate {
        
        var textView = FunTextView()
        
        var maxCount: Int = 500
        
        var contentInset = UIEdgeInsets(top: 20, left: 12, bottom: 8, right: 12) {
            didSet {
                setNeedsLayout()
            }
        }
        
        func bind(viewModel: ViewModel) {
            _ = textView.rx.textInput <-> viewModel.text_behavior
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            textView.font = Theme.Font.default
            textView.textColor = Theme.Color.darkText
            textView.backgroundColor = .clear
            textView.delegate = self
            textView.textContainerInset = UIEdgeInsets(top: 5, left: 8, bottom: 0, right: 8)
            textView.keyboardDismissMode = .onDrag
            addSubview(textView)
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            textView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: bounds.width-contentInset.left-contentInset.right, height: bounds.height-contentInset.top-contentInset.bottom)
        }
        
        private var beginEdit: ((UITextView)->Bool)?
        func beginEdit(_ handler: ((UITextView)->Bool)?) {
            beginEdit = handler
        }
        private var endEdit: ((UITextView)->Void)?
        func endEdit(_ handler: ((UITextView)->Void)?) {
            endEdit = handler
        }
        private var changeHeight: ((CGFloat)->Void)?
        func changeHeight(_ handler: ((CGFloat)->Void)?) {
            changeHeight = handler
        }
        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            
            return beginEdit?(textView) ?? true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            endEdit?(textView)
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "" { // 删除字符
                return true
            }
            
            // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
            if (textView.markedTextRange != nil) {
                return true
            }
            
            if let text = textView.text {
                if text.count > maxCount-1 {
                    
                    return false
                }
            }
            
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 textView:shouldChangeTextInRange:replacementText: 的，所以要在这里截断文字
            // 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
            
            if (textView.markedTextRange == nil) {
                
                textView.text = textView.text.fb.subString(to: maxCount)
            }
        }
    }
}
