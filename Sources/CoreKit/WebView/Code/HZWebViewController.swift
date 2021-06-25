//
//  HZWebViewController.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/10/19.
//

import Foundation
import WebKit
open class HZWebViewController: UIViewController, HZController {
    
    deinit {
        debugPrint("HZWebViewController deinit")
    }
    
    public lazy var disposeBag = DisposeBag()
    
    // 是否显示导航条(默认显示)
    public var isActionBarShow: Bool = true {
        didSet {
            if isActionBarShow {
                fb.bottomView = actionBar
            } else {
                fb.bottomView = nil
            }
        }
    }
    
    // 导航条
    public lazy var actionBar: ActionBar = {
        let actionBar = ActionBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 49))
        actionBar.bind(webView: contentView, disposeBag: disposeBag)
        return actionBar
    }()
    
    
    
    // webView
    public lazy var contentView: HZWebView = {
        let configuration = WKWebViewConfiguration.default()
        
        let contentView = HZWebView(frame: self.view.bounds, configuration: configuration)
        // 添加此属性可触发侧滑返回上一网页与下一网页操作
        contentView.allowsBackForwardNavigationGestures = true
        
        // 监听canGoBack
        contentView.rx.canGoBack.response { [weak self] (canGoBack) in
            // 当webView支持返回的时候，关闭系统的pop手势响应
            self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = !canGoBack
            
        }.disposed(by: disposeBag)
        
        return contentView
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
//        fb.contentInsets = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        // 添加webView
        fb.contentView = contentView
        
        // 显示导航条
        isActionBarShow = true
    }
    
    
    open func initNavigationBar(navigationBar: HZNavigationBar) {
        navigationBar.backItemImage = Theme.Image.left_arrow?.withRenderingMode(.alwaysTemplate)
        navigationBar.backItem.tintColor = Theme.Color.darkText
        navigationBar.titleColor = Theme.Color.darkText
        
        fb.contentInsets = UIEdgeInsets(top: navigationBar.frame.maxY, left: 0, bottom: 0, right: 0)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //当webView离开时，打开系统的pop手势响应
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
}

extension HZWebViewController {
    public class ActionBar: UIView {
        let leftButton: UIButton
        let rightButton: UIButton
        public override init(frame: CGRect) {
            self.leftButton = UIButton()
            self.rightButton = UIButton()
            super.init(frame: frame)
            
            leftButton.tintColor = Theme.Color.lightBackground
            leftButton.setImage(Theme.Image.left_arrow?.withRenderingMode(.alwaysOriginal), for: .normal)
            leftButton.setImage(Theme.Image.left_arrow?.withRenderingMode(.alwaysTemplate), for: .disabled)
            leftButton.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside)
            
            rightButton.tintColor = Theme.Color.lightBackground
            rightButton.setImage(Theme.Image.right_arrow?.withRenderingMode(.alwaysOriginal), for: .normal)
            rightButton.setImage(Theme.Image.right_arrow?.withRenderingMode(.alwaysTemplate), for: .disabled)
            rightButton.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside)
            
            addSubview(leftButton)
            addSubview(rightButton)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        public func bind(webView: WKWebView, disposeBag: DisposeBag) {
            webView.rx.canGoBack.response { [weak self] (canGoBack) in
                self?.isHidden = (!webView.canGoBack && !webView.canGoForward)
                self?.leftButton.isEnabled = canGoBack
            }.disposed(by: disposeBag)
            
            webView.rx.canGoForward.response { [weak self] (canGoForward) in
                self?.rightButton.isEnabled = canGoForward
            }.disposed(by: disposeBag)
            
            handle = { [weak self] (sender) in
                if sender == self?.leftButton {
                    // 返回
                    webView.goBack()
                } else if sender == self?.rightButton {
                    // 前进
                    webView.goForward()
                }
            }
        }
        
        @objc private func action(sender: UIButton) {
            handle?(sender)
        }
        
        var handle: ((UIButton)->Void)?
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            
            leftButton.frame = CGRect(x: center.x - bounds.height - 30, y: 0, width: bounds.height, height: bounds.height)
            rightButton.frame = CGRect(x: center.x + 30, y: 0, width: bounds.height, height: bounds.height)
        }
    }
}

