//
//  ScanModel.swift
//  FunBox
//
//  Created by choarkinphe on 2020/10/16.
//  Copyright © 2020 Konnech. All rights reserved.
//

import AVFoundation
import UIKit
#if !COCOAPODS
import FunBox
#endif

extension FunScan {
    
    struct Tips {
        static let title = "扫码"
        static let empty_code = "无法识别二维码"
        static let handleing = "处理中"
    }
    
    public struct Style {
        public  var boardColor: UIColor = .red
        
        public var boardWidth: CGFloat = 8.0
        
        public var tagImage: UIImage? = UIImage(named: "ic_scan_arrow", in: FunScan.bundle, compatibleWith: nil)
        
        public var scanInsets: UIEdgeInsets = UIEdgeInsets(top: 120, left: 0, bottom: 80, right: 0)
        
        public var title: String? = "扫一扫"
        
        static let `default` = Style()
        
        public init() {}
    }
    
    struct Result {
        var label: String?
        
        var stringValue: String?
    }
}
