//
//  FunHUD.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/31.
//

import UIKit



typealias FunHUD = FunBox.Toast
extension FunHUD {
    //    class HUD {
    enum `Type` {
        case info
        case error
        case success
        case loading
    }
    private static var window = UIApplication.shared.fb.currentWindow!
    static func dismiss(inView: UIView?=nil) {
        FunBox.toast.dismiss(inView: inView)
    }
    
    static func dismissActivity(inView: UIView?=nil) {
        FunBox.toast.dismissActivity(inView: inView ?? window)
    }
    
    static func toast(_ type: Type, message: String?, inView: UIView?=nil) {
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
