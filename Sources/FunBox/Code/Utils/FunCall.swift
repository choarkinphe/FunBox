//
//  FunCall.swift
//  FunBox
//
//  Created by 肖华 on 2020/12/24.
//

import MessageUI
import UIKit

public typealias FunCall = FunBox.Call
public protocol FunPhoneNumber {
    func asPhoneNumbers() -> [String]?
}
typealias PhoneNumbers = [String]
extension String: FunPhoneNumber {
    public func asPhoneNumbers() -> [String]? {
        return components(separatedBy: ",")
    }
}

extension PhoneNumbers: FunPhoneNumber {
    public func asPhoneNumbers() -> [String]? {
        return self
    }
}
extension FunBox {
    public class Call {
        
        public static func call(_ phone: String?, complete: ((Bool)->Void)?=nil) {
            guard let phone = phone, let url = "telprompt://\(phone)".realURL else {
//                FunBox.toast.template(.info).message(FunTips.noContactInformation).position(.center).show()
                FunHUD.toast(.info, message: FunTips.noContactInformation)
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: complete)
        }
        
        public static func sms(_ phone: FunPhoneNumber?, complete: ((Bool)->Void)?=nil) {
            guard let phone = phone else {
//                FunBox.toast.template(.info).message(FunTips.noContactInformation.fb.localized(in: FunBox.bundle)).position(.center).show()
                FunHUD.toast(.info, message: FunTips.noContactInformation)
                return
            }
            
            if MFMessageComposeViewController.canSendText() {
                let smsVC = MFMessageComposeViewController()
                
                // 设置短信内容
                smsVC.body = ""
                // 设置收件人列表
                smsVC.recipients = phone.asPhoneNumbers()  // 号码数组
                
                composeDelegate = SMSComposeDelegate()
                
                composeDelegate?.complete = { (success) in
                    composeDelegate = nil
                    complete?(success)
                }
                // 设置代理
                smsVC.messageComposeDelegate = composeDelegate
                // 显示控制器
                UIApplication.shared.fb.frontController?.present(smsVC, animated: true, completion: nil)
            }
            
        }
        
        private static var composeDelegate: SMSComposeDelegate?
        
    }
}

fileprivate class SMSComposeDelegate: UIViewController, MFMessageComposeViewControllerDelegate {
    
    var complete: ((Bool)->Void)?
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            self.complete?(true)
        }
    }
    
}
