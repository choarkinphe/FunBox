//
//  FunBox+Tips.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/31.
//

import Foundation
public typealias FunTips = FunBox.Tips
extension FunBox {
    public struct Tips {
        public static let tips = FunTips("Tips").localized
        public static let noContactInformation = FunTips("NoContactInformation").localized
        public static let cameraAuthorize = FunTips("CameraAuthorize").localized
        public static let albumSaveAuthorize = FunTips("AlbumSaveAuthorize").localized
        public static let albumAuthorize = FunTips("AlbumAuthorize").localized
        public static let cancel = FunTips("Cancel").localized
        public static let sure = FunTips("Sure").localized
        public static let setting = FunTips("Setting").localized
        public static let loadFailed = FunTips("LoadFailed").localized
        public static let loading = FunTips("Loading").localized
        public static let noData = FunTips("NoData").localized
        public static let repairing = FunTips("Repairing").localized
        public static let notFound = FunTips("NotFound").localized
        public static let processing = FunTips("Processing").localized
        public static let saving = FunTips("Saving").localized
        public static let saveSuccess = FunTips("SaveSuccess").localized
        public static let unknow = FunTips("Unknow").localized
        
        public let localized: String
        public init(_ rawValue: String, bundle: Bundle? = nil) {
            localized = rawValue.fb.localized(in: bundle ?? FunBox.bundle)
        }
    }
    
}
