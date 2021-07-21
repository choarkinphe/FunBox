//
//  UIView+Add.swift
//  Store
//
//  Created by choarkinphe on 2020/6/2.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit
@_exported import SnapKit
typealias ConstructionElements = [ConstructionElement?]


public protocol ConstructionElement {
    var font: UIFont? {get}
    var color: UIColor? {get}
    var image: UIImage? {get}
}

extension ConstructionElement {
    public var font: UIFont? {return nil}
    public var color: UIColor? {return nil}
    public var image: UIImage? {return nil}
}

extension UIImage: ConstructionElement {
    public var image: UIImage? {return self}
}

extension UIFont: ConstructionElement {
    public var font: UIFont? { return self }

}

extension UIColor: ConstructionElement {

    public var color: UIColor? { return self }
}

extension ConstructionElements: ConstructionElement {
    public var font: UIFont? {
        for item in self {
            if let font = item?.font {
                return font
            }
        }
        
        return nil
    }
    
    public var color: UIColor? {
        for item in self {
            if let color = item?.color {
                return color
            }
        }
        
        return nil
    }
    
    
}

public extension UILabel {

    convenience init(_ style: ConstructionElement) {
        self.init()
        if let font = style.font {
            self.font = font
        }
        if let textColor = style.color {
            self.textColor = textColor
        }
        
    }
}

//enum CKType {
//    case back
//}

public extension UIButton {
    convenience init(_ style: ConstructionElement) {
        self.init()
        if let font = style.font {
            self.titleLabel?.font = font
        }
        if let textColor = style.color {
            setTitleColor(textColor, for: .normal)
        }
        if let image = style.image {
            setImage(image, for: .normal)
        }
    }
    
}

