//
//  VideoEditor.swift
//  CommunityCircle
//
//  Created by 肖华 on 2020/7/25.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
#if !COCOAPODS
import FunBox
#endif
extension FunMediaHelper {
    open class VideoEditor: UIViewController {
        public enum Mode {
            case add
            case edit
        }
        deinit {
            debugPrint("VideoEditor Die")
        }
        // 默认为添加模式
        public var mode: Mode = .add
        // 默认的缩略图大小
        static var thumbnailSize = CGSize(width: 64, height: 108)
        
        // 回调信息
        public typealias Handler = (((image: UIImage?, asset: PHAsset?))->Void)
        private var completion: Handler?
        public func completion(_ handler: @escaping Handler) {
            completion = handler
        }
        
        // 当前封面图展示框
        private let imageView = UIImageView()
        // 操作对象
        private var helper: VideoHelper?
        // 数据源
        public var asset: AVAsset? {
            didSet {
                guard let asset = asset else { return }
                // 初始化helper
                helper = VideoHelper.build(asset)
                // 初始化player
                player.play(resource: asset)
                // 给slider绑定数据
                DispatchQueue.main.async {
                    
                    self.slider.bind(helper: self.helper)
                }
                
            }
        }
        
        public var source: PHAsset? {
            didSet {
                FunHUD.toast(.loading, message: FunTips.loading)
                source?.fb.requestAVAsset({ [weak self] (source_asset) in
                    self?.asset = source_asset
                    FunHUD.dismissActivity()
                })
            }
        }
        
        open override func viewDidLoad() {
            super.viewDidLoad()
            
            imageView.contentMode = .scaleAspectFit
            view.addSubview(player)
            view.addSubview(imageView)
            view.addSubview(slider)
            view.addSubview(playButton)
            
            view.backgroundColor = .black
            
            let btn = UIBarButtonItem(title: "提交", style: .done, target: self, action: #selector(format(sender:)))
            navigationItem.rightBarButtonItem = btn
            
            navigationItem.leftBarButtonItem?.tintColor = .white
        }
        
        open override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            navigationController?.navigationBar.setBackgroundImage(UIImage.fb.color(UIColor.fb.RGB([34,34,34])), for: .default)
            navigationController?.navigationBar.tintColor = .white
            
        }
        
        open override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            playButton.frame = CGRect(x: view.center.x - 27, y: view.bounds.height - fb.safeAeraInsets.bottom - 20 - 54 - 54, width: 54, height: 54)
            slider.frame = CGRect(x: 0, y: view.bounds.height - fb.safeAeraInsets.bottom - 20 - 54, width: view.frame.width, height: 54)
            imageView.frame = CGRect(x: 24, y: 88 + 24, width: view.bounds.width - 48, height: slider.frame.origin.y - 88 - 58)
            player.frame = imageView.frame
            
        }
        
        // 转码、裁剪、导出视频
        @objc private func format(sender: UIBarButtonItem) {
            guard let asset = asset, let source = source else { return }
            
            
            // 只有当视频发生过裁剪，才会出发保存到相册操作
            
            if slider.sliderDidChanged == false, mode == .edit {
                
                DispatchQueue.main.async {
                    // 在编辑模式下，且滑块未移动过,说明视频信息没有发生变更，直接输出原片
                    self.completion?((self.imageView.image,self.source))
                    
                }
                
            } else {
                debugPrint("Pixel:  ",source.pixelWidth,"X",source.pixelHeight)
                
                // 新增模式下，直接转码操作
                FunHUD.toast(.loading, message: FunTips.transcoding)
                
                helper?.progress({ (progress) in
                    // 转码进度
                }).export(name: asset.asURLAsset()?.url.pathExtension ?? FunTips.unknow, start: slider.timeRange.start, end: slider.timeRange.end) { [weak self] (fileUrl) in
                    FunHUD.dismissActivity()
                    // 保存到相册
                    FunHUD.toast(.loading, message: FunTips.saving)
                    PHPhotoLibrary.fb.save(resource: fileUrl) { (result) in
                        DispatchQueue.main.async {
                            
                            self?.completion?((self?.imageView.image,result.asset))
                            FunHUD.dismissActivity()
                        }
                    }
                    
                    
                }
                
            }
            
        }
        
        // 选择器
        private lazy var slider: VideoHelper.Slider = {
            
            let slider = VideoHelper.Slider()
            
            slider.currentFrame(thumbnailSize: imageView.bounds.size) { [weak self] (result) in
                FunHUD.dismissActivity()
                // 拖动选择封面图
                self?.imageView.image = result.image
                
                if self?.player.isPlaying == true {
                    // 正在播放时拖动slider,快进到这个时间点
                    //                self?.player.seek(to: result.currentTime)
                    self?.imageView.alpha = 1
                    if !slider.isDragging {
                        self?.player.seek(to: result.currentTime, finished: { (finish) in
                            //                    self?.imageView.alpha = 0
                            self?.imageView.alpha = 0
                        })
                    }
                }
            }
            
            return slider
        }()
        
        private var playButton: UIButton = {
            let playButton = UIButton()
            
            playButton.setImage(UIImage(named: "video_editor_play.png", in: FunMediaHelper.bundle, compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .normal)
            playButton.setImage(UIImage(named: "video_editor_pause.png", in: FunMediaHelper.bundle, compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .selected)
            playButton.tintColor = .white
            playButton.addTarget(self, action: #selector(to_play(sender:)), for: .touchUpInside)
            return playButton
        }()
        
        @objc private func to_play(sender: UIButton) {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                // 移动到选择范围开始的地方，然后开始播放
                player.seek(to: slider.timeRange.start)
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.imageView.alpha = 0
                }) { (finished) in
                    self.player.play()
                }
            } else {
                self.player.pause()
                UIView.animate(withDuration: 0.15, animations: {
                    self.imageView.alpha = 1
                }) { (finished) in
                    
                }
            }
            
        }
        
        private var timer: DispatchSourceTimer?
        private lazy var player: VideoPlayer = {
            let player = VideoPlayer()
            player.autoPlay = false
            
            player.stateChanged { [weak self] (state) in
                if state == .playing {
                    // 播放时创建一个计时器
                    self?.timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
                    // 每0.1s执行一次
                    self?.timer?.schedule(wallDeadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(0))
                    
                    // 开启计时器
                    self?.timer?.setEventHandler {
                        // 获取当前播放进度
                        DispatchQueue.main.async {
                            if let endTime = self?.slider.timeRange.end,
                               let current_time = self?.player.currentTime,
                               current_time >= endTime {
                                // 播放到选择的最后时间段，直接暂停
                                self?.player.pause()
                                
                            }
                        }
                    }
                    
                    self?.timer?.resume()
                } else {
                    // 停止播放时
                    self?.playButton.isSelected = false
                    
                    // 完成时取消计时
                    self?.timer?.cancel()
                }
            }
            
            //        player.periodicTime { [weak self] (current_time) in
            //            if let endTime = self?.slider.timeRange.end, current_time >= endTime {
            //                print("EndTime: ",endTime)
            //                player.pause()
            //                self?.playButton.isSelected = false
            //            }
            //        }
            return player
        }()
    }
}



