//
//  HZEditViewController.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/11/3.
//

import Foundation
import Photos

extension HZEditor {
    // 内部内容
    struct Content: HZEditContentable {
        var text: String?
        var medias: [HZEditorImage]?
    }

    // 内部媒体资源对象
    struct MediaElement: HZEditorImage, MediaPreviewResource {
        var source_image: UIImage? {
            return image
        }
        
        var source_url: String? {
            return url
        }
        
        var image: UIImage?
        
        var asset: PHAsset?
        
        var url: String?
    }
    
}
