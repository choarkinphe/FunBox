//
//  VideoPlayer.swift
//  HZCommon
//
//  Created by choarkinphe on 2020/8/20.
//  Copyright © 2020 hongzheng. All rights reserved.
//
#if !COCOAPODS
import FunBox
#endif
import UIKit
import AVFoundation
/*
 播放器
 */
extension VideoHelper {
    // 视频播放器
    open class Player: UIView {
        
//        private var timeObserver: Any?
        // 监听对象
//        private var observation_loadedTimeRanges: NSKeyValueObservation?
//        private var observation_status: NSKeyValueObservation?
        
        // 视频显示layer
        private var playerLayer: AVPlayerLayer {
            return layer as! AVPlayerLayer
        }
        
        private var options = [String: Any]()
        // 播放状态
        public var isPlaying: Bool {
            return state == .playing
        }
        // 默认开启自动播放
        public var autoPlay: Bool = true
        // 默认开启循环播放
        public var cyclePlay: Bool = true
        // 视频播放对象
        private var player: Core? {
            get {
                return playerLayer.player as? Core
            }
            
            set {
                playerLayer.player = newValue
            }
        }
        
        // 播放进度
        public var progress: Float {
            if totalTime <= 0 {
                return 0.0
            }
            return Float(currentTime / totalTime)
        }
        // 当前时间
        public var currentTime: TimeInterval {
            if let currrent = player?.currentTime().seconds  {
                return currrent
            }
            
            return 0.0
        }
        // 总时间
        public var totalTime: TimeInterval {
            if let duration = player?.currentItem?.duration {
                return TimeInterval(duration.value) / TimeInterval(duration.timescale)
            }
            
            return 0.0
        }
        
        open override class var layerClass: AnyClass {
            return AVPlayerLayer.self
        }
        
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            // 设置显示模式
            playerLayer.videoGravity = .resizeAspect
            playerLayer.contentsScale = UIScreen.main.scale
            

            
            addSubview(activityIndicatorView)
            activityIndicatorView.color = .white
            activityIndicatorView.hidesWhenStopped = true
            
            do {
                /*
                 // app的声音可与其它app共存，但锁屏和静音模式会被静音，除非当前app是唯一播放的app
                 AVAudioSessionCategoryAmbient
                 
                 // 会停止其他程序的音频播放。当设备被设置为静音模式，音频会随之静音
                 AVAudioSessionCategorySoloAmbient
                 
                 // 仅用来录音，无法播放音频
                 AVAudioSessionCategoryRecord
                 
                 // 会停止其它音频播放，并且能在后台播放，锁屏和静音模式都能播放声音
                 AVAudioSessionCategoryPlayback
                 
                 // 能播也能录，播放默认声音是从听筒出来
                 AVAudioSessionCategoryPlayAndRecord
                 */
                try AVAudioSession.sharedInstance().setCategory(.playback)
            }
            catch {
                debugPrint("AVPlayer:",error.localizedDescription)
            }
            // 注册通知
            NotificationCenter.default.addObserver(self, selector: #selector(playing(notic:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playing(notic:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playing(notic:)), name: NSNotification.Name.AVPlayerItemTimeJumped, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playing(notic:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
            
            
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func playing(notic: Notification) {
            switch notic.name {
            case .AVPlayerItemDidPlayToEndTime: // 播放完成
                state = .playToEnd
                
                // 重播
                if cyclePlay {
                    replay()
                }
            default:
                break
            }
        }
        
        public enum State {
            case none
            case playing
            case pause
            case playToEnd
        }
        
        private(set) var state: State = .none {
            didSet {
                stateHandler?(state)
            }
        }
        
        private var stateHandler: ((State)->Void)?
        public func stateChanged(_ handler: @escaping (State)->Void) {
            stateHandler = handler
        }
        
        public func replay() {
            // 回到起点
            player?.currentItem?.seek(to: .zero)
            // 执行播放
            play()
        }
        
        public func play() {
            player?.play()
            //            isPlaying = true
            state = .playing
        }
        
        public func pause() {
            player?.pause()
            //            isPlaying = false
            state = .pause
        }
        
        public func seek(to time: TimeInterval, finished completion: ((Bool)->Void)?=nil) {
            guard let asset = player?.currentItem?.asset else { return }
            activityIndicatorView.startAnimating()
            player?.seek(to: CMTime(seconds: time, preferredTimescale: asset.duration.timescale), completionHandler: { [weak self] (finished) in
                self?.activityIndicatorView.stopAnimating()
                completion?(finished)
            })
        }
        
        // 资源库
        private var library = [URL: AVPlayerItem]()
        
        
        public func play(resource: VideoResource?) {
            guard let item = resource?.asPlayerItem(), let url = item.getURL() else { return }
            
            activityIndicatorView.startAnimating()
            
            if url == player?.currentItem?.getURL() {
                // 当前存在正在播放的数据
                // 当前播放与即将播放的资源相同时
                debugPrint("Same Resource")
                return
            }
            
            // 监听缓冲进度改变
//            observation_loadedTimeRanges = item.observe(\AVPlayerItem.loadedTimeRanges) { (playerItem, change) in
//                print(change)
//                print(item.loadedTimeRanges)
//            }
//
//            // 监听状态改变
//            observation_status = item.observe(\AVPlayerItem.status) { (playerItem, change) in
//                print(change)
//                print(playerItem.status)
//            }
            
            player = Core(playerItem: item)
            
//            timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: item.asset.duration.timescale), queue: .main, using: { [weak self] (time) in
//
//                debugPrint("CurrentPeriodicTime:",time.seconds)
//
//                self?.activityIndicatorView.stopAnimating()
//            })
            
            player?.timeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: item.asset.duration.timescale), queue: .main, using: { [weak self] (time) in
                debugPrint("CurrentPeriodicTime:",time.seconds)

                self?.activityIndicatorView.stopAnimating()
            })
            // 执行播放
            if autoPlay {
                play()
            }
            
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            activityIndicatorView.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
            
            
            debugPrint("AVPlayer Die")
//            if let timeObserver = timeObserver {
//                player?.removeTimeObserver(timeObserver)
//            }
//            timeObserver = nil
        }
    }
}

extension VideoPlayer {
    fileprivate class Core: AVPlayer {
        
        private var timeObserver: Any?
        
        deinit {
            debugPrint("CorePlayer Die")
            if let timeObserver = timeObserver {
                removeTimeObserver(timeObserver)
            }
        }
        
        func timeObserver(forInterval interval: CMTime, queue: DispatchQueue = .global(), using block: @escaping (CMTime) -> Void) {
            timeObserver = addPeriodicTimeObserver(forInterval: interval, queue: queue, using: block)
        }
    }
}

// VideoResource协议，方便方法调用
public protocol VideoResource {
    func asAsset() -> AVAsset?
    func asPlayerItem() -> AVPlayerItem?
    func getURL() -> URL?
}

extension VideoResource {
    
    public func asPlayerItem() -> AVPlayerItem? {
        guard let asset = asAsset() else { return nil }
        return AVPlayerItem(asset: asset)
    }
}
extension String: VideoResource {
    public func getURL() -> URL? {
        return URL(string: self)
    }
    
    public func asAsset() -> AVAsset? {
        guard let url = URL(string: self) else { return nil }
        return AVURLAsset(url: url)
    }
}
extension URL: VideoResource {
    public func getURL() -> URL? {
        return self
    }
    
    public func asAsset() -> AVAsset? {
        
        return AVURLAsset(url: self)
    }
}
extension AVAsset: VideoResource {
    public func getURL() -> URL? {
        return asURLAsset()?.url
    }
    
    public func asAsset() -> AVAsset? {
        return self
    }
    
    public func asURLAsset() -> AVURLAsset? {
        return self as? AVURLAsset
    }
}

extension AVPlayerItem: VideoResource {
    public func getURL() -> URL? {
        return asAsset()?.asURLAsset()?.url
    }
    
    public func asAsset() -> AVAsset? {
        return self.asset
    }
    
    public func asPlayerItem() -> AVPlayerItem? {
        return self
    }
}

public typealias VideoViewController = VideoPlayer.Controller
extension VideoPlayer {
    public class Controller: UIViewController {
        
        public func play(resource: VideoResource) {
            player.play(resource: resource)
        }
        
        public init(resource: VideoResource?=nil) {
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .overFullScreen
            
            player.play(resource: resource)
        }
        
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            
            modalPresentationStyle = .overFullScreen
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .init(white: 0, alpha: 0.97)
            fb.contentView = player
            
//            close.setImage(HZImage.close, for: .normal)
            close.addTarget(self, action: #selector(close(sender:)), for: .touchUpInside)
            view.addSubview(close)
            
        }
        
        private let close = UIButton()
        private lazy var player: VideoPlayer = {
            let player = VideoPlayer()
            player.autoPlay = true
            
            return player
        }()
        
        public override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            close.frame = CGRect(x: 12, y: fb.safeAeraInsets.top+20, width: 44, height: 44)
        }
        
        @objc private func close(sender: UIButton) {
            dismiss(animated: false) {
                
            }
        }
        
        deinit {
            debugPrint("VideoViewController die")
        }
    }
}
/*
extension VideoPlayer {
    class ControlView: UIView {
        // 结束时间
        public var endTime: TimeInterval {
            if timeRange.end > 0.0 {
                return timeRange.end
            }
            if let totalTime = player?.totalTime {
                return totalTime
            }
            
            return 0.0
        }
        
        // 播放范围
        public var timeRange: VideoHelper.TimeRange = (0.0,0.0)
        
        private var player: VideoPlayer?
        private var timer: DispatchSourceTimer?
        func bind(player: VideoPlayer) {
            self.player = player
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
//                            var endTime = self?.player?.timeRange.end
//                            if endTime == 0.0 {
//                                endTime = player.totalTime
//                            }
//                            let endTime = player.totalTime
//                            let current_time = player.currentTime
                            if let endTime = self?.endTime,
                               player.currentTime >= endTime {
                                // 播放到选择的最后时间段，直接暂停
                                player.pause()
                                
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
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(coverImage)
            addSubview(playButton)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            coverImage.frame = bounds
//            playButton.frame = CGRect(x: center.x - 27, y: bounds.height / 2.0 - 27, width: 54, height: 54)
            playButton.center = center
            playButton.bounds = CGRect(x: 0, y: 0, width: 54, height: 54)
        }
        
        // 当前封面图展示框
        let coverImage = UIImageView()
        
        private lazy var playButton: UIButton = {
            let playButton = UIButton()
            
            playButton.setImage(UIImage(named: "video_editor_play.png", in: MediaHelper.bundle, compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .normal)
            playButton.setImage(UIImage(named: "video_editor_pause.png", in: MediaHelper.bundle, compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .selected)
            playButton.tintColor = .white
            playButton.addTarget(self, action: #selector(to_play(sender:)), for: .touchUpInside)
            return playButton
        }()
        
        @objc private func to_play(sender: UIButton) {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                // 移动到选择范围开始的地方，然后开始播放
//                player.seek(to: slider.timeRange.start)
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.coverImage.alpha = 0
                }) { (finished) in
                    self.player?.play()
                }
            } else {
                self.player?.pause()
                UIView.animate(withDuration: 0.15, animations: {
                    self.coverImage.alpha = 1
                }) { (finished) in
                    
                }
            }
            
        }
        
        deinit {
            timer = nil
        }
    }
}
 */
