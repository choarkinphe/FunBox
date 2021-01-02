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
//    public enum `Type` {
//        case info
//        case error
//        case success
//        case loading
//    }
    private static var window = UIApplication.shared.fb.currentWindow!
    public static func dismiss(inView: UIView?=nil) {
        FunBox.toast.dismiss(inView: inView)
    }
    
    public static func dismissActivity(inView: UIView?=nil) {
        FunBox.toast.dismissActivity(inView: inView ?? window)
    }
    
    public static func toast(_ template: Template, message: String?, inView: UIView?=nil) {
        dismiss(inView: inView)
        FunToast(template).message(message).inView(inView ?? window).position(.center).show()
//        FunBox.toast.template(template).message(message).inView(inView ?? window).position(.center).show()
//        switch type {
//            case .info:
//            case .success:
//                FunBox.toast.template(.done).message(message).inView(inView ?? window).position(.center).show()
//            case .error:
//                FunBox.toast.template(.error).message(message).inView(inView ?? window).position(.center).show()
//            case .loading:
//                FunBox.toast.message(message).inView(inView ?? window).position(.center).mode(.activity).show()
//        }
    }
    //    }
}

extension FunHUD.Template {
    public static let success = FunHUD.Template.done
}

//fileprivate extension String {
//    var localized: String { return fb.localized(in: FunBox.bundle) }
//}
