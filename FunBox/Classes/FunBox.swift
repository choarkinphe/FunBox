//
//  FunBox.swift
//  Alamofire
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
public typealias FunLocation = FunBox.Location
public typealias FunToast = FunBox.Toast
public typealias FunSheet = FunBox.Sheet
public typealias FunAlert = FunBox.Alert
public typealias FunDatePicker = FunBox.DatePicker
public typealias FunCache = FunBox.Cache
//public typealias FunDrawingBoard = FunBox.DrawingBoard
open class FunBox {
    
    private struct Static {
        
//        static var instance_device: Device = Device()
    }
    
}

// MARK: - DrawingBoard
//public extension FunBox {
//   static var drawingBoard: DrawingBoard {
//
//        return DrawingBoard.default
//    }
//}

// MARK: - picker
public extension FunBox {
    
    static var datePicker: DatePicker {
        
        return DatePicker.default
    }
    
    static var sheet: Sheet {
        
        return Sheet.default
    }
    
    static var alert: Alert {
        
        return Alert.default
    }
    
    static var toast: Toast {
        return Toast.default
    }
    

}

// MARK: -Tool
public extension FunBox {

    static var cache: Cache {
        
        return Cache.default
    }
    
    static var device: UIDevice {
        return UIDevice.current
    }
}

// MARK: - CustomView
public typealias FunButton = FunBox.Button
extension FunBox {
    open class Button: UIButton {
        public enum Layout {
            case `default`
            case imageTop
            case imageLeft
            case imageBottom
            case imageRight
        }
        
        public var layout: Layout = .default
        
        public convenience init(_ layout: Layout) {
            self.init()
            
            self.layout = layout
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            guard let label_size = titleLabel?.frame.size,
                let image_size = imageView?.frame.size else { return }
            
            switch self.layout {
            case .imageTop:
                imageView?.center = CGPoint(x: center.x, y: image_size.height / 2.0 + 7.0)
                titleLabel?.bounds = CGRect(x: 0, y: 0, width: bounds.size.width - 6.0, height: bounds.size.height - label_size.height / 2.0 - 4)
                //                self.titleLabel.width = self.width - 6;
                titleLabel?.center = CGPoint(x: center.x, y: bounds.size.height - label_size.height / 2.0 - 4)
                
                titleLabel?.textAlignment = .center
            case .imageLeft:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
                
                titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
                
            case .imageBottom:
                imageView?.center = CGPoint(x: center.x, y: bounds.size.height - image_size.height / 2.0 - 4)
                
                titleLabel?.center = CGPoint(x: center.x, y: bounds.size.height - label_size.height / 2.0 + 4)
                
            case .imageRight:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: label_size.width + 4, bottom: 0, right: -label_size.width - 4)
                
                titleEdgeInsets = UIEdgeInsets(top: 0, left: -image_size.width - 4, bottom: 0, right: -image_size.width + 4)
                
            default:
                break
            }

        }
    }
}
