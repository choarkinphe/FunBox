//
//  FunLabel.swift
//  HZCommon
//
//  Created by choarkinphe on 2020/8/14.
//  Copyright © 2020 hongzheng. All rights reserved.
//

import UIKit
// MARK: - CustomView
//public typealias FunLabel = FunBox.Label
//extension FunBox {
    open class FunLabel: UILabel {
        public enum VerticalAlignment: Int {
            case none = 0
            case top = 1
            case center = 2
            case bottom = 3
        }
        open var verticalAlignment: VerticalAlignment = .none {
            didSet {
                setNeedsDisplay()
            }
        }
        open var edgeInsets: UIEdgeInsets = .zero {
            didSet {
                setNeedsDisplay()
            }
        }
        open override func drawText(in rect: CGRect) {
            if verticalAlignment == .none {
                super.drawText(in: rect)
            } else {
                
                var rect = bounds
                rect.origin.x = rect.origin.x + edgeInsets.left
                rect.origin.y = rect.origin.y + edgeInsets.top
                rect.size.width = rect.width - edgeInsets.right - rect.origin.x
                rect.size.height = rect.height - edgeInsets.bottom - rect.origin.y
                super.drawText(in: textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines))
            }
        }
        
        open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
            var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
            switch verticalAlignment {
            case .top:
                textRect.origin.y = bounds.origin.y
            case .center:
                textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0
            case .bottom:
                
                textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
            default:
                break
            }
            return textRect
        }
    }
//}
