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
