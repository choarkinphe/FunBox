//
//  HZEditToolBar.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/11/4.
//

import UIKit
extension HZEditor {
    // MARK: - 用于承载toolBar和imageBar
    class BottomView: UIView {
        private let imageBar: ImageBar
        private let toolBar: ToolBar
        override init(frame: CGRect) {
            imageBar = ImageBar()
            toolBar = ToolBar()
            super.init(frame: frame)
            addSubview(imageBar)
            addSubview(toolBar)
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            imageBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 64)
            toolBar.frame = CGRect(x: 0, y: bounds.height - 49, width: bounds.width, height: 49)
        }
        
        private var disposeBag = DisposeBag()
        func bind(viewModel: HZEditor.ViewModel) {
            imageBar.bind(viewModel: viewModel)
            toolBar.bind(viewModel: viewModel)
            
            viewModel.resource_behavior.response { [weak self] (resource) in
                guard let this = self else { return }
                // resource为空的时候关闭imageBar
                if resource != nil {
                    self?.imageBar.isHidden = false
                    self?.bounds = CGRect(x: 0, y: 0, width: this.bounds.width, height: 113)
                } else {
                    self?.imageBar.isHidden = true
                    self?.bounds = CGRect(x: 0, y: 0, width: this.bounds.width, height: 49)
                }
            }.disposed(by: disposeBag)
        }
    }
}
 
extension HZEditor {
    // MARK: - 用于承载已选择的照片
    class ImageBar: UIView {
        private var disposeBag = DisposeBag()
        private let contentView: UIScrollView
        private var images = [Item]()
        override init(frame: CGRect) {
            contentView = UIScrollView()
            super.init(frame: frame)
            
            contentView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            contentView.showsHorizontalScrollIndicator = false
            contentView.showsVerticalScrollIndicator = false
            addSubview(contentView)
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func layout(resource: [HZEditorImage]?) {
            guard let resource = resource else { return }
            // 先清空上次加载的图片
            images.removeAll()
            contentView.fb.removeAllSubviews(type: Item.self)
            // 遍历resource，创建新的Item
            resource.forEach { (item) in
                let imageView = Item()
                imageView.contentMode = .scaleAspectFill
                imageView.layer.masksToBounds = true
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(preview(sender:))))
                imageView.isUserInteractionEnabled = true
                contentView.addSubview(imageView)
                images.append(imageView)
                
                if let image = item.image {
                    // 优先读取本地图片
                    imageView.image = image
                } else if let url = item.url {
                    // 无本地图片时，加载url
                    imageView.webImage.resource(url).show()
                }
            }

            // 视图添加完成后，重新布局
            setNeedsLayout()
            
        }
        
        @objc private func preview(sender: UIGestureRecognizer) {
            guard let imageView = sender.view as? UIImageView else { return }
            previewHandle?(imageView.tag)
        }
        
        // 删除的handle
        private var removeHandle: ((Int)->Void)?
        // 预览的handle
        private var previewHandle: ((Int)->Void)?
        
        func bind(viewModel: HZEditor.ViewModel) {
            viewModel.resource_behavior.response { [weak self] (resource) in
                self?.layout(resource: resource)
            }.disposed(by: disposeBag)
            
            // 删除
            removeHandle = {(index) in
                // 移除viewModel中对应的数据
                if var resource = viewModel.resource {
                    resource.remove(at: index)
                    viewModel.set(resource: resource)
                }
                
            }
            
            // 预览
            previewHandle = { (index) in
                if let resource = viewModel.resource {
                    // 获取viewModel中的数据预览
                    FunMediaHelper.preview(resource: resource, index: index)
                }
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            contentView.frame = bounds
            
            let itemSize = CGSize(width: bounds.height - 4, height: bounds.height - 4)
            for (index, imageView) in images.enumerated() {
                imageView.frame = CGRect(x: CGFloat(index) * (itemSize.width + 8), y: 2, width: itemSize.width, height: itemSize.height)
                imageView.tag = index
                imageView.deleteHandle = { (sender) in
                    self.removeHandle?(index)
                }
                contentView.contentSize = CGSize(width: imageView.frame.maxX, height: bounds.height)
            }
        }
        
        // MARK: - 带删除按钮的UIImageView（内部使用）
        private class Item: UIImageView {
            lazy var deleteButton: UIButton = {
                let button = UIButton()
                button.imageEdgeInsets = UIEdgeInsets(top: -5, left: 5, bottom: 5, right: -5)
                button.setImage(UIImage(named: "image_del", in: HZEditor.bundle, compatibleWith: nil), for: .normal)
                button.addTarget(self, action: #selector(delete(sender:)), for: .touchUpInside)
                addSubview(button)
                return button
            }()
            
            var deleteHandle: ((UIButton)->Void)?
            @objc private func delete(sender: UIButton) {
                deleteHandle?(sender)
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                deleteButton.frame = CGRect(x: bounds.width - 24, y: 0, width: 24, height: 24)
            }
        }
    }
}

// MARK: - 提交、取消等功能按钮的视图
extension HZEditor {
    class ToolBar: UIView {
        fileprivate let submitButton = UIButton()
        fileprivate let cancelButton = UIButton()
        fileprivate let imageButton = UIButton()
        private var disposeBag = DisposeBag()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            submitButton.setTitle("提交", for: .normal)
            submitButton.setTitleColor(.white, for: .normal)
            submitButton.setTitleColor(Theme.Color.lightText, for: .disabled)
            submitButton.setBackgroundImage(UIImage.fb.color(.red), for: .normal)
            submitButton.setBackgroundImage(UIImage.fb.color(Theme.Color.line), for: .disabled)
            submitButton.layer.cornerRadius = 4
            submitButton.layer.masksToBounds = true
            
            addSubview(submitButton)
            
            cancelButton.setTitle("取消", for: .normal)
            cancelButton.setTitleColor(Theme.Color.lightText, for: .normal)
            
            addSubview(cancelButton)
            
            imageButton.setImage(UIImage(named: "image_picker", in: HZEditor.bundle, compatibleWith: nil), for: .normal)
            
            addSubview(imageButton)
            
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func bind(viewModel: HZEditor.ViewModel) {
            
            // 选择照片
            imageButton.rx.tap.response {
                viewModel.pickImages()
            }.disposed(by: disposeBag)
            
            // 提交
            submitButton.rx.tap.response { [weak self] in
                viewModel.submit(sender: self?.submitButton)
            }.disposed(by: disposeBag)
            
            // 取消(退出)
            cancelButton.rx.tap.response {
                viewModel.goBack()
            }.disposed(by: disposeBag)
        }
        

        override func layoutSubviews() {
            super.layoutSubviews()
            
            imageButton.frame = CGRect(x: 8, y: 8.5, width: 32, height: 32)
            
            submitButton.frame = CGRect(x: bounds.width - 72, y: 10.5, width: 64, height: 28)
            
            cancelButton.frame = CGRect(x: submitButton.frame.minX - 72, y: 10.5, width: 64, height: 24)
        }
        
    }
}
