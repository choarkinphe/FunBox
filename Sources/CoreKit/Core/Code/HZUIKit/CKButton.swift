//
//  HZButton.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/15.
//

import UIKit

class CKButton: UIButton {
    var hitTestEdgeInsets: UIEdgeInsets = .zero
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if hitTestEdgeInsets == .zero {
            return super.point(inside: point, with: event)
        }
        
        let rect = CGRect(x: hitTestEdgeInsets.left, y: hitTestEdgeInsets.top, width: bounds.width - hitTestEdgeInsets.left - hitTestEdgeInsets.right, height: bounds.height - hitTestEdgeInsets.top - hitTestEdgeInsets.bottom)
        
        return rect.contains(point)
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

//    }
}

class CKBubble: UIView {
    
}
