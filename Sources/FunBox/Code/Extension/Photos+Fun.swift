//
//  Photos+Fun.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/22.
//

import UIKit
import Photos

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


public extension FunNamespaceWrapper where T: PHAsset {
//extension PHAsset {
    
    func requestAVAsset(_ complete: @escaping ((AVAsset?)->Void)) {
        let optionForCache = PHVideoRequestOptions()
        optionForCache.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: wrappedValue, options: optionForCache) { (avasset, audioMix, info) in
            DispatchQueue.main.async {
                complete(avasset)
            }
        }
        
    }
    
    func requestData(_ complete: @escaping ((Data?)->Void)) {
        if wrappedValue.mediaType == .video {
            
            requestAVAsset { (asset) in
                if let url = (asset as? AVURLAsset)?.url, let data = try? Data.init(contentsOf: url) {
                    complete(data)
                } else {
                    complete(nil)
                }
            }
        } else {
            PHImageManager.default().requestImageData(for: wrappedValue, options: nil) { (data, text, orientation, info) in
                if let data = data {
                    // 图片被旋转过，修正
                    if orientation != .up, let image = UIImage(data: data)?.fb.fixOrientation {
                        complete(image.jpegData(compressionQuality: 1.0))
                        
                    } else {
                        complete(UIImage(data: data)?.jpegData(compressionQuality: 1.0))
                    }
                } else {
                    complete(nil)
                }
            }
        }
    }
}
 


/*
public extension FunNamespaceWrapper where T: PHPhotoLibrary {
//extension PHPhotoLibrary {
    
    func collection(for albumName: String) -> PHAssetCollectionChangeRequest {
        var collection: PHAssetCollectionChangeRequest?
        // 1. 创建搜索集合
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        // 2. 遍历搜索集合并取出对应的相册，返回当前的相册changeRequest
        result.enumerateObjects { (assetCollection, index, pointer) in
            if let localizedTitle = assetCollection.localizedTitle, localizedTitle.contains(albumName) {
                
                collection = PHAssetCollectionChangeRequest(for: assetCollection)
            }
        }
        
        if let collection = collection {
            return collection
        }
        
        // 如果不存在，创建一个名字为albumName的相册changeRequest
        return PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
    }
    
    // 保存媒体资源
    static func save(to albumName: String? = UIApplication.shared.fb.appName, resource: FunPhotoResource?, complete: @escaping ((PHAsset)->Void)) {
        guard let albumName = albumName else { return }
        // 尝试获取相册保存权限
        FunBox.Authorize.Photo.save({ (status) in
            if status == .authorized {
                
                let library = PHPhotoLibrary.shared()
                
                var localIdentifier: String?
                
                library.performChanges({
                    // 创建一个相册变动请求
                    let collectionRequest = library.fb.collection(for: albumName)
                    
                    // 根据传入的照片，创建照片变动请求
                    let request = resource?.asChangeRequest()
                    
                    // 创建一个占位对象
                    if let placeholder = request?.placeholderForCreatedAsset {
                        localIdentifier = placeholder.localIdentifier
                        // 将占位对象添加到相册请求中
                        collectionRequest.addAssets(NSArray(object: placeholder))
                    }
                    
                }) { (success, error) in
                    DispatchQueue.main.async {
                        if success, let localIdentifier = localIdentifier {
                            if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                                complete(asset)
                            }
                            
                        } else {
                            FunBox.toast.template(.error).message(error?.localizedDescription).inView(UIApplication.shared.fb.currentWindow).show()
                        }
                    }
                }
                
            }
        })
    }
}
*/
//public protocol PhotoResource {
//    func asAssetRequest() -> PHAssetChangeRequest?
//}
//
//extension UIImage: PhotoResource {
//    public func asAssetRequest() -> PHAssetChangeRequest? {
//        return PHAssetChangeRequest.creationRequestForAsset(from: self)
//    }
//}

public protocol PhotoResource {
    func asChangeRequest() -> PHAssetChangeRequest?
}
//
//extension URL: PhotoResource {
//    public func asChangeRequest() -> PHAssetChangeRequest? {
//        guard isFileURL else { return nil}
//        if ["mp4","mov"].contains(pathExtension) {
//            return PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self)
//        }
//        return PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: self)
//    }
//}

extension UIImage: PhotoResource {
    public func asChangeRequest() -> PHAssetChangeRequest? {
        return PHAssetChangeRequest.creationRequestForAsset(from: self)
    }
}

extension URL: PhotoResource {
    
    public func asChangeRequest() -> PHAssetChangeRequest? {
    
        if isFileURL {
            // 获取文件类型
            let mimeType = fb.mimeType
            
            if mimeType.contains("video") {// 视频类型
                return PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self)
            } else if mimeType.contains("image") { // 图片类型
                return PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: self)
            }
        }
        
        return nil
    }
}

extension PHPhotoLibrary {
    
    public struct Album: Equatable {
        public let name: String
        public init(name: String) {
            self.name = name
        }
        
        public static var `default`: Album {
            
            if let title = UIApplication.shared.fb.appName {
                return Album(name: title)
            }
            
            return Album(name: "New")
        }
        
        func toCollectionRequest() -> PHAssetCollectionChangeRequest {
            var collection: PHAssetCollectionChangeRequest?
            // 1. 创建搜索集合
            let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
            // 2. 遍历搜索集合并取出对应的相册，返回当前的相册changeRequest
            result.enumerateObjects { (assetCollection, index, pointer) in
                if let localizedTitle = assetCollection.localizedTitle, localizedTitle.contains(name) {
                    
                    collection = PHAssetCollectionChangeRequest.init(for: assetCollection)
                }
            }
            
            if let collection = collection {
                return collection
            }
            
            // 如果不存在，创建一个名字为albumName的相册changeRequest
            return PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        }
        
        
    }
    
   
}


//extension PHPhotoLibrary: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == PHPhotoLibrary {
    //照片保存
    static func save(album: PHPhotoLibrary.Album = .default, resource: PhotoResource?, complete: @escaping (((asset: PHAsset?, error: Error?))->Void)) {
        guard let resource = resource else { return }
        // 尝试获取相册保存权限
        FunBox.Authorize.Photo.save({ (status) in
            if status == .authorized {
                
                let library = PHPhotoLibrary.shared()
                
                var localIdentifier: String?
                
                library.performChanges({
                    // 创建一个相册变动请求
                    let collectionRequest = album.toCollectionRequest()
                    
                    // 根据传入的照片，创建照片变动请求
                    let assetRequest = resource.asChangeRequest()
                    
                    // 创建一个占位对象
                    if let placeholder = assetRequest?.placeholderForCreatedAsset {
                        localIdentifier = placeholder.localIdentifier
                        // 将占位对象添加到相册请求中
                        collectionRequest.addAssets(NSArray(object: placeholder))
                    }
                    
                }) { (success, error) in
                    
                    if success, let localIdentifier = localIdentifier, let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                        DispatchQueue.main.async {
                            
                            complete((asset,error))
                        }
                        
                        
                    } else {
                        DispatchQueue.main.async {
                            
                            complete((nil,error))
                        }
                        
                    }
                }
                
            }
        })
    }
}
