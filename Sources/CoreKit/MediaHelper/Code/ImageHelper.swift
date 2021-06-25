//
//  ImageHelper.swift
//  HZCoreKit_Example
//
//  Created by choarkinphe on 2020/9/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import TZImagePickerController
import JXPhotoBrowser
import Photos
import UIKit
public typealias ImageHelper = MediaHelper.Image
extension MediaHelper {
    public class Image: NSObject {
        
        private let picker: TZImagePickerController?
        
        required public override init() {
            picker = TZImagePickerController(maxImagesCount: 9, delegate: nil)
            super.init()
            if let picker = picker {
                
                picker.pickerDelegate = self
                picker.modalPresentationStyle = .fullScreen
                
                // 最长允许拍摄30s视频
                picker.videoMaximumDuration = 30
                
                // 是否允许选择视频
                picker.allowPickingVideo = true
                
                // 设置默认语言
                picker.preferredLanguage = "zh-Hans"
                // 当照片选择张数达到上限时，其它照片置灰
                picker.showPhotoCannotSelectLayer = true
                // pick不会自己dismiss
                picker.autoDismiss = false
                
                picker.uiImagePickerControllerSettingBlock = { (vc) in
                    vc?.showsCameraControls = true
                    vc?.allowsEditing = false
                    vc?.videoQuality = .typeHigh
                }
                
                picker.imagePickerControllerDidCancelHandle = {
                    
                    picker.dismiss(animated: true) {
                        
                    }
                }
            }
            
        }
        
        public static var `default`: ImageHelper {
            
            let helper = ImageHelper()
            
            return helper
        }
        
        public func maxImagesCount(_ count: Int) -> Self {
            picker?.maxImagesCount = count
            return self
        }
        
        public func allowPickingVideo(_ allowPickingVideo: Bool) -> Self {
            picker?.allowPickingVideo = allowPickingVideo
            return self
        }
        
        
        
        public func response<T>(sourceType: T.Type, complete: @escaping ([T]?)->Void) where T: PickResource {
            
            if let picker = picker {
                
                
                picker.didFinishPickingPhotosWithInfosHandle = { (photos, assets, isSelectOriginalPhoto, infos) in
                    
                    picker.dismiss(animated: false) {
                        if let photos = photos, let assets = assets, photos.count == assets.count {
                            var resource = [T]()
                            for (index,asset) in assets.enumerated() {
                                var item = T()
                                
                                item.image = photos[index]
                                item.asset = asset as? PHAsset
                                resource.append(item)
                                //                                resource.append((photos[index],asset as? PHAsset))
                            }
                            DispatchQueue.main.async {
                                complete(resource)
                            }
                        }
                    }
                }
                
                picker.didFinishPickingVideoHandle = { (coverImage, asset) in
                    
                    guard let asset = asset else { return }
                    
                    let editor = VideoEditor()
                    editor.source = asset
                    editor.completion { (result) in
                        picker.dismiss(animated: false) {
                            
                            var resource = T()
                            resource.image = coverImage
                            resource.asset = asset
                            complete([resource])
                        }
                    }
                    picker.pushViewController(editor, animated: true)
                }
                
                
                
                UIApplication.shared.fb.frontController?.present(picker, animated: true, completion: nil)
            }
        }
        
        @available(*, deprecated, message: "use func response(complete: @escaping Handler) instand of it")
        public func picker(complete: @escaping Handler) {
            
            response(sourceType: PickElement.self) { (resource) in
                var result = [MediaHelper.Resource]()
                resource?.forEach({ (item) in
                    result.append((item.image,item.asset))
                })
                complete(result)
            }
        }
        
        deinit {
            debugPrint("ImageHelper die")
        }
    }
}

public protocol PickResource {
    var image: UIImage? { get set }
    var asset: PHAsset? { get set }
    init()
}

extension ImageHelper: HandyJSON {
    struct PickElement: PickResource {
        var image: UIImage?
        var asset: PHAsset?
    }
}

extension ImageHelper: TZImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
    }
    
}
/*
public protocol PHPhotoResource {
    func asChangeRequest() -> PHAssetChangeRequest?
}

extension URL: PHPhotoResource {
    public func asChangeRequest() -> PHAssetChangeRequest? {
        guard isFileURL else { return nil}
        if ["mp4","mov"].contains(pathExtension) {
            return PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self)
        }
        return PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: self)
    }
}

extension UIImage: PHPhotoResource {
    public func asChangeRequest() -> PHAssetChangeRequest? {
        return PHAssetChangeRequest.creationRequestForAsset(from: self)
    }
}

extension PHPhotoLibrary {
    
    private func collection(for albumName: String) -> PHAssetCollectionChangeRequest {
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
    static func save(to albumName: String? = UIApplication.shared.fb.appName, resource: PHPhotoResource?, complete: @escaping ((PHAsset)->Void)) {
        guard let albumName = albumName else { return }
        // 尝试获取相册保存权限
        FunBox.Authorize.Photo.save({ (status) in
            if status == .authorized {
                
                let library = PHPhotoLibrary.shared()
                
                var localIdentifier: String?
                
                library.performChanges({
                    // 创建一个相册变动请求
                    let collectionRequest = library.collection(for: albumName)
                    
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
                            HZHUD.toast(.error, message: error?.localizedDescription)
                        }
                    }
                }
                
            }
        })
    }
    
    //视频保存
    static func saveVideo(albumName: String?, localPath: URL?, complete: @escaping ((PHAsset)->Void)) {
        guard let albumName = albumName, let localPath = localPath else { return }
        // 尝试获取相册保存权限
        FunBox.Authorize.Photo.save({ (status) in
            if status == .authorized {
                
                let library = PHPhotoLibrary.shared()
                
                var localIdentifier: String?
                
                library.performChanges({
                    // 创建一个相册变动请求
                    let collectionRequest = library.collection(for: albumName)
                    
                    // 根据传入的照片，创建照片变动请求
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localPath)
                    
                    // 创建一个占位对象
                    if let placeholder = assetRequest?.placeholderForCreatedAsset {
                        localIdentifier = placeholder.localIdentifier
                        // 将占位对象添加到相册请求中
                        collectionRequest.addAssets(NSArray(object: placeholder))
                    }
                    
                }) { (success, error) in
                    
                    if success, let localIdentifier = localIdentifier {
                        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                            complete(asset)
                        }
                        
                    }
                }
                
            }
        })
    }
}
*/
