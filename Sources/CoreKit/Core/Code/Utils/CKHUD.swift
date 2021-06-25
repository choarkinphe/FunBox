//
//  CKHUD.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/9.
//

import Foundation
#if !COCOAPODS
import FunBox
#endif

public typealias CKHUD = Service.HUD
extension Service {
    public class HUD: NSObject {
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
                FunBox.toast.message(message).inView(inView ?? window).position(.center).image(UIImage(named: "Toast_tips_info", in: CoreKit.bundle, compatibleWith: nil)).show()
            case .success:
                FunBox.toast.message(message).inView(inView ?? window).position(.center).image(UIImage(named: "Toast_tips_done", in: CoreKit.bundle, compatibleWith: nil)).show()
            case .error:
                FunBox.toast.message(message).inView(inView ?? window).position(.center).image(UIImage(named: "Toast_tips_error", in: CoreKit.bundle, compatibleWith: nil)).show()
            case .loading:
                FunBox.toast.message(message).inView(inView ?? window).position(.center).mode(.activity).show()
            }
        }
    }
}

