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
public typealias FunImageHelper = FunMediaHelper.Image
extension FunMediaHelper {
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
        
        public static var `default`: FunImageHelper {
            
            let helper = FunImageHelper()
            
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
        
        
        
        public func response<T>(sourceType: T.Type, complete: @escaping ([T]?)->Void) where T: FunPickResource {
            
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
                    
//                    let editor = VideoEditor()
//                    editor.source = asset
//                    editor.completion { (result) in
//                        picker.dismiss(animated: false) {
//
//                            var resource = T()
//                            resource.image = coverImage
//                            resource.asset = asset
//                            complete([resource])
//                        }
//                    }
//                    picker.pushViewController(editor, animated: true)
                }
                
                
                
                UIApplication.shared.fb.frontController?.present(picker, animated: true, completion: nil)
            }
        }
        
        
        deinit {
            debugPrint("ImageHelper die")
        }
    }
}

public protocol FunPickResource {
    var image: UIImage? { get set }
    var asset: PHAsset? { get set }
    init()
}

extension FunImageHelper {
    struct PickElement: FunPickResource {
        var image: UIImage?
        var asset: PHAsset?
    }
}

extension FunImageHelper: TZImagePickerControllerDelegate {
    public func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
    }
}

