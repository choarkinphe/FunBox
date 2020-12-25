//
//  VideoSlider.swift
//  HZCommon
//
//  Created by choarkinphe on 2020/8/27.
//  Copyright © 2020 hongzheng. All rights reserved.
//
#if !COCOAPODS
import FunBox
#endif
import UIKit
import Photos
extension VideoHelper {
    // 目标奇石时间
    public typealias TimeRange = (start: TimeInterval, end: TimeInterval)
    
    class Slider: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
        
        var isDragging: Bool {
            return contentView.isDragging || contentView.isDecelerating
        }
        func bind(helper: VideoHelper?) {
            guard let helper = helper else { return }
            
            // 保存视频的长度
            duration = helper.duration
            if duration < max_duration {
                // 如果允许的最大长度超过了视频本身长度
                max_duration = duration
            }
            
            // 初衷：保证max_duration下有足够的显示
            
            // 至少截取24帧(默认每秒截取1帧，当时长不足24s时，改变截取策略)
            // 最多截取48帧(时长超过48s时，调整)
            var sampling = 1
            if duration < 12 {
                sampling = 2
            }
            
            helper.thumbnailSize(CGSize(width: 32, height: 54)).max_count(48).images(sampling: sampling, { [weak self] (images) in
                guard let this = self else { return }
                this.images = images
                
                
            })
            
            // 加载完先返回第一帧，设置时间为第0s
            helper.thumbnailSize(UIScreen.main.bounds.size).percent(0).image { [weak self] (image) in
                //                guard let this = self else { return }
                DispatchQueue.main.async {
                    HUD.dismissActivity()
                    if let image = image {
                        self?.timeLabel.text = String(format: "%.1fs", 0)
                        self?.image_completion?((0.0,image))
                    } else {
                        HUD.toast(.error, message: "加载失败")
                    }
                }
            }
            
            // 滑动时会执行
            scroll_scale = { [weak self] (scale) in
                guard let this = self else { return }
                // 获取当前帧的缩略图
                helper.thumbnailSize(UIScreen.main.bounds.size).percent(Double(scale)).image { (image) in
                    
                    DispatchQueue.main.async {
                        
                        this.image_completion?((Double(scale) * helper.duration,image))
                    }
                }
                
                // 获取当前进度的时间
                let time = helper.percent(Double(scale)).currentTime
                
                this.timeLabel.text = String(format: "%.1fs", time)
                
            }
            
        }
        
        // 滑块被移动过
        private(set) var sliderDidChanged: Bool = false
        // 视频最短时间为3s
        var min_duration: TimeInterval = 3
        // 视频允许最长时间为30s
        var max_duration: TimeInterval = 30
        
        // 视频的时长
        private var duration: TimeInterval = 0
        // 像素对应的时长(每一像素对应的时长)
        private var pixel_duration: TimeInterval {
            if contentView.contentSize.width == 0.0 {
                return 0.0
            }
            return duration / TimeInterval(contentView.contentSize.width)
        }
        // 每秒对应的像素
        private var duration_pixel: CGFloat {
            if contentView.contentSize.width == 0.0 {
                return 0.0
            }
            return contentView.contentSize.width / CGFloat(duration)
        }
        
        var timeRange: TimeRange {
            // 获取起始点的百分比
            let start_percent = TimeInterval(start_position.x / contentView.contentSize.width)
            let end_percent = TimeInterval(end_position.x / contentView.contentSize.width)
            
            // 转换获取时间
            let start_time = duration * start_percent
            let end_time = duration * end_percent
            
            return (start_time,end_time)
        }
        
        
        private var image_completion: (((currentTime: TimeInterval, image: UIImage?))->Void)?
        private var thumbnailSize: CGSize = PHImageManagerMaximumSize
        // 获取当前帧
        func currentFrame(thumbnailSize size: CGSize?=nil, complete: @escaping (((currentTime: TimeInterval, image: UIImage?))->Void)) {
            if let size = size {
                thumbnailSize = size
            }
            image_completion = complete
        }
        
        static var tag_width: CGFloat = 24.0
        
        static var cellIdentifier = "com.videoeditor.cell.identifier"
        // 获取到的图片数据源
        var images: [UIImage]? {
            didSet {
                DispatchQueue.main.async {
                    
                    self.contentView.reloadData()
                    
                    self.setNeedsLayout()
                }
            }
        }
        // 选择起点
        var start_position: CGPoint
        // 选择的终点
        var end_position: CGPoint
        
        // 缩略图承载器
        let contentView: UICollectionView
        // 监听对象（contentSize）
        var observation: NSKeyValueObservation?
        
        // 时间指示器（标注当前帧时间）
        let indicatorView = UIView()
        let timeLabel = UILabel()
        
        // 蒙层
        let masker: Masker
        // 选择框框
        let selector: Selector
        // 手势
        lazy var pan: FunPan = {
            let pan = FunPan()
            
            pan.touchesMoved { [weak self] (touches, event) in
                guard let this = self else { return }
                // 迁移
                if let position = touches.first?.location(in: this.contentView) {
                    // 获取触摸的点在contentView上的坐标
                    // 计算视频允许的最大、最小宽度
                    // min_duration视频对应的像素
                    let min_width = this.duration_pixel * CGFloat(this.min_duration)
                    // max_duration视频对应的像素
                    let max_width = this.duration_pixel * CGFloat(this.max_duration)
                    // 修改起始点的坐标
                    if this.change == .start {
                        // 起点x不能小于0
                        var start_x = max(position.x, 0)
                        // 起点不能大于终点前min_duration秒
                        start_x = min(start_x, this.end_position.x - min_width)
                        // 依据视频的时长限制，反推出起点坐标
                        // 起点不能再终点的max_duration前
                        start_x = max(start_x, this.end_position.x - max_width)
                        // 保存起点坐标
                        this.start_position = CGPoint(x: start_x, y: 0)
                        
                    } else if this.change == .end {
                        // 终点x不能大于contentSize.w
                        var end_x = min(position.x, this.contentView.contentSize.width)
                        // 终点不能小于起点后min_duration秒
                        end_x = max(end_x, this.start_position.x + min_width)
                        
                        // 终点不能在起点后max_duration秒
                        end_x = min(end_x, this.start_position.x + max_width)
                        // 保存终点坐标
                        this.end_position = CGPoint(x: end_x, y: 0)
                    }
                    
                    if this.change != .none {
                        this.setNeedsLayout()
                    }
                    
                    //                    this.position_change?((this.start_position,this.end_position))
                }
            }
            pan.touchesEnded { [weak self] (touches, event) in
                guard let this = self else { return }
                // 判断当前停留位置
                if let position = touches.first?.location(in: this) {
                    // 如果起点在指示器右侧
                    if this.change == .start, position.x > this.indicatorView.frame.origin.x {
                        // 计算指示器到当前位置的距离
                        let offset = position.x - this.indicatorView.frame.origin.x
                        // 将指示器滚动到高亮区域内
                        this.contentView.setContentOffset(CGPoint(x: this.contentView.contentOffset.x + offset, y: 0), animated: true)
                    }
                    // 如果终点在指示器左侧
                    if this.change == .end, position.x < this.indicatorView.frame.origin.x {
                        // 计算指示器到当前位置的距离
                        let offset = this.indicatorView.frame.origin.x - position.x
                        // 将指示器滚动到高亮区域内
                        this.contentView.setContentOffset(CGPoint(x: this.contentView.contentOffset.x - offset, y: 0), animated: true)
                    }
                }
                // 抬手初始化
                this.change = .none
            }
            
            pan.delegate = self
            
            return pan
        }()
        // 滑动回调
        private var scroll_scale: ((CGFloat)->Void)?
        func scroll_scale(_ handler: ((CGFloat)->Void)?) {
            scroll_scale = handler
        }
        
        // 当前的动作状态
        var change: Change = .none
        enum Change {
            case none
            case start
            case end
        }
        
        // 只响应滑块上的手势
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            let position = touch.location(in: self.selector)
            // 获取触摸的点在selector上的坐标
            if position.x <= Slider.tag_width {
                // 触摸点在开始滑块上
                print("触摸点在开始滑块上")
                change = .start
            }
            if position.x >= self.selector.bounds.width - Slider.tag_width {
                // 触摸点在结束滑块上
                print("触摸点在结束滑块上")
                change = .end
            }
            
            return change != .none
            
        }
        
        override init(frame: CGRect) {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 32, height: 54)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            contentView = UICollectionView(frame: CGRect(origin: .zero, size: frame.size), collectionViewLayout: layout)
            masker = Masker(frame: CGRect(origin: .zero, size: frame.size))
            selector = Selector(frame: CGRect(origin: .zero, size: frame.size))
            start_position = .zero
            end_position = .zero
            
            super.init(frame: frame)
            contentView.register(Cell.self, forCellWithReuseIdentifier: Slider.cellIdentifier)
            contentView.contentInset = UIEdgeInsets(top: 0, left: frame.width / 2.0, bottom: 0, right: frame.width / 2.0)
            contentView.dataSource = self
            contentView.delegate = self
            contentView.showsHorizontalScrollIndicator = false
            contentView.bounces = false
            
            addSubview(contentView)
            
            contentView.addSubview(masker)
            
            selector.addGestureRecognizer(pan)
            contentView.addSubview(selector)
            
            indicatorView.backgroundColor = .white
            indicatorView.layer.cornerRadius = 1.5
            indicatorView.layer.masksToBounds = true
            
            timeLabel.textColor = .white
            timeLabel.font = UIFont.systemFont(ofSize: 11)
            timeLabel.textAlignment = .center
            addSubview(timeLabel)
            
            addSubview(indicatorView)
            observation = contentView.observe(\UICollectionView.contentSize, changeHandler: { [weak self] (_, changed) in
                guard let this = self else { return }
                if this.end_position == .zero, this.contentView.contentSize.width > 0 {
                    //
                    //                    let size = this.contentView.contentSize
                    //                    this.end_position = CGPoint(x: size.width, y: 0)
                    // 计算视频允许的最大、最小宽度
                    // min_duration视频对应的像素
                    //                let min_width = duration_pixel * CGFloat(min_duration)
                    // max_duration视频对应的像素
                    //                    let duration_pixel = size.width / CGFloat(this.duration)
                    let max_width = this.duration_pixel * CGFloat(this.max_duration)
                    print(max_width,this.duration_pixel,this.max_duration)
                    let end_x = this.start_position.x + max_width
                    // 根据视频的真是长度，初始化end_position
                    this.end_position = CGPoint(x: end_x, y: 0)
                    this.setNeedsLayout()
                }
            })
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            return images?.count ?? 0
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Slider.cellIdentifier, for: indexPath) as! Cell
            cell.imageView.image = images?[indexPath.item]
            return cell
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            location(scrollView)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            
            location(scrollView)
        }
        
        private func location(_ scrollView: UIScrollView) {
            // 标记滑块被移动过
            sliderDidChanged = true
            // 手动滑动停止后
            if scrollView.contentOffset.x + scrollView.contentInset.left < start_position.x || scrollView.contentOffset.x == 0 {
                // 如果指示器停留在开始坐标前
                scrollView.setContentOffset(CGPoint(x: start_position.x-scrollView.contentInset.left, y: 0), animated: true)
            }
            if scrollView.contentOffset.x + scrollView.contentInset.left > end_position.x || scrollView.contentOffset.x == scrollView.contentSize.width {
                // 如果指示器停留在结束坐标后
                scrollView.setContentOffset(CGPoint(x: end_position.x-scrollView.contentInset.right, y: 0), animated: true)
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            endScroll(scrollView)
        }
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            endScroll(scrollView)
        }
        
        private func endScroll(_ scrollView: UIScrollView) {
            let scale = (scrollView.contentOffset.x + scrollView.contentInset.left) / scrollView.contentSize.width
            
            if let handler = scroll_scale {
                handler(scale)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            
            indicatorView.frame = CGRect(x: bounds.width / 2.0 - 1.5, y: -4, width: 3, height: bounds.size.height+8)
            
            timeLabel.frame = CGRect(x: 0, y: -18, width: bounds.width, height: 14)
            contentView.frame = bounds
            contentView.contentInset = UIEdgeInsets(top: 0, left: bounds.width / 2.0, bottom: 0, right: bounds.width / 2.0)
            masker.frame = CGRect(x: -Slider.tag_width, y: 0, width: contentView.contentSize.width + 2 * Slider.tag_width, height: bounds.height)
            
            let mask_highlight_rect = CGRect(x: start_position.x+Slider.tag_width, y: start_position.y, width: end_position.x - start_position.x, height: masker.bounds.height)
            
            masker.highlight_rect = mask_highlight_rect
            
            selector.frame = CGRect(x: start_position.x-Slider.tag_width, y: start_position.y, width: end_position.x - start_position.x + 2 * Slider.tag_width, height: masker.bounds.height)
            
            setNeedsDisplay()
        }
        
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            masker.setNeedsDisplay()
            selector.setNeedsDisplay()
            
        }
        
        // 蒙层
        class Masker: UIView {
            var highlight_rect: CGRect = .zero
            override init(frame: CGRect) {
                super.init(frame: frame)
                
                backgroundColor = .init(white: 0, alpha: 0.8)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func draw(_ rect: CGRect) {
                super.draw(rect)
                
                let path = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
                let highlight_path = UIBezierPath(roundedRect: highlight_rect, cornerRadius: 2)
                path.append(highlight_path.reversing())
                
                let maskLayer = CAShapeLayer()
                maskLayer.path = path.cgPath
                
                layer.mask = maskLayer
                
            }
        }
        
        // 选择框
        class Selector: UIView {
            override init(frame: CGRect) {
                super.init(frame: frame)
                
                backgroundColor = .white
                layer.cornerRadius = 5
                layer.masksToBounds = true
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func draw(_ rect: CGRect) {
                super.draw(rect)
                
                
                let highlight_rect = CGRect(x: Slider.tag_width, y: 3, width: bounds.width - 2 * Slider.tag_width, height: bounds.height - 6)
                let path = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
                let highlight_path = UIBezierPath(roundedRect: highlight_rect, cornerRadius: 2)
                path.append(highlight_path.reversing())
                
                let selectorLayer = CAShapeLayer()
                selectorLayer.path = path.cgPath
                
                layer.mask = selectorLayer
                
            }
        }
        
        class Cell: UICollectionViewCell {
            var imageView = UIImageView()
            //            var cover = UIView()
            override init(frame: CGRect) {
                super.init(frame: frame)
                
                contentView.addSubview(imageView)
                
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                imageView.frame = contentView.bounds
                
            }
        }
    }
}
