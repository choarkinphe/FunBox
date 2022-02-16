//
//  MediaHelper.swift
//  Pods
//
//  Created by choarkinphe on 2020/9/10.
//

import Photos
import UIKit
import FunBox

public class MediaHelper {
    public typealias Resource = (image: UIImage?,asset: PHAsset?)
    public typealias Handler = ([Resource]?)->Void
    
}
extension MediaHelper: HZModuleProtocol {
    public static var bundle: Bundle? {
        
        if let url = Bundle(for: self).url(forResource: "MediaHelper", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
}

extension MediaHelper {
    public static func preview(resource: [MediaHelper.Resource], index: Int) {
        
        trans(for: resource) { (sources) in
            preview(resource: sources, index: index)
        }
    }
    
    static func trans(for resource: [MediaHelper.Resource], complete: @escaping (([UIImage])->Void)) {
        var sources = [UIImage]()
        
        let group = DispatchGroup()
        resource.forEach { (item) in
            if let image = item.image {
                group.enter()
                sources.append(image)
                group.leave()
            } else if let asset = item.asset {
                group.enter()
                asset.fb.requestData { (data) in
                    if let data = data, let image = UIImage(data: data) {
                        sources.append(image)
                        group.leave()
                    }
                }
//                asset.data { (data) in
//                    if let data = data, let image = UIImage(data: data) {
//                        sources.append(image)
//                        group.leave()
//                    }
//                }
            }
        }
        
        group.notify(queue: .main) {
            complete(sources)
        }
    }
}

// 数据转换
/*
extension PHAsset {
    
    public func trans2AVAsset(_ complete: @escaping ((AVAsset?)->Void)) {
        let optionForCache = PHVideoRequestOptions()
        optionForCache.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: self, options: optionForCache) { (avasset, audioMix, info) in
            DispatchQueue.main.async {
                complete(avasset)
            }
        }
        
    }
    
    public func data(_ complete: @escaping ((Data?)->Void)) {
        if mediaType == .video {
            
            trans2AVAsset { (asset) in
                if let url = asset?.asURLAsset()?.url, let data = try? Data.init(contentsOf: url) {
                    complete(data)
                } else {
                    complete(nil)
                }
            }
        } else {
            PHImageManager.default().requestImageData(for: self, options: nil) { (data, text, orientation, info) in
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
 */
