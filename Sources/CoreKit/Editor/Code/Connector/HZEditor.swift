//
//  HZEditor.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/11/3.
//

import Foundation
// MARK: - 关键
// 内容的数据协议
public protocol HZEditContentable {
    var text: String? { get set }
    var medias: [HZEditorImage]? { get set }
    init()
}
// 媒体资源的协议
public protocol HZEditorImage: FunPickResource {
    var url: String? { get set }
}

public typealias HZEditorOptions = [HZEditor.Option]

public class HZEditor: HZModuleProtocol {
    
    public typealias SubmitHandle<T> = (((content: T, dismiss: ((Bool)->Void)))->Void) where T: HZEditContentable
    
    public static var bundle: Bundle? {
        if let url = Bundle(for: self).url(forResource: "Editor", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
    
    // 内部的配置信息
    struct Config {
        // 允许最大照片数
        var imageCount: Int = 9
        // 字数限制
        var textCount: Int = 5000
    }
    
    // 编辑器的页面
    private var editor: ViewController?
    
    public init() {
        // 创建时就生成editor
        editor = ViewController()
    }
    

    
    // 编辑模式下，feed数据进来
    public func feed(content: HZEditContentable?) -> Self {
    
        editor?.viewModel.feed(content: content)
        
        return self
    }
    
    // 添加配置
    public func feed(options: HZEditorOptions) -> Self {
        
        // 遍历options，生成对应的配置文件
        options.forEach { (item) in
            if item == .imageCount, let imageCount = item.external as? Int {
                editor?.viewModel.config.imageCount = imageCount
            }
            if item == .textCount, let textCount = item.external as? Int {
                editor?.viewModel.config.textCount = textCount
            }
            
        }

        return self
    }
    
    // 开启编辑框
//    public func present(navigation: @escaping ((content: HZEditContentable, dismiss: ((Bool)->Void)))->Void) {
//
////        editor.viewModel.submitHandle = navigation
//        
////        let nav = NavigationController(rootViewController: editor)
////        UIApplication.shared.fb.frontController?.present(nav, animated: true, completion: {
////
////        })
//        
//        response(type: Content.self, navigation: navigation)
//    }
    
    // 开启编辑框
    public func response<T>(type: T.Type, navigation: @escaping SubmitHandle<T>) where T: HZEditContentable {
        if let editor = editor {
            editor.viewModel.submit = { (sender) in
                
                // 先关闭提交按钮事件，防止重复点击
                sender?.isEnabled = false
                
                let dismiss = { (finished: Bool) in
                    if finished {
                        UIApplication.shared.fb.frontController?.dismiss(animated: true, completion: {
                            
                        })
                    }
                    // 数据处理完成后，打开交互
                    sender?.isEnabled = true
                }
                // 创建临时数据，丢出去
    //            var content = Content()
    //            content.text = text_behavior.value
    //            content.medias = resource
                
                var content = T()
                content.medias = editor.viewModel.resource
                content.text = editor.viewModel.text_behavior.value
                navigation((content,dismiss))
            }
            
            let nav = NavigationController(rootViewController: editor)
            UIApplication.shared.fb.frontController?.present(nav, animated: true, completion: {
                
            })
        }
        
        
        
        
        
    }

}

private typealias Options = [HZEditor.Option]

extension HZEditor {
    
    // 默认类
    public static var `default`: HZEditor {
        let instance = HZEditor()
        return instance
    }
    
    public struct Option: Equatable {
        public static func == (lhs: Option, rhs: Option) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        let rawValue: String
        var external: Any?
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        static let imageCount = Option(rawValue: "imageCount")
        public static func imageCount(_ count: Int) -> Option {
            var imageCount = Option(rawValue: "imageCount")
            imageCount.external = count
            return imageCount
        }
        
        static let textCount = Option(rawValue: "textCount")
        public static func textCount(_ count: Int) -> Option {
            var textCount = Option(rawValue: "textCount")
            textCount.external = count
            return textCount
        }
    }
}
