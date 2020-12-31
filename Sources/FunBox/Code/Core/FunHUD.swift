//
//  FunHUD.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/31.
//

import UIKit



public typealias FunHUD = FunBox.Toast
extension FunHUD {
    //    class HUD {
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
    //    }
}

//fileprivate extension String {
//    var localized: String { return fb.localized(in: FunBox.bundle) }
//}
