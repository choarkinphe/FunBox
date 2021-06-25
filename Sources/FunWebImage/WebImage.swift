//
//  WebImage.swift
//  Store
//
//  Created by choarkinphe on 2020/6/10.
//  Copyright © 2020 Konnech. All rights reserved.
//
import UIKit
import Kingfisher
import FunBox


public protocol FunImageContainer {
    func response(for config: FunWebImage.Config)
}

public protocol FunWebImageSource {
    func asSource() -> Source?
}

extension String: FunWebImageSource {
    public func asSource() -> Source? {
        var string = self   
        if !string.hasPrefix("http"), var server = FunWebImage.manager.baseURL {
            if server.hasSuffix("/") {
                server.removeLast()
            }
            if string.hasPrefix("/") {
                string = "/" + string
            }
            string = server + string
        }
        if let URL = string.asURL() {
            if URL.fb.mimeType.lowercased().hasPrefix("video") {
                return .provider(AVAssetImageDataProvider(assetURL: URL, seconds: 0))
            }
            
            return URL.asSource()
        }
        
        return nil
    }
}

extension URL: FunWebImageSource {
    public func asSource() -> Source? {
        return isFileURL ?
            .provider(LocalFileImageDataProvider(fileURL: self, cacheKey: cacheKey)) :
            .network(self)
    }
}

public typealias FunWebImage = FunBox.WebImage
extension FunBox {
    public class WebImage {
        
        public static let manager = WebImage.Manager()
        
        public typealias Completion = (((image: UIImage?, error: String?))->Void)
        
        public enum Position: String {
            case `default` = "default"
            case backgrounder = "backgrounder"
        }
        
        public struct Config {
            public var position: Position = .default
            public var source: Source?
            public var holderImage: UIImage?
            public var state: UIControl.State = .normal
            public var complete: Completion?
            public var options: KingfisherOptionsInfo = [.transition(.fade(0.5))]
            public var progress: DownloadProgressBlock?
            public var indicatorType: IndicatorType?
        }
        
        fileprivate var config = Config()
        
        fileprivate let target: FunImageContainer
        init(target: FunImageContainer) {
            self.target = target
        }
        
        public func progress(_ progress: DownloadProgressBlock?) -> Self {
            config.progress = progress
            
            return self
        }
        
        public func resource(_ source: FunWebImageSource?) -> Self {
            config.source = source?.asSource()
            return self
        }
        
        public func holderImage(_ holderImage: UIImage?) -> Self {
            config.holderImage = holderImage
            return self
        }
        
        public func options(_ options: KingfisherOptionsInfo) -> Self {
            config.options.append(contentsOf: options)
            return self
        }
        
        public func indicatorType(_ indicatorType: IndicatorType) -> Self {
            config.indicatorType = indicatorType
            return self
        }
        
        public func response(_ complete: Completion?=nil) {
            config.complete = complete
            
            target.response(for: config)
        }
    }
}


extension UIButton: FunImageContainer {
    
    public func response(for config: FunWebImage.Config) {
        DispatchQueue.main.async {
            if let source = config.source {
                
                switch config.position {
                    case .default:
                        
                        self.kf.setImage(with: source, for: config.state, placeholder: config.holderImage, options: config.options, progressBlock: config.progress) { (result) in
                            switch result {
                                case let .success(data):
                                    
                                    if let complete = config.complete {
                                        complete((data.image,nil))
                                    }
                                case let .failure(error):
                                    
                                    self.setImage(config.holderImage, for: config.state)
                                    
                                    if let complete = config.complete {
                                        complete((nil,error.localizedDescription))
                                    }
                            }
                        }
                    case .backgrounder:
                        self.kf.setBackgroundImage(with: source, for: config.state, placeholder: config.holderImage, options: config.options, progressBlock: config.progress) { (result) in
                            switch result {
                                case let .success(data):
                                    
                                    if let complete = config.complete {
                                        complete((data.image,nil))
                                    }
                                case let .failure(error):
                                    
                                    self.setBackgroundImage(config.holderImage, for: config.state)
                                    
                                    if let complete = config.complete {
                                        complete((nil,error.localizedDescription))
                                    }
                            }
                        }
                        
                }
                
            } else {
                
                switch config.position {
                    case .default:
                        self.setImage(config.holderImage, for: self.state)
                    case .backgrounder:
                        self.setBackgroundImage(config.holderImage, for: self.state)
                }
                
                
                let errorString = "WebImageError: imageUrl is empty"
                
                if let complete = config.complete {
                    complete((nil,errorString))
                } else {
                    print(errorString)
                }
                
            }
        }
    }
    
}


extension UIImageView: FunImageContainer {
    public func response(for config: FunWebImage.Config) {
        DispatchQueue.main.async {
            if let source = config.source {
                if let indicatorType = config.indicatorType {
                    self.kf.indicatorType = indicatorType
                }
                self.kf.setImage(with: source, placeholder: config.holderImage, options: config.options, progressBlock: config.progress) { (result) in
                    switch result {
                        case let .success(data):
                            
                            if let complete = config.complete {
                                complete((data.image,nil))
                            }
                        case let .failure(error):
                            
                            self.image = config.holderImage
                            
                            if let complete = config.complete {
                                complete((nil,error.localizedDescription))
                            }
                    }
                }
            } else {
                
                self.image = config.holderImage
                
                let errorString = "WebImageError: imageUrl is empty"
                
                if let complete = config.complete {
                    complete((nil,errorString))
                } else {
                    print(errorString)
                }
                
            }
        }
    }
}

public extension FunNamespaceWrapper where T: UIButton {
    func webImageSource(_ source: FunWebImageSource?, for position: FunWebImage.Position = .default, status: UIButton.State = .normal) -> FunWebImage {
        
        let session = FunWebImage(target: wrappedValue)
        session.config.source = source?.asSource()
        session.config.position = position
        session.config.state = status
        return session
        
    }
}

public extension FunNamespaceWrapper where T: UIImageView {
    
    func webImageSource(_ source: FunWebImageSource?) -> FunWebImage {
        let session = FunWebImage(target: wrappedValue)
        session.config.source = source?.asSource()
        return session
        
    }
    
}

extension FunWebImage {
    public struct Manager {
        public var baseURL: String?
    }
}
