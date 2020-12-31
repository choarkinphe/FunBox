//
//  FunBox+Tips.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/31.
//

import Foundation
typealias FunTips = FunBox.Tips
extension FunBox {
    struct Tips {
        static let tips = FunTips("Tips").localized
        static let noContactInformation = FunTips("NoContactInformation").localized
        static let cameraAuthorize = FunTips("CameraAuthorize").localized
        static let albumSaveAuthorize = FunTips("AlbumSaveAuthorize").localized
        static let albumAuthorize = FunTips("AlbumAuthorize").localized
        static let cancel = FunTips("Cancel").localized
        static let sure = FunTips("Sure").localized
        static let setting = FunTips("Setting").localized
        static let loadFailed = FunTips("LoadFailed").localized
        static let loading = FunTips("Loading").localized
        static let noData = FunTips("NoData").localized
        static let repairing = FunTips("Repairing").localized
        static let loadingException = FunTips("LoadingException").localized
        static let processing = FunTips("Processing").localized
        static let saving = FunTips("Saving").localized
        static let saveSuccess = FunTips("SaveSuccess").localized
        static let unknow = FunTips("Unknow").localized
        
        let localized: String
        init(_ rawValue: String, bundle: Bundle? = nil) {
            localized = rawValue.fb.localized(in: bundle ?? FunBox.bundle)
        }
    }
    
}
