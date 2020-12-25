//
//  FunHolder.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/24.
//

import UIKit
extension UIView: HolderNamespaceWrappable {
    public struct Holder {
        let imageName: String
        var description: String?
        public init(imageName: String, description: String?=nil) {
            self.imageName = imageName
            self.description = description
        }
        
        public static var faild = Holder(imageName: "fb_holder_image_faild", description: "加载失败")
        public static var load = Holder(imageName: "fb_holder_image_load", description: "加载中")
        public static var empty = Holder(imageName: "fb_holder_image_empty", description: "暂无数据")
        public static var fix = Holder(imageName: "fb_holder_image_fix", description: "修复中")
        public static var notFound = Holder(imageName: "fb_holder_image_notFound", description: "加载异常")
    }
    
    fileprivate struct Key {
        static var identifier: String = "com.funbox.holder.identifier"
        static var handle: String = "com.funbox.holder.handle"
    }

}
public extension HolderNamespaceWrapper where T : UIView {

    var identifier: String? {

        return objc_getAssociatedObject(wrappedValue, &UIView.Key.identifier) as? String
    }
    
    func set(identifier: String?) {
        objc_setAssociatedObject(wrappedValue, &UIView.Key.identifier, identifier, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    private func set(handle: ((UIView.Holder)->Void)?) {
        objc_setAssociatedObject(wrappedValue, &UIView.Key.handle, handle, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
//
    private var handle: ((UIView.Holder)->Void)? {

        return objc_getAssociatedObject(wrappedValue, &UIView.Key.handle) as? ((UIView.Holder)->Void)
    }
    
    func touchBegin(_ handle: ((UIView.Holder)->Void)?) {
//        holderView?.handle = handle
        set(handle: handle)
    }
    
    func set(_ holder: UIView.Holder = .empty) {
        if let holderView = holderView {
         
            holderView.holder = holder
        }
    }
    
    func show(_ holder: UIView.Holder?) {
        guard let holder = holder else {
            dismiss()
            return
        }
        let holderView = HolderView(frame: wrappedValue.bounds)
        
        holderView.holder = holder
        
        if let scrollView = self.wrappedValue as? UIScrollView {
            scrollView.isScrollEnabled = false
        }
        for item in wrappedValue.subviews {
            if !item.isHidden {
                item.isHidden = true
                
                item.holder.set(identifier: (item.holder.identifier ?? "") + "hiddenFlag")
            }
            
        }
        
        wrappedValue.addSubview(holderView)

        holderView.handle = handle
        
    }
    
    func dismiss() {
        if let scrollView = self.wrappedValue as? UIScrollView {
            scrollView.isScrollEnabled = true
        }
        if let holdView = holderView {
            holdView.removeFromSuperview()
        }
        
        for item in wrappedValue.subviews {
            
            if let identifier = item.holder.identifier, identifier.contains("hiddenFlag") {
                item.isHidden = false
                item.holder.set(identifier: identifier.fb.subString(to: identifier.count - 10))
            }
            
        }
    }
    
    // holder是否显示中
    var isShowing: Bool {
        
        return wrappedValue.viewWithTag(181191101) != nil
    }
    
    private var holderView: HolderView? {
        for item in wrappedValue.subviews {
            if item is HolderView {
                return item as? HolderView
            }
        }

        return nil
    }
    
}

fileprivate class HolderView: UIView {
    var imageView = UIImageView()
    var descriptionLabel = UILabel()
    
    var holder: Holder {
        didSet {

            if let image = UIImage(named: holder.imageName) {
                // 默认获取项目中的image
                imageView.image = image
            } else {
                // 项目中未找到，再获取包内数据
                imageView.image = UIImage(named: holder.imageName, in: FunBox.bundle, compatibleWith: nil)
            }
            
            descriptionLabel.text = holder.description
        }
    }
    
    override init(frame: CGRect) {
        self.holder = .empty
        super.init(frame: frame)
        
        backgroundColor = .clear
        tag = 181191101
        descriptionLabel.textColor = .darkText
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        addSubview(imageView)
        addSubview(descriptionLabel)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchAction(sender:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var handle: ((Holder)->Void)?
    
    @objc private func touchAction(sender: UITapGestureRecognizer) {
        handle?(holder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let image = imageView.image {
            imageView.frame = CGRect.init(x: (bounds.size.width - image.size.width) / 2, y: (bounds.size.height - image.size.height) / 2.5, width: image.size.width, height: image.size.height)
        }
        descriptionLabel.frame = CGRect(x: 0, y: imageView.frame.maxY + 12, width: bounds.size.width, height: 30)
    }
}


// 创建一个holder的命名空间，方便扩展方法
public protocol HolderNamespaceWrappable {
    associatedtype HolderWrapperType
    var holder: HolderWrapperType { get }
    static var holder: HolderWrapperType.Type { get }
}

public extension HolderNamespaceWrappable {
    var holder: HolderNamespaceWrapper<Self> {
        return HolderNamespaceWrapper(value: self)
    }
    
    static var holder: HolderNamespaceWrapper<Self>.Type {
        return HolderNamespaceWrapper.self
    }
}

public struct HolderNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}

