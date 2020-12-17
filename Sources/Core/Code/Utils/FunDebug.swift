//
//  FunDebug.swift
//  FunBox
//
//  Created by choarkinphe on 2020/10/28.
//

import UIKit
public typealias FunLoger = FunBox.Debug.Loger
extension FunBox {
    public struct Debug { }
}

// MARK: - Log
public extension FunBox.Debug {
    class Loger {
        // Log的储存路径
        private static let cachePathName = "com.funbox.core.cache.log"
        
        private static var cachePool: FunCache {
            let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
            // 指定缓存路径
            let cachePool = FunBox.Cache.init(path: directoryPath! + "/\(cachePathName)")
            // 缓存有效期为30天
            cachePool.cacheTimeOut = 2592000
            return cachePool
        }
        
        
        // 记录一条log
        public static func record(_ message: String?) {
            guard let message = message else { return }
            // 生成索引，并保存
            
            // 生成log
            let log = Log(message)
            let formatter = DateFormatter()
            formatter.locale = .current
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
            if let createTime = log.createTime {
                let time = formatter.string(from: Date(timeIntervalSince1970: createTime))
                
                cachePool.cache(key: time, data: log.encode())
            }
            
        }

        // log的索引
        public static var indexes: [String] {
         
            var indexes = [String]()
            
            cachePool.indexes.forEach { (item) in
                indexes.append(item.key)
            }
            
            return indexes
        }
        
        // 清空log
        public static func clean() {
            cachePool.removeAllCache()
        }
        
        // 获取日志
        public static func read(index: String?) -> Log? {
            
            return Log.decode(cachePool.loadCache(key: index))
        }
        
    }
}
extension FunLoger {
    public class Log: Codable {
        // 记录时间
        public var createTime: TimeInterval?
        // 记录下的信息
        public var message: String?
        // 记录发生时停留的页面信息
        public var page: String?
        
        private enum CodingKeys: String, CodingKey {
            case createTime
            case message
            case page
        }
        
        init(_ message: String?) {
            self.message = message
            self.createTime = Date().timeIntervalSince1970
            if let viewController = UIApplication.shared.fb.frontController {
                self.page = viewController.description
            }
        }
        
        required public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            createTime = try container.decode(TimeInterval.self, forKey: .createTime)
            message = try container.decode(String.self, forKey: .message)
            page = try container.decode(String.self, forKey: .page)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(createTime, forKey: .createTime)
            try container.encode(message, forKey: .message)
            try container.encode(page, forKey: .page)
        }
        
        func encode() -> Data? {
            // 获取真实的Data
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(self)
                
                return data
                
            } catch let error {
                
                debugPrint("FunLoger: \(error.localizedDescription)")
                
            }
            return nil
        }
        
        static func decode(_ data: Data?) -> Self? {
            guard let data = data else { return nil }
            let decoder = JSONDecoder()
            // 解码数据
            return try? decoder.decode(Self.self, from: data)
        }
        
    }
}


// MARK: - FPS
public extension FunBox.Debug {
    class FPS: NSObject {

        private var count: Int = 0
        private var lastTime: TimeInterval = 0
        private var isShow: Bool = false
        private var font: UIFont?
        private var subFont: UIFont?
        private var frame: CGRect = CGRect.init(x: UIScreen.main.bounds.size.width - 68, y: UIScreen.main.bounds.size.height - 84, width: 60, height: 24)
        private var targetView: UIView?

        
        private lazy var fpsLabel: UILabel = {
            font = UIFont.init(name: "Menlo", size: 14)
            if font != nil {
                subFont = UIFont.init(name: "Menlo", size: 4)
            } else {
                font = UIFont.init(name: "Courier", size: 14)
                subFont = UIFont.init(name: "Courier", size: 4)
            }
            
            let _fpsLabel = UILabel.init(frame: frame)
            _fpsLabel.textColor = .white
            _fpsLabel.layer.cornerRadius = 5
            _fpsLabel.layer.masksToBounds = true
            _fpsLabel.textAlignment = .center
            _fpsLabel.isUserInteractionEnabled = false
            _fpsLabel.backgroundColor = UIColor.init(white: 0.0, alpha: 0.7)
            _fpsLabel.font = UIFont.systemFont(ofSize: 17)
            return _fpsLabel
        }()
        
        public static var `default`: FPS {
            
            return Static.instance
        }
        
        private struct Static {
            static let instance = FPS()
        }
        
        public func set(frame: CGRect) -> Self {
            self.frame = frame
            
            return self
        }
        
        public func show(inView: UIView? = nil) {
            
            isShow = true
            
            targetView = inView ?? UIApplication.shared.keyWindow
            
            targetView?.addSubview(fpsLabel)
            
            start()
        }
        
        private func start() {
            
            let link = CADisplayLink.weak_linker(target: self, selector: #selector(tick(linker:)))
            link.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        }
        
        @objc private func tick(linker: CADisplayLink) {
            
            if lastTime == 0 {
                lastTime = linker.timestamp
                
                return
            }
            
            count = count + 1
            
            let delta = linker.timestamp - lastTime

            if delta < 1.0 {
                return
            }
            
            lastTime = linker.timestamp
            let fps = Double(count) / delta
            count = 0
            
            let progress = fps / 60.0
            let fpsText = "\(Int(round(fps))) FPS"
            
            if isShow {
                
                let color = UIColor.init(hue: CGFloat(0.27 * (progress - 0.2)), saturation: 1.0, brightness: 0.9, alpha: 1.0)
                let text = NSMutableAttributedString.init(string: fpsText)
                text.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange.init(location: 0, length: text.length - 3))
                text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange.init(location: text.length - 3, length: 3))
                text.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange.init(location: 0, length: text.length))
                text.addAttribute(NSAttributedString.Key.font, value: subFont!, range: NSRange.init(location: text.length - 4, length: 1))
                self.fpsLabel.attributedText = text
                self.targetView?.bringSubviewToFront(self.fpsLabel)

            } else {
                print(fpsText)
            }
            
            
        }
    }
}
