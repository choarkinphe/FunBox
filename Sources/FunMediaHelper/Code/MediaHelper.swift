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
        
        public static var bundle: Bundle? {
            
            if let url = Bundle(for: self).url(forResource: "MediaHelper", withExtension: "bundle") {
                return Bundle(url: url)
                
            } else if let url = Bundle(for: FunBox.self).path(forResource: "FunBox_FunMediaHelper.bundle", ofType: nil) {
                return Bundle(path: url)
            }
            return nil
        }
    }
    
}

extension FunTips {
    static let transcoding = FunTips("Transcoding", bundle: FunMediaHelper.bundle).localized
    
}
