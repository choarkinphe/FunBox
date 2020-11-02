//
//  FunAuthorize.swift
//  CommunityCircle
//
//  Created by choarkinphe on 2020/8/10.
//  Copyright © 2020 Konnech. All rights reserved.
//

import Foundation
import Photos
public typealias FunAuthorize = FunBox.Authorize
public extension FunBox {
    // 获取权限
    struct Authorize { }
}

// Photo的相关权限
public extension FunAuthorize {
       class Photo {
        // 保存照片权限
        public static func save(_ clouse: @escaping (PHAuthorizationStatus)->Void) {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized || status == .notDetermined {
                    clouse(.authorized)
                } else {
                    
                    clouse(status)
                }
            })
        }
            // 获取相册权限
            static func library(_ clouse: @escaping (PHAuthorizationStatus)->Void) {
                let status = PHPhotoLibrary.authorizationStatus()
                
                if status == .authorized {
                    clouse(status)
                } else if status == .notDetermined { // 未授权，请求授权
                    PHPhotoLibrary.requestAuthorization({ (state) in
                        DispatchQueue.main.async(execute: {
                            clouse(state)
                        })
                    })
                    
                    clouse(status)
                } else {
                    FunBox.alert.title("照片访问受限").message("点击“设置”，允许访问您的照片").addAction(title: "取消", style: .cancel).addAction(title: "设置", style: .default) { (action) in
                        let url = URL(string: UIApplication.openSettingsURLString)
                        if let url = url, UIApplication.shared.canOpenURL(url) {
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(url, options: [:],
                                                          completionHandler: {
                                                            (success) in
                                })
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }.present()
                    
                    clouse(status)
                }
            }
        }
        
        // 用户是否开启相机权限
        static func camera(_ clouse: @escaping (AVAuthorizationStatus)->Void){
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if status == .authorized{
               clouse(status)
            } else if status == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {  // 允许
                        clouse(.authorized)
                    }
                })
            } else {
                
                FunBox.alert.title("相机访问受限").message("点击“设置”，允许访问您的相机").addAction(title: "取消", style: .cancel).addAction(title: "设置", style: .default) { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(url, options: [:],
                                                      completionHandler: {
                                                        (success) in
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }.present()
                
                clouse(status)
            }
            
        }
        
    
}


public extension FunBox {
    struct Options {
        struct Application {
            static func openExternalURL(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
                return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
            }
        }
        
    }
}

