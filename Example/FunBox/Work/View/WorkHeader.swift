//
//  WorkHeader.swift
//  Store
//
//  Created by choarkinphe on 2020/6/20.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit
import FunModules

extension Work {
    class Header: UIScrollView {
        
        func bind(viewModel: Work.ViewModel) {
//            viewModel.tabs { (tabs) in
//                self.tabs = tabs
//            }
        }
        
        var tabs: [Tab]? {
            didSet {
                //                buttons.removeAll()
                if let tabs = tabs {
                    for (index,tab) in tabs.enumerated() {
                        let button = FunButton(.imageTop)
                        if let iconName = tab.icon {
                            button.setImage(UIImage(named: iconName), for: .normal)
                        } else {
                            button.setImage(UIImage.fb.color(UIColor.fb.random, size: CGSize(width: 50, height: 50)), for: .normal)
                        }
                        button.setTitle(tab.name, for: .normal)
                        button.setTitleColor(.darkText, for: .normal)
                        button.titleLabel?.font = UIFont.systemFont(ofSize: 11)
                        
                        buttons.insert(button, at: index)
                        
                        addSubview(button)
                    }
                    
                    contentSize = CGSize(width: 24 + 74 * tabs.count, height: 104)
                } else {
                    // 清空视图
                    for button in buttons {
                        button.removeFromSuperview()
                    }
                    buttons.removeAll()
                }
                
                setNeedsLayout()
            }
        }
        
        var buttons = [FunButton]()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            guard let tabs = tabs else { return }
            for (index, button) in buttons.enumerated() {
                
                if index < tabs.count {
                    button.frame = CGRect(x: 15 + (index * 86), y: 12, width: 74, height: 80)
                } else {
                    button.removeFromSuperview()
                }
            }
            
            buttons.removeAll { (button) -> Bool in
                
                if !subviews.contains(button) {
                    return true
                }
                
                return false
            }
            
        }
    }
}
