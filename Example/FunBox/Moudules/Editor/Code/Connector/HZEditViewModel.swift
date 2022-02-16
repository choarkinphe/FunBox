//
//  HZEditViewController.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/11/3.
//

import Foundation

extension HZEditor {
    
    class ViewModel: ViewModelable {
        
        // 自定义配置
        var config = Config()
        
        var disposeBag = DisposeBag()
        // 方便调用的resource信息
        var resource: [MediaElement]? {
            if let resource = resource_behavior.value {
                if let result = resource as? [MediaElement] {
                    return result
                } else {
                    var result = [MediaElement]()
                    resource.forEach({ (item) in
                        result.append(MediaElement(image: item.image, asset: item.asset, url: item.url))
                    })
                    return result
                }
             
            }
            return nil
        }
        // 设置新的resource
        func set(resource: [HZEditorImage]?) {
            resource_behavior.accept(resource)
        }
        
        // 添加resource
        func add(resource: [HZEditorImage]?) {
            guard let new = resource else { return }
            var elements = self.resource ?? [HZEditorImage]()
            elements.append(contentsOf: new)
            resource_behavior.accept(elements)
        }
        // resouce的监听
        var resource_behavior = BehaviorRelay<[HZEditorImage]?>(value: nil)
        // text的监听（与textView动态绑定）
        var text_behavior = BehaviorRelay<String>(value: "")
        
        // 喂一条数据进来
        func feed(content: HZEditContentable?) {
        
            text_behavior.accept(content?.text ?? "")
            
            resource_behavior.accept(content?.medias)
            
        }
        
        // 还可选择多少张照片
        private var maxCount: Int {
            return config.imageCount - (resource?.count ?? 0)
        }
        
        // 返回
        func goBack() {
            FunBox.alert
                .title("提示")
                .message("真的要退出吗？")
                .addAction(title: "再想想", style: .cancel)
                .addAction(title: "退出", style: .default) { (action) in
                    UIApplication.shared.fb.frontController?.dismiss(animated: true, completion: {
                        
                    })
                }
                .present()
        }
        
        // 提交事件的传递
//        var submitHandle: (((content: HZEditContentable, dismiss: ((Bool)->Void)))->Void)?
//        var submitHandle: SubmitHandle<Content>?
        var submit: ((UIButton?)->Void)?
        
        // 提交
        func submit(sender: UIButton?=nil) {
            
            submit?(sender)
            
            // 先关闭提交按钮事件，防止重复点击
//            sender?.isEnabled = false
            
//            let dismiss = { (finished: Bool) in
//                if finished {
//                    UIApplication.shared.fb.frontController?.dismiss(animated: true, completion: {
//                        
//                    })
//                }
//                // 数据处理完成后，打开交互
//                sender?.isEnabled = true
//            }
//            // 创建临时数据，丢出去
//            var content = Content()
//            content.text = text_behavior.value
//            content.medias = resource
//            submitHandle?((content,dismiss))
        }
        
        func pickImages() {
            FunImageHelper.default.allowPickingVideo(false).maxImagesCount(maxCount).response(sourceType: MediaElement.self, complete: { (resource) in
                // 调用添加的方法，这样才支持增量添加照片
                self.add(resource: resource)
            })
        }
    }
}


