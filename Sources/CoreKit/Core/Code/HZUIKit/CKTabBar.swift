//
//  HZTabBar.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/11/23.
//

import UIKit
open class CKTabBar: UIStackView {
    
    public struct Style {
        public var size: CGSize = .init(width: 44, height: 3)
        public var color: UIColor = Theme.Color.main
        public var isHidden: Bool = false
    }
    
    public var bottomLine: Style
    public var indicator: Style
    
    public private(set) var item_array = [UIControl]()
    private var line_view = CALayer()
    private var indicator_view = UIView()
    
    private var select = BehaviorRelay<Int?>(value: nil)
    
    public override init(frame: CGRect) {
        bottomLine = Style()
        bottomLine.color = Theme.Color.line
        bottomLine.size = CGSize(width: CKScreen.width, height: 1)
        indicator = Style()
        super.init(frame: frame)
        backgroundColor = .white
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        
        
        layer.addSublayer(line_view)
        
        
        addSubview(indicator_view)
        
        
        select.bind { [weak self] (index) in
            if let index = index {
                self?.scroll(to: index, animated: true)
                
                self?.select_handler?(index)
            }
        }.disposed(by: disposeBag)
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func set(items: [UIControl]) {
        // 先清空旧数据
        clean()
        
        for (index,item) in items.enumerated() {
            item.tag = index
            item_array.append(item)
            item.addTarget(self, action: #selector(select(sender:)), for: .touchUpInside)
            addArrangedSubview(item)
        }
    }
    
    public func clean() {
        // 清空旧数据
        fb.removeAllSubviews(type: UIControl.self)
        item_array.removeAll()
    }

    
    fileprivate var isLock = false
    @objc private func select(sender: UIControl) {
        
        select.accept(sender.tag)
        
    }
    
    private var select_handler: ((Int)->Void)?
    public func tab_select(_ handler: ((Int)->Void)?) {
        select_handler = handler
    }
    
    public func item(for index: Int) -> UIControl? {
        if item_array.count > index {
            return item_array[index]
        }
        return nil
    }
    
    public func scroll(to index: Int, animated: Bool?=nil) {
        guard let sender = item_array.first(where: { (item) -> Bool in
            return item.tag == index
        }) else { return }
        
        for item in item_array {
            item.isSelected = false
        }
        sender.isSelected = true
        
        if isLock {
            return
        }
        
        isLock = true
        UIView.animate(withDuration: animated == true ? 0.35 : 0.15, animations: {
            self.indicator_view.center.x = sender.frame.midX
        }) { (completion) in
            self.setNeedsLayout()
            self.isLock = false
        }
        
    }
    
    private var disposeBag = DisposeBag()
    public func bind(scrollView: UIScrollView, disposeBag: DisposeBag?=nil) {
        
        scrollView.rx.contentOffset.response { [weak self] (offset) in
            guard let this = self, (scrollView.isDragging || scrollView.isDecelerating) else { return }
            // 获取scrollView的contentSize，计算比例
            let scale = scrollView.contentSize.width / this.bounds.width
            
            // 计算偏移量（规定scrollView的分页为一屏宽）
            // 当前页的页面中点对应indicator的中点
            let point = CGPoint(x: offset.x + CKScreen.width / 2.0, y: offset.y)
            
            let position = CGPoint(x: point.x / scale, y: offset.y)
            
            this.indicator_view.center.x = position.x
            
            
        }.disposed(by: disposeBag ?? self.disposeBag)
        
        scrollView.rx.didEndDecelerating.response { [weak self] in
            
            // 滚动结束后，获取当前页
            let page = Int(scrollView.contentOffset.x / CKScreen.width)
            // 滚动到该页
//            self?.scroll(to: page)
//
//            self?.select_handler?(page)
            self?.select.accept(page)
            
        }.disposed(by: disposeBag ?? self.disposeBag)
        
        
        select.bind { (index) in
            
            if let index = index {
                let offset = CKScreen.width * CGFloat(index)
                
                scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
            }
            
        }.disposed(by: disposeBag ?? self.disposeBag)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        
        line_view.isHidden = bottomLine.isHidden
        line_view.backgroundColor = bottomLine.color.cgColor
        line_view.frame = CGRect(x: (bounds.width - bottomLine.size.width) / 2.0, y: bounds.size.height - bottomLine.size.height, width: bottomLine.size.width, height: bottomLine.size.height)
        
        
        indicator_view.backgroundColor = indicator.color
        indicator_view.isHidden = indicator.isHidden
        for sender in item_array {
            
            if sender.isSelected {
                
                indicator_view.frame = CGRect(x: sender.frame.midX - indicator.size.width / 2.0, y: bounds.size.height - indicator.size.height, width: indicator.size.width, height: indicator.size.height)
                
            }
        }
    }
}
