//
//  Photos+Fun.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/22.
//

import UIKit
import Photos
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
 

public protocol FunPhotoResource {
    func asChangeRequest() -> PHAssetChangeRequest?
}

extension URL: FunPhotoResource {
    public func asChangeRequest() -> PHAssetChangeRequest? {
        guard isFileURL else { return nil}
        if ["mp4","mov"].contains(pathExtension) {
            return PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self)
        }
        return PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: self)
    }
}

extension UIImage: FunPhotoResource {
    public func asChangeRequest() -> PHAssetChangeRequest? {
        return PHAssetChangeRequest.creationRequestForAsset(from: self)
    }
}

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

