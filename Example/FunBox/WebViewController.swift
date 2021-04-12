//
//  WebViewController.swift
//  FunBox_Example
//
//  Created by choarkinphe on 2020/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WebKit

struct User {
    var name: String?
}

class WebViewController: UIViewController {
    lazy var contentView: WKWebView = {
//        let userContentController = WKUserContentController()
//        userContentController.add(self, name: "telMobile")
        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
        
        let contentView = WKWebView(frame: self.view.bounds, configuration: configuration)
        // 添加此属性可触发侧滑返回上一网页与下一网页操作
        contentView.allowsBackForwardNavigationGestures = true
        contentView.uiDelegate = self
        contentView.navigationDelegate = self
        
        return contentView
    }()
    
    var url = "http://rdhangzhouapi.hz.com/H5/Index?openid=1f6f630482e4f5f9cdd9e6b65fb142c0#pages/Directories/RegionList"
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取编码后的URL
        fb.contentView = contentView
        guard let URL = URL(string: url) else { return }
        
        let request = URLRequest(url: URL)
        
        contentView.load(request)
        
        contentView.configuration.userContentController.add(self, name: "telMobile")
        
        if var name = user.name {
//            name = ""
            outPut(name: name)
        }
//
    }
    
    deinit {
        clear()
    }
    /**
     清理缓存
     */
    func clear() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    func outPut(name: String) -> String {
        
        return "姓名:\(name)"
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
    }
    
    
    
}

extension WKWebViewConfiguration {
    static func `default`() -> WKWebViewConfiguration {
//    static var `default`: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = WKUserContentController()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.minimumFontSize = 14
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        preferences.javaScriptCanOpenWindowsAutomatically = false
        
        configuration.preferences = preferences
        
        configuration.allowsInlineMediaPlayback = true

        //是使用h5的视频播放器在线播放还是使用原生播放器播放
        configuration.allowsInlineMediaPlayback = true
        //配置视频是否需要用户手动播放 设置NO 则会允许自动播放
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        //设置是否允许画中画技术 在特定设备上有效
        configuration.allowsPictureInPictureMediaPlayback = true

        // web内容处理池，由于没有属性可以设置，也没有方法可以调用，不用手动创建
        //    configuration.processPool = [HZWebKitManager manager].processPool;
        return configuration
    }
}
