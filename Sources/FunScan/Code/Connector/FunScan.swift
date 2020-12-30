//
//  ScanAPI.swift
//  hangzhou-pd
//
//  Created by jiang junhui on 2020/10/16.
//  Copyright © 2020 Konnech. All rights reserved.
//

import AVFoundation
import UIKit
#if !COCOAPODS
import FunBox
#endif

public typealias FunScan = FunBox.Scan
extension FunBox {
    public class Scan: FunModuleProtocol {
        
        public typealias Handle<T> = (((content: T?, dismiss: ((Bool)->Void)))->Void) where T: FunURLConvertable
        
        public static var bundle: Bundle? {
            if let url = Bundle(for: self).url(forResource: "FunScan", withExtension: "bundle") {
                return Bundle(url: url)
            } else if let url = Bundle(for: FunBox.self).path(forResource: "FunBox_FunScan.bundle", ofType: nil) {
                return Bundle(path: url)
            }
            return nil
        }
        
        private var scaner: FunScanController?
        
        public init() {
            scaner = FunScanController()
            scaner?.modalPresentationStyle = .overFullScreen
        }
        
        public func feed(style: Style) -> Self {
            scaner?.style = style
            return self
        }
        
        public func response(navigation: @escaping Handle<String>) {
            // 首先检测权限
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            // 未授权的先跳转去设置再说
            if status == .restricted || status == .denied {
                FunBox.alert.title("提示\n").message("请去-> [设置 - 隐私 - 相机 - 打开访问开关").addAction(title: "拒绝", style: .cancel).addAction(title: "设置", style: .default) { (action) in
                    if let URL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
                    }
                }.present()
                
                return
            }
            
            if let scaner = scaner {
                
                scaner.handle = { (result) in
                    let dismiss = { (finished: Bool) in
                        if finished {
                            scaner.dismiss()
                        } else {
                            scaner.start()
                        }
                    }
                    navigation((result,dismiss))
                }
                
                scaner.show()
                
            }
            
        }
    }
}
extension FunScan {
    
    // 默认类
    public static var `default`: FunScan {
        let instance = FunScan()
        return instance
    }
}
