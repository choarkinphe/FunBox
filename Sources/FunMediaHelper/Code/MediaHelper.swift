//
//  MediaHelper.swift
//  Pods
//
//  Created by choarkinphe on 2020/9/10.
//

import Photos
import UIKit
#if !COCOAPODS
import FunBox
#endif

public typealias FunMediaHelper = FunBox.MediaHelper
typealias HUD = FunBox.HUD
extension FunBox {
    public class MediaHelper {
        
        public static var bundle: Bundle? {
            
            if let url = Bundle(for: self).url(forResource: "MediaHelper", withExtension: "bundle") {
                return Bundle(url: url)
                
            } else if let url = Bundle(for: FunBox.self).path(forResource: "FunBox_FunMediaHelper.bundle", ofType: nil) {
                return Bundle(path: url)
            }
            return nil
        }
    }
    
    class HUD: NSObject {
        public enum `Type` {
            case info
            case error
            case success
            case loading
        }
        private static var window = UIApplication.shared.fb.currentWindow!
        public static func dismiss(inView: UIView?=nil) {
            FunBox.toast.dismiss(inView: inView)
        }
        
        public static func dismissActivity(inView: UIView?=nil) {
            FunBox.toast.dismissActivity(inView: inView ?? window)
        }
        
        public static func toast(_ type: Type, message: String?, inView: UIView?=nil) {
            dismiss(inView: inView)
            
            switch type {
                case .info:
                    FunBox.toast.template(.info).message(message).inView(inView ?? window).position(.center).show()
                case .success:
                    FunBox.toast.template(.done).message(message).inView(inView ?? window).position(.center).show()
                case .error:
                    FunBox.toast.template(.error).message(message).inView(inView ?? window).position(.center).show()
                case .loading:
                    FunBox.toast.message(message).inView(inView ?? window).position(.center).mode(.activity).show()
            }
        }
    }
}
