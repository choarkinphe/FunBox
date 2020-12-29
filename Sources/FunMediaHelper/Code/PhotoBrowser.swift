//
//  PhotoBrowser.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/10/30.
//
#if !COCOAPODS
import FunBox
import FunWebImage
import FunUI
#endif
import JXPhotoBrowser
import Photos
import UIKit

public typealias FunPhotoBrowser = FunMediaHelper.PhotoBrowser

public protocol FunMediaPreviewResource {
    var source_image: UIImage? { get }
    var source_url: String? { get }
    var source_asset: PHAsset? { get }
    var mediaType: PHAssetMediaType? { get }
}

extension FunMediaPreviewResource {
    public var mediaType: PHAssetMediaType? {
        if let asset = source_asset {
            return asset.mediaType
        }
        if let source_url = source_url,
           let mimeType = URL(string: source_url)?.fb.mimeType.lowercased() {
            if mimeType.contains("video") {
                return .video
            } else if mimeType.contains("au") {
                return .audio
            } else if mimeType.contains("image") {
                return .image
            }
        }
        return .image
    }
    
    public var source_asset: PHAsset? {
        return nil
    }
}

extension FunMediaHelper {
    
    public static func preview(resource: [FunMediaPreviewResource?], index: Int=0) {
        let browser = PhotoBrowser(resource: resource)
        
        browser.pageIndex = index
        
        browser.show()
    }
}

// MARK: - PhotoBrowser
extension FunMediaHelper {
    
    public class PhotoBrowser: JXPhotoBrowser {
        
        var resource: [FunMediaPreviewResource?]?
        init(resource: [FunMediaPreviewResource?]?=nil) {
            super.init()
            self.resource = resource
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        let moreButton = UIButton()
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            pageIndicator = JXPhotoBrowserNumberPageIndicator()
            
            moreButton.addTarget(self, action: #selector(moreAction(sender:)), for: .touchUpInside)
            
            moreButton.setImage(UIImage(named: "fb_nav_more", in: FunBox.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            moreButton.tintColor = .white
            
            view.addSubview(moreButton)
            
            browserView.cellClassAtIndex = { index in
                
                return ImageCell.self
            }
            
            numberOfItems = { [weak self] in
                return (self?.resource?.count ?? 0)
            }
            
            reloadCellAtIndex = { [weak self] context in
                let browserCell = context.cell as? PhotoBrowser.ImageCell
                //            let indexPath = IndexPath(item: context.index, section: indexPath.section)
                browserCell?.set(resource: self?.resource?[context.index])
                
                self?.moreHandler = { (action) in
                    if let image = browserCell?.imageView.image {
                        PHPhotoLibrary.fb.save(resource: image) { (asset) in
                            
                            HUD.toast(.success, message: "保存成功")
                            
                        }
                    }
                }
            }
        }
        
        var moreHandler: ((UIAlertAction)->Void)?
        
        @objc private func moreAction(sender: UIButton) {
            DispatchQueue.main.async {
                FunBox.alert.style(.actionSheet).title("提示").addAction(title: "保存", style: .default, handler: self.moreHandler).addAction(title: "取消", style: .cancel).present()
            }
        }
        
        public override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            view.bringSubviewToFront(moreButton)
            pageIndicator?.frame = CGRect(x: view.center.x - 70, y: fb.safeAeraInsets.top + 10, width: 140, height: 44)
            moreButton.frame = CGRect(x: view.bounds.width - 66, y: pageIndicator?.frame.minY ?? fb.safeAeraInsets.top + 10, width: 44, height: 44)
        }
        
        class ImageCell: JXPhotoBrowserImageCell {
            
            override func setup() {
                super.setup()
                addSubview(progressView)
            }
            
            private lazy var progressView: ProgressView = {
                let progressView = ProgressView()
                return progressView
            }()
            
            private lazy var playButton: UIButton = {
                let playButton = UIButton()
                
                playButton.setImage(UIImage(named: "video_editor_play.png", in: FunMediaHelper.bundle, compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .normal)
                playButton.tintColor = .white
                playButton.addTarget(self, action: #selector(to_play(sender:)), for: .touchUpInside)
                imageView.addSubview(playButton)
                imageView.isUserInteractionEnabled = true
                playButton.isHidden = true
                
                return playButton
            }()
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                progressView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
                
                playButton.frame = CGRect(x: 0, y: 0, width: 54, height: 54)
                playButton.center = CGPoint(x: imageView.center.x, y: imageView.bounds.height / 2.0)
                bringSubviewToFront(playButton)
                
            }
            
            private var playAction: ((UIButton)->Void)?
            func set(resource: FunMediaPreviewResource?) {
                if let image = resource?.source_image {
                    imageView.image = image
                } else if let url = resource?.source_url {
                    imageView.fb.webImageSource(url).options([.transition(.fade(0.5))]).progress { [weak self]  (received, total) in
                        // progress
                        let progress = CGFloat(received)/CGFloat(total)
                        self?.progressView.progress = progress
                        self?.progressView.isHidden = false
                    }.response { [weak self] (result) in
                        DispatchQueue.main.async {
                            self?.imageView.image = result.image
                            self?.progressView.isHidden = true
                            self?.setNeedsLayout()
                        }
                    }
                    
                    if url.hasSuffix("mp4") {
                        playButton.isHidden = false
                        playAction = { (sender) in
                            let player = VideoViewController(resource: url)
                            
                            UIApplication.shared.fb.frontController?.present(player, animated: false, completion: {
                                
                            })
                        }
                    } else {
                        playButton.isHidden = true
                    }
                    
                }
                
            }
            
            @objc private func to_play(sender: UIButton) {
                playAction?(sender)
                
            }
        }
        
    }
}

extension FunPhotoBrowser.ImageCell {
    /// 加载进度环
    fileprivate class ProgressView: UIView {
        
        /// 进度
        var progress: CGFloat = 0 {
            didSet {
                DispatchQueue.main.async {
                    self.fanshapedLayer.path = self.makeProgressPath(self.progress).cgPath
                    if self.progress >= 1.0 || self.progress < 0.01 {
                        self.isHidden = true
                    } else {
                        self.isHidden = false
                    }
                }
            }
        }
        
        /// 外边界
        private var circleLayer: CAShapeLayer!
        
        /// 扇形区
        private var fanshapedLayer: CAShapeLayer!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            if self.frame.size.equalTo(.zero) {
                self.frame.size = CGSize(width: 50, height: 50)
            }
            setupUI()
            progress = 0
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupUI() {
            backgroundColor = UIColor.clear
            let strokeColor = UIColor(white: 1, alpha: 0.8).cgColor
            
            circleLayer = CAShapeLayer()
            circleLayer.strokeColor = strokeColor
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.path = makeCirclePath().cgPath
            layer.addSublayer(circleLayer)
            
            fanshapedLayer = CAShapeLayer()
            fanshapedLayer.fillColor = strokeColor
            layer.addSublayer(fanshapedLayer)
        }
        
        private func makeCirclePath() -> UIBezierPath {
            let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
            let path = UIBezierPath(arcCenter: arcCenter, radius: 25, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            path.lineWidth = 2
            return path
        }
        
        private func makeProgressPath(_ progress: CGFloat) -> UIBezierPath {
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius = bounds.midY - 2.5
            let path = UIBezierPath()
            path.move(to: center)
            path.addLine(to: CGPoint(x: bounds.midX, y: center.y - radius))
            path.addArc(withCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2 + CGFloat.pi * 2 * progress, clockwise: true)
            path.close()
            path.lineWidth = 1
            return path
        }
    }
}

extension String: FunMediaPreviewResource {
    public var source_image: UIImage? { return nil }
    public var source_url: String? { return self }
}

extension UIImage: FunMediaPreviewResource {
    public var source_image: UIImage? { return self }
    public var source_url: String? { return nil }
}

extension FunMediaHelper {
    
    fileprivate static let ImageLayoutViewCellID = "com.funbox.mediahelper.imageLayout.cell.id"
    public class ImageLayoutView<T>: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource where T: FunMediaPreviewResource {
        
        public var layout: FunWaterFallLayout

        public init(frame: CGRect) {
            self.layout = FunWaterFallLayout()
            super.init(frame: frame, collectionViewLayout: layout)
            
            layout.flowCount = 3
            layout.itemSize { [weak self] (indexPath) -> CGSize in
                guard let this = self else { return .zero }
                let width = this.layout.flowWidth
                let height = this.layout.flowWidth
//                if self?.mediaType == .video, let video = self?.resource?.first, !video.isAdd {
//                    self.layout.flowCount = 2
//                    if let image = video.image {
//                        height = image.size.height / image.size.width * layout.flowWidth
//                    } else if video.height > 0,
//                              video.width > 0 {
//                        height = video.height / video.width * layout.flowWidth
//                    }
//                }
                
                return CGSize(width: width, height: height)
            }
            
            backgroundColor = .clear
            isScrollEnabled = false
            register(Cell.self, forCellWithReuseIdentifier: FunBox.MediaHelper.ImageLayoutViewCellID)
            delegate = self
            dataSource = self
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            superview?.endEditing(true)
        }
        
        public var maxCount: Int = 9
        
        public private(set) var resource: [T]?
        
        public func set(resource: [T]) {
            self.resource = resource
            reloadData()
        }
        
        private var add: (()->Void)?
        public func add(_ handle: (()->Void)?) {
            add = handle
        }
        
        private var preview: (((index: Int, item: T))->Void)?
        public func preview(_ handle: @escaping (((index: Int, item: T))->Void)) {
            preview = handle
        }
        
        class Cell: UICollectionViewCell {
            var imageV = UIImageView()
            var del_button = UIButton()
            override init(frame: CGRect) {
                super.init(frame: frame)
                imageV.contentMode = .scaleAspectFill
                imageV.layer.masksToBounds = true
                contentView.addSubview(imageV)
                
                del_button.setImage(UIImage(named: "cc_close"), for: .normal)
                del_button.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside)
                contentView.addSubview(del_button)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                imageV.frame = bounds
                del_button.frame = CGRect(x: bounds.width - 22, y: 2, width: 20, height: 20)
                del_button.accessibilityFrame = CGRect(x: bounds.width - 30, y: 0, width: 30, height: 30)
            }
            
            private var delete: ((UIButton)->Void)?
            func delete(_ handler: @escaping (UIButton)->Void) {
                delete = handler
            }
            @objc private func action(sender: UIButton) {
                delete?(sender)
            }
            
        }
        
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if let resource = resource {
                
                var count = resource.count
                if maxCount > 0 {
                    count = count + 1
                }
                return count
            }
            
            return 1
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FunBox.MediaHelper.ImageLayoutViewCellID, for: indexPath) as! Cell
            if let resource = resource, indexPath.item < resource.count {
                
                if let image = resource[indexPath.item].source_image {
                    cell.imageV.image = image
                } else {
                    cell.imageV.fb.webImageSource(resource[indexPath.item].source_url).response()
                }
                cell.del_button.isHidden = false
                cell.delete { (sender) in
                    self.resource?.remove(at: indexPath.item)
                    collectionView.reloadData()
                }
            } else {
                cell.imageV.image = UIImage(named: "image_add.png", in: FunMediaHelper.bundle, compatibleWith: .none)
                cell.del_button.isHidden = true
            }
            
            return cell
        }
        
        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if let resource = resource, indexPath.item < resource.count {
                // 预览
                if let preview = preview {
                    
                    preview((indexPath.item,resource[indexPath.item]))
                } else {
                    FunMediaHelper.preview(resource: resource, index: indexPath.item)
                }
                
            } else {
                // 添加 (一直未选时才允许添加视频)
                add?()
            }
            
        }
        
        
    }
    
}
