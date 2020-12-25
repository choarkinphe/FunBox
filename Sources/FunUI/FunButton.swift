//
//  FunButton.swift
//  FunBox
//
//  Created by choarkinphe on 2020/8/25.
//
#if !COCOAPODS
import FunBox
#endif

import UIKit

open class FunButton: UIButton {
    public enum Layout {
        case `default`
        case imageTop
        case imageLeft
        case imageBottom
        case imageRight
    }
    
    open var layout: Layout = .default
    
    public convenience init(_ layout: Layout) {
        self.init()
        
        self.layout = layout
    }
    
    open override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        
        setNeedsLayout()
    }
    
    open override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        setNeedsLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let label_size = titleLabel?.frame.size,
              let image_size = imageView?.frame.size else { return }
        
        switch self.layout {
        case .imageTop:
            imageView?.center = CGPoint(x: bounds.size.width / 2.0, y: image_size.height / 2.0 + 7.0)
            titleLabel?.frame = CGRect(x: 4, y: bounds.size.height - label_size.height - 4, width: bounds.size.width - 8, height: label_size.height)
            titleLabel?.textAlignment = .center
        case .imageLeft:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
            
        case .imageBottom:
            imageView?.center = CGPoint(x: center.x, y: bounds.size.height - image_size.height / 2.0 - 4)
            
            titleLabel?.center = CGPoint(x: center.x, y: bounds.size.height - label_size.height / 2.0 + 4)
            
        case .imageRight:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: label_size.width + 4, bottom: 0, right: -label_size.width - 4)
            
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -image_size.width - 4, bottom: 0, right: image_size.width + 4)
            
        default:
            break
        }
        
    }
}
