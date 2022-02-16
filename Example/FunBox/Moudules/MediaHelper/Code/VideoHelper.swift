//
//  VideoHelper.swift
//  CommunityCircle
//
//  Created by 肖华 on 2020/7/25.
//  Copyright © 2020 Konnech. All rights reserved.
//

import AVFoundation
import Photos
import UIKit
public typealias VideoPlayer = VideoHelper.Player
public typealias VideoHelper = MediaHelper.Video
extension MediaHelper {
    public class Video {
        // 构造helper
        static func build(_ target: VideoResource) -> VideoHelper {
            let helper = VideoHelper()
            
            helper.asset = target.asAsset()
            
            return helper
        }
        private static var ioQueue = DispatchQueue(label: "com.videohelper.ioqueue")
        private static var timeQueue = DispatchQueue(label: "com.videohelper.timeQueue")
        // 媒体资源
        private var asset: AVAsset?
        // 缩略图尺寸(默认读取原图的尺寸)
        private var thumbnailSize: CGSize = PHImageManagerMaximumSize
        func thumbnailSize(_ size: CGSize) -> VideoHelper {
            if size != PHImageManagerMaximumSize {
                thumbnailSize = CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale)
            } else {
                thumbnailSize = size
            }
            return self
        }
        
        
        // 设置进度
        private var percent: Double?
        func percent(_ value: Double) -> VideoHelper {
            percent = value
            return self
        }
        
        // 视频的总时长
        var duration: TimeInterval {
            guard let asset = asset else {
                return 0
            }
            
            // 获取视频总时长,单位秒
            return TimeInterval(asset.duration.value) / TimeInterval(asset.duration.timescale)
        }
        
        var currentTime: TimeInterval {
            guard let percent = percent else {
                return 0
            }
            
            return duration * percent
        }
        
        private var progressHandler: ((Float)->Void)?
        func progress(_ handler: ((Float)->Void)?) -> Self {
            progressHandler = handler
            return self
        }
        
        private var timer: DispatchSourceTimer?
        
        // 导出
        func export(name: String, start: TimeInterval?=nil, end: TimeInterval?=nil, completion: @escaping ((URL?)->Void)) {
            // 导出时加锁
            isLock = true
            
            // 利用裁剪方法，生成一个新的asset(直接操作原始asset会失败)
            cut(start: start ?? 0.0, end: end ?? duration) { (new_asset) in
                VideoHelper.ioQueue.async {
                    // 检验
                    if let asset = new_asset, let document = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                        // 拼接文件路径
                        let path = URL(fileURLWithPath: document+"/Video")
                        let filePath = path.appendingPathComponent("\(name).mp4")
                        let fileManager = FileManager.default
                        do {
                            // 判断文件夹是否存在
                            if !fileManager.fileExists(atPath: path.path) {
                                // 不存在就创建这个文件夹
                                try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                            }
                            //判断文件是否存在
                            if fileManager.fileExists(atPath: filePath.path) {
                                // 存在就删除旧文件
                                try fileManager.removeItem(at: filePath)
                            }
                        }
                        catch {
                            print(error)
                            self.isLock = false
                        }
                        
                        // 创建转码任务
                        let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
                        // 文件格式
                        session?.outputFileType = .mp4
                        // 保存路径
                        session?.outputURL = filePath
                        session?.shouldOptimizeForNetworkUse = true
                        debugPrint("OutPut:",filePath)
                        
                        // 创建一个计时器
                        self.timer = DispatchSource.makeTimerSource(flags: [], queue: VideoHelper.timeQueue)
                        // 每0.1s执行一次
                        self.timer?.schedule(wallDeadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(0))
                        // 开启计时器
                        self.timer?.setEventHandler {
                            // 获取并传递当前的转码进度
                            if let handler = self.progressHandler, let progress = session?.progress {
                                DispatchQueue.main.async {
                                    handler(progress)
                                }
                            }
                        }
                        
                        self.timer?.resume()
                        // 任务完成
                        session?.exportAsynchronously(completionHandler: {
                            // 完成时取消并且销毁计时器
                            self.timer?.cancel()
                            self.timer = nil
                            self.isLock = false
                            // 确认任务完成时给出回调信息
                            if session?.status == AVAssetExportSession.Status.completed {
                                DispatchQueue.main.async {
                                    
                                    completion(filePath)
                                }
                            }
                            
                        })
                    }
                    
                }
                
                
            }
            
            
            
        }
        /// 裁剪
        /// - Parameters:
        ///   - start: 开始时间
        ///   - end: 结束时间
        /// - complete: 结果
        func cut(start: TimeInterval, end: TimeInterval, complete: @escaping ((AVAsset?)->Void)) {
            // 校验asset数据
            guard let asset = asset else {
                complete(nil)
                return
            }
            isLock = true
            VideoHelper.ioQueue.async {
                // 在子线程下开启裁剪任务
                // 获取开始、结束时间，生成时间范围
                let start_time = CMTime(seconds: start, preferredTimescale: asset.duration.timescale)
                let end_time = CMTime(seconds: end, preferredTimescale: asset.duration.timescale)
                let time_range = CMTimeRange(start: start_time, duration: end_time-start_time)
                // 创建AVMutableComposition
                let composition = AVMutableComposition()
                // 创建一个音频和视频的轨道,类型都为AVMediaTypeAudio
                let video_track = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                
                let audio_track = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                
                
                //创建一个轨道级检查界面的对象
                if let origin_video_track = asset.tracks(withMediaType: .video).first,
                   let origin_audio_track = asset.tracks(withMediaType: .audio).first {
                    
                    //获取videoPath的音视频插入轨道
                    
                    do {
                        try video_track?.insertTimeRange(time_range, of: origin_video_track, at: .zero)
                        
                        try audio_track?.insertTimeRange(time_range, of: origin_audio_track, at: .zero)
                        
                        video_track?.preferredTransform = origin_video_track.preferredTransform
                        
                    }
                    catch {
                        self.isLock = false
                    }
                }
                
                DispatchQueue.main.async {
                    self.isLock = false
                    complete(composition)
                }
            }
            
        }
        
        private var isLock = false
        // 获取某一时间的帧画面
        func image(duration: Double?=nil, _ complete: @escaping ((UIImage?)->Void)) {
            guard let asset = asset else {
                complete(nil)
                return
            }
            if isLock {
                return
            }
            isLock = true
            VideoHelper.ioQueue.async {
                
                // 默认读取地0秒（第一帧）
                var duration = ((duration ?? self.percent) ?? 0.0)
                // 获取所有track（非合成视频的话，实际上只会有一个）
                let gen = AVAssetImageGenerator(asset: asset)
                gen.maximumSize = self.thumbnailSize
                gen.apertureMode = .cleanAperture
                gen.appliesPreferredTrackTransform = true
                // 获取视频总时长,单位秒
                //        let second = self.duration
                if duration < 1 { // duration此时是progress（进度百分比）
                    duration = self.duration * duration
                }
                let time = CMTime(seconds: duration, preferredTimescale: 60)
                
                var actualTime = CMTime()
                do {
                    let cg_image = try gen.copyCGImage(at: time, actualTime: &actualTime)
                    self.isLock = false
                    DispatchQueue.main.async {
                        
                        complete(UIImage(cgImage: cg_image))
                    }
                }
                catch {
                    debugPrint(error.localizedDescription)
                    self.isLock = false
                    DispatchQueue.main.async {
                        complete(nil)
                    }
                }
            }
        }
        
        // 最多获取多少帧
        private var max_count: Int?
        func max_count(_ count: Int) -> Self {
            max_count = count
            return self
        }
        /// 获取视频帧(合成视频另外处理)
        /// - Parameters:
        ///   - sampling: 每秒获取多少帧
        ///   - complete: 帧图片
        func images(sampling: Int? = nil, _ complete: @escaping (([UIImage]?)->Void)) {
            guard let asset = asset else {
                complete(nil)
                return
            }
            
            VideoHelper.ioQueue.async {
                
                var imageArray = [UIImage]()
                //        for track in asset.tracks(withMediaType: .video) {
                // 获取所有track（非合成视频的话，实际上只会有一个）
                if let track = asset.tracks(withMediaType: .video).first {
                    
                    let gen = AVAssetImageGenerator(asset: asset)
                    gen.maximumSize = self.thumbnailSize
                    gen.apertureMode = .cleanAperture
                    
                    // 创建时间节点的数组
                    var array = [NSValue]()
                    let duration = asset.duration.seconds
                    let all = duration * Double(track.nominalFrameRate)
                    
                    var numberGet = Int(duration * Double(sampling ?? 5)) // 默认每秒取5帧
                    // 如果设置过总帧数，那么不按秒取帧
                    if let max_count = self.max_count {
                        numberGet = min(max_count, numberGet)
                    }
                    
                    let scan = Int(all) / numberGet
                    
                    for item in 0..<numberGet {
                        let value = CMTimeValue(item*scan)
                        let ctvalue = CMTime(value: value, timescale: CMTimeScale(track.nominalFrameRate))
                        
                        array.append(NSValue(time: ctvalue))
                        
                    }
                    
                    //这里是获取多个视频帧所用的异步方法，将更高效的去获取视频帧内容而不堵塞UI线程
                    gen.generateCGImagesAsynchronously(forTimes: array) { (time_1, cg_img, time_2, result, error) in
                        if let cg_img = cg_img {
                            let img = UIImage.init(cgImage: cg_img)
                            //把获取到的图片加入一个数组内
                            imageArray.append(img)
                            
                            if imageArray.count == array.count {
                                
                                DispatchQueue.main.async {
                                    complete(imageArray)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
    }
}


