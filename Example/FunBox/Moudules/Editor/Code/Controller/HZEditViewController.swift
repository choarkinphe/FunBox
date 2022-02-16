//
//  HZEditViewController.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/11/3.
//

import UIKit
public typealias HZEditViewController = HZEditor.ViewController

extension HZEditor {
    open class ViewController: UIViewController, HZController {
        
        var viewModel = ViewModel()
        
        open override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .white
            // 关联ContentView
            fb.contentView = contentView
            contentView.bind(viewModel: viewModel)
            
            // 关联底部工具栏
            fb.bottomView = bottomView
            bottomView.bind(viewModel: viewModel)

            // 监听键盘
            fb.observer.keyboardWillShow { [weak self] (keyBoard) in
                guard let this = self else {return}
                UIView.animate(withDuration: keyBoard.duration, delay: 0, options: .allowAnimatedContent, animations: {
                    if keyBoard.isShow { // 键盘显示
//                        this.bottomView.isEditMode = true
                        this.bottomView.frame = CGRect(x: 0, y: this.view.bounds.height - keyBoard.rect.height - this.bottomView.frame.height, width: this.bottomView.frame.width, height: this.bottomView.frame.height)
//                        rect = keyBoard.rect
                        this.contentView.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoard.rect.height + 8, right: 0)
                        
                    } else {
//                        this.bottomView.isEditMode = false
                        DispatchQueue.main.async {
                            this.contentView.textView.contentInset = .zero
                            this.bottomView.frame = CGRect(x: 0, y: 0, width: this.bottomView.frame.width, height: this.bottomView.frame.height)
                            this.fb.isNeedLayout = true
                            this.view.setNeedsLayout()
                        }
                    }
                }) { (complete) in
                    if !keyBoard.isShow {
                        this.fb.isNeedLayout = true
                        this.view.setNeedsLayout()
                    }
                    
                }
            }
            
        }
        
        // 设置导航栏样式
        public func initNavigationBar(navigationBar: HZNavigationBar) {
            fb.contentInsets = UIEdgeInsets(top: navigationBar.frame.maxY, left: 0, bottom: 0, right: 0)
            navigationBar.backItemImage = Theme.Image.close?.withRenderingMode(.alwaysTemplate)
            navigationBar.backItem.tintColor = Theme.Color.darkText
            navigationBar.title = "回复"
            navigationBar.backAction({ [weak self] (sender) in
                self?.viewModel.goBack()
            })
        }
        
        // 输入内容（TextView）
        lazy var contentView: ContentView = {
            let contentView = ContentView()
            
            contentView.textView.placeholder = "请输入"
            
            return contentView
        }()
        
        // 底部工具栏
        lazy var bottomView: BottomView = {
            let bottomView = BottomView(frame: CGRect(x: 0, y: 0, width: HZScreen.width, height: 113))

            return bottomView
        }()
    }
}


extension HZEditor {
    // 内部导航栏控制器
    class NavigationController: UINavigationController {
        override init(rootViewController: UIViewController) {
            super.init(rootViewController: rootViewController)
            
            modalPresentationStyle = .overFullScreen
            
            
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            super.pushViewController(viewController, animated: animated)
            
        }
    }
}
