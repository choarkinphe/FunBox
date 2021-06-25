//
//  HZWebView.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/9/15.
//

import UIKit
import WebKit
import RxWebKit

open class HZWebView: WKWebView {
    // 回收站
    private var disposeBag = DisposeBag()
    // 进度条
    public let progressView: UIProgressView
    // 监听request
    var request_behavior = BehaviorRelay<URLRequest?>(value: nil)
    // 错误信息
    public var error = BehaviorRelay<WebError?>(value: nil)
    // 即将请求
    private var request_handle: ((inout URLRequest)->Void)?
    public func request_resume(_ handle: @escaping ((inout URLRequest)->Void)) {
        request_handle = handle
    }
    
    // 添加userAgent
    public func add(userAgent: String?) {
        if let userAgent = userAgent {
            rx.evaluateJavaScript("navigator.userAgent").response { (result) in
                if let oldAgent = result as? String {
                    let newAgent = oldAgent + userAgent
                    self.customUserAgent = newAgent
                }
            }.disposed(by: disposeBag)
        }
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 2))
        super.init(frame: frame, configuration: configuration)
        progressView.tintColor = .red
        progressView.trackTintColor = .clear
        addSubview(progressView)
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // 添加读取所有图片的脚本
        configuration.userContentController.addUserScript(.getImages)
        
        // 绑定request，当request发生变更时，自动请求页面
        request_behavior.bind { [weak self] (request) in
            if var request = request {
                self?.request_handle?(&request)
                self?.load(request)
            }
        }.disposed(by: disposeBag)
        
        // 观察加载进度
        rx.estimatedProgress.response { [weak self] (progress) in
            self?.progressView.progress = Float(progress)
        }.disposed(by: disposeBag)
        
        // 开始加载
        rx.loading.response { [weak self] (isLoding) in
            if isLoding {
                UIView.animate(withDuration: 0.4) {
                    self?.progressView.alpha = 1
                }
            }
        }.disposed(by: disposeBag)
        
        // 加载完成
        rx.didFinishNavigation.response { [weak self] (result) in
            guard let this = self else { return }
            UIView.animate(withDuration: 0.4) {
                this.progressView.alpha = 0
            }
            this.rx.evaluateJavaScript("getImages()").response(onNext: { (result) in
                if let result = result as? String {
                    // 获取所有图片的url+·
                    let imagePaths = result.components(separatedBy: "+")
                    print(result)
                    print(imagePaths)
                }
                
            }).disposed(by: this.disposeBag)
            
            this.rx.evaluateJavaScript("registerImageClickAction();").response { (result) in
                
            }.disposed(by: this.disposeBag)
            
        }.disposed(by: disposeBag)
        
        // 加载失败
        rx.didFailNavigation.response { [weak self] (result) in
            UIView.animate(withDuration: 0.4) {
                self?.progressView.alpha = 0
            }
        }.disposed(by: disposeBag)
        
        
        
        //  MARK: - 导航每次跳转调用跳转
        // 决定导航的动作，通常用于处理跨域的链接能否导航。
        // WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接单独处理。
        // 但是，对于Safari是允许跨域的，不用这么处理。
        // 这个是决定是否Request
//        rx.decidePolicyNavigationAction.response { (navigation) in
//
//            if (navigation.action.request.url?.scheme?.contains("http") == true) {
//                // 普通http链接的直接允许
//                navigation.handler(.allow)
////                return
//            }
//
//            //预览图片
//            if navigation.action.request.url?.scheme?.contains("image-preview") == true {
//                print("预览图片")
////                print(self.i)
//            }
//
//            //默认允许
//            navigation.handler(.allow)
//
//        }.disposed(by: disposeBag)
        
        // 处理页面请求Response信息
        rx.decidePolicyNavigationResponse.response { (navigation) in
            
            if let response = navigation.reponse.response as? HTTPURLResponse {
                debugPrint("response:\(response)")
                // 响应不正常正常时
                if (response.statusCode < 200 || response.statusCode > 300) {
                    
                    // 加载失败，如果外部有处理，就传递出去
                    
                    // 取消请求并跳出
                    navigation.handler(.cancel)
                    return
                }
            }
            
            // 默认允许
            navigation.handler(.allow)
            
        }.disposed(by: disposeBag)
        
        //  MARK: - 用于授权验证的API，与AFN、UIWebView的授权验证API是一样的
        //用于授权验证的API，与AFN、UIWebView的授权验证API是一样的
        rx.didReceiveChallenge.response { (result) in
            // 判断服务器采用的验证方法
            if result.challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let serverTrust = result.challenge.protectionSpace.serverTrust {
                let credential = URLCredential.init(trust: serverTrust)
                result.handler(.useCredential,credential)
                
                return
            }
            // 验证失败，取消本次验证
            result.handler(.cancelAuthenticationChallenge,nil)
            
        }.disposed(by: disposeBag)
        
//        rx.observe(CGRect.self, "frame").response { (frame) in
//
//            self.setNeedsLayout()
//        }.disposed(by: disposeBag)
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 绑定bridge
    public func bind(bridge: HZWebBridge) {
        // 添加js事件
        bridge.scripts_behavior.bind { [weak self] (scripts) in
            guard let this = self else { return }
            scripts.forEach { (item) in
                this.configuration.userContentController.removeScriptMessageHandler(forName: item.key.rawValue)
                this.configuration.userContentController.rx.scriptMessage(forName: item.key.rawValue).response { (message) in
                    // 有传入的脚本
                    if let script = item.value {
                        // 交给传入的脚本处理
                        script(message.body)
                    } else {
                        // 未找到传入脚本
                        // 尝试路由跳转
                        HZCoreKit.router.open(page: .script(message: message)) { (response) in
                            
                        }
                    }

                }.disposed(by: this.disposeBag)
            }
        }.disposed(by: disposeBag)

    }
    
    public func load(url: URLConvertable?, options: HZWebViewOptions?=nil, params: URLParams?=nil) {
        // 首先使用默认的编码规则
//        var characterSet: CharacterSet = .default
        
        guard var url = url else {
            // 未知错误
            error.accept(.unknown)
            return
        }
        
        var params_characters: CharacterSet?
        
        options?.forEach { (option) in
            if option == .url_characterSet,
               let set = option.paramter as? CharacterSet,
               let set_url = url.characterSet(set) {
                // 查找到URL编码规则，设置编码规则后的url
                url = set_url
            }
            if option == .params_characterSet,
               let set = option.paramter as? CharacterSet {
                // 查找到参数编码
                params_characters = set
            }
        }
        
        // 编码并拼接参数后获取真实URL
        guard let URL = url.appendQuery(params, characters: params_characters ?? .urlQueryAllowed) else {
            
            // 未知错误
            error.accept(.unknown)
            return
        }

        let request = URLRequest(url: URL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)

        request_behavior.accept(request)
    }
    
    public func load(fileName: String) {
        
        var fileName = fileName
        
        if !fileName.contains("html") {
            fileName = fileName + ".html"
        }
        
        if let path = Bundle.main.path(forResource: fileName, ofType:nil) {
            let request = URLRequest(url: URL(fileURLWithPath: path))
            
            request_behavior.accept(request)
            
        } else {
            // 找不到页面
            error.accept(.notFound)
        }
        
        
    }
    

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        progressView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 2)
    }
    
    deinit {
        debugPrint("HZWebView deinit")
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
}

extension WKUserScript {
    
    public static var getImages: WKUserScript {
        guard let path = HZWebView.bundle?.path(forResource: "getImages", ofType: "js"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let code = String(data: data, encoding: .utf8) else { return WKUserScript()
        }
        
        return WKUserScript(source: code, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
}



extension HZWebView: HZModuleProtocol {
    public static var bundle: Bundle? {
        
        if let url = Bundle(for: self).url(forResource: "WebView", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
    
    public static func install() {
//        HZCoreKit.router.regist(host: .script, router: HZWebBridge.self)
    }
}

extension HZWebView {
    public struct WebError: LocalizedError, Equatable {
        // description会直接传入给localizedDescription
        public init(description: String?) {
            self.description = description
        }
        // 内部变量暂存错误信息
        private var description: String?
        
        public var code: Int = 0
        
        public var errorDescription: String? {
            return description
        }
        
        public static var notFound: WebError {
            var error = WebError(description: "抱歉！您要访问的页面弄丢了")
            error.code = 404
            return error
        }
        
        public static var unknown: WebError {
            var error = WebError(description: nil)
            error.code = 500
            return error
        }
    }
}

// MARK: - RequestOptions
public typealias HZWebViewOptions = [HZWebView.Option]

extension HZWebView {

    public struct Option: Equatable {
        
        public enum CharacterSetTarget {
            case URL
            case Params
        }
        
        public static func == (lhs: HZWebView.Option, rhs: HZWebView.Option) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        var paramter: Any?
        private let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        // 自定义编码规则
        fileprivate static let url_characterSet = Option(rawValue: "url_characterSet")
        fileprivate static let params_characterSet = Option(rawValue: "params_characterSet")
        
        public static func characterSet(_ set: CharacterSet = .default, for target: CharacterSetTarget) -> Option {
            if target == .URL {
                var option = Option(rawValue: "url_characterSet")
                option.paramter = set
                return option
            } else {
                var option = Option(rawValue: "params_characterSet")
                option.paramter = set
                return option
            }

        }

    }
}



extension WKWebViewConfiguration {
    
    // 创建默认的Configuration
    static func `default`() -> WKWebViewConfiguration {

        let configuration = WKWebViewConfiguration()

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

