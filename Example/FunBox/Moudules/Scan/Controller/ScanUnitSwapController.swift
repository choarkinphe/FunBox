//
//  ScanUnitSwapController.swift
//  PollCall
//
//  Created by choarkinphe on 2020/12/29.
//  Copyright © 2020 Konnech Inc'. All rights reserved.
//

import UIKit
//import FunUI
//import FunMediaHelper
import SnapKit
import Photos
struct ScanUnitSwap {
    var deviceID: String?
    var brokenUnit: String?
    var replacementUnit: String?
    var notes: String?
    
}


class ScanUnitSwapController: UIViewController {
    var unitSwapModel = ScanUnitSwap()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        fb.contentInsets = UIEdgeInsets(top: 88, left: 0, bottom: 0, right: 0)
        
        fb.contentView = contentView
        fb.bottomView = bottomView
        
        let broken = ScanInputer(title: "Scan Broken Unit:")
        broken.textChanged { [weak self] (text) in
            self?.unitSwapModel.brokenUnit = text
        }
        contentView.addSubview(broken)
        broken.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.left.right.equalTo(view)
            make.height.equalTo(88)
        }
        
        let replacement = ScanInputer(title: "Scan Replacement Unit:")
        replacement.textChanged { [weak self] (text) in
            self?.unitSwapModel.replacementUnit = text
        }
        contentView.addSubview(replacement)
        replacement.snp.makeConstraints { (make) in
            make.left.height.right.equalTo(broken)
            make.top.equalTo(broken.snp.bottom).offset(32)
        }
        
        let notes = PCInputCard(title: "Notes:")
        notes.textChanged { [weak self] (text) in
            self?.unitSwapModel.notes = text
        }
        contentView.addSubview(notes)
        notes.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(replacement.snp.bottom).offset(32)
            make.height.greaterThanOrEqualTo(120)
        }
        
        let imagelayout = FunMediaHelper.ImageLayoutView<PCImageResource>(frame: .zero)
        imagelayout.maxCount = 5
        imagelayout.layout.flowCount = 5
        imagelayout.add {
            FunImageHelper.default.maxImagesCount(5-imagelayout.resource.count).response(sourceType: PCImageResource.self) { (resource) in
                if let resource = resource {
                    imagelayout.add(resource: resource)
                }
            }
        }
        contentView.addSubview(imagelayout)
        imagelayout.snp.makeConstraints { (make) in
            make.left.right.equalTo(notes)
//            make.right.equalTo(-12)
            make.top.equalTo(notes.snp.bottom).offset(12)
            make.height.equalTo(view.snp.width).multipliedBy(0.25).offset(-6)
            make.bottom.equalTo(-34)
        }
    }
    
    lazy var contentView: UIScrollView = {
        let contentView = UIScrollView()
        return contentView
    }()
    
    lazy var bottomView: UIView = {
        let button = UIButton()
        
        button.backgroundColor = .blue
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        return UIView(bottomView: button)
    }()
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
}


struct PCImageResource: FunMediaPreviewResource, FunPickResource {
    var image: UIImage?
    
    var asset: PHAsset?
    
    var source_image: UIImage? {
        return image
    }
    
    var source_url: String?
    
    var source_asset: PHAsset? {
        return asset
    }
}
