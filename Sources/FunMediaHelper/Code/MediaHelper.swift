//
//  MediaHelper.swift
//  Pods
//
//  Created by choarkinphe on 2020/9/10.
//

import Photos
import UIKit
#if !COCOAPODS
import FunBox
#endif

public typealias FunMediaHelper = FunBox.MediaHelper
extension FunBox {
    public class MediaHelper {
        public typealias Resource = (image: UIImage?,asset: PHAsset?)
        public typealias Handler = ([Resource]?)->Void
        
    }
}
extension FunMediaHelper {
    public static var bundle: Bundle? {
        
        if let url = Bundle(for: self).url(forResource: "MediaHelper", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
}

extension FunMediaHelper {
    public static func preview(resource: [FunMediaHelper.Resource], index: Int) {
        
        trans(for: resource) { (sources) in
            preview(resource: sources, index: index)
        }
    }
    
    static func trans(for resource: [FunMediaHelper.Resource], complete: @escaping (([UIImage])->Void)) {
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

