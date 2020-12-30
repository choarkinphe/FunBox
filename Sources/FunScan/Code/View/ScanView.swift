//
//  ScanView.swift
//  hangzhou-pd
//
//  Created by jiang junhui on 2020/10/16.
//  Copyright © 2020 Konnech. All rights reserved.
//

import Foundation

extension FunScan {
    
    class MaskView: UIView {
        let infoLabel: UILabel
        let containerView: UIView
        let line: UIImageView
        
        override init(frame: CGRect) {
            infoLabel = UILabel()
            infoLabel.textColor = .lightGray
            infoLabel.font = UIFont.systemFont(ofSize: 15)
            line = UIImageView(image: UIImage(named: "ic_scan_line", in: FunScan.bundle, compatibleWith: nil))
            
            containerView = UIView()
            super.init(frame: frame)
            
            addSubview(containerView)
//            containerView.snp.makeConstraints { (make) in
//                make.left.equalTo(15)
//                make.right.equalTo(-15)
//                make.center.equalTo(self)
//                make.height.equalTo(containerView.snp.width)
//            }
            
            infoLabel.textAlignment = .center
            addSubview(infoLabel)
//            infoLabel.snp.makeConstraints { (make) in
//                make.left.equalTo(15)
//                make.right.equalTo(-15)
//                make.bottom.equalTo(-100)
//            }
            
            line.alpha = 0
            addSubview(line)
//            line.snp.makeConstraints { (make) in
//                make.left.right.equalTo(infoLabel)
//                make.top.equalTo(containerView)
//                make.height.equalTo(60)
//            }
            
            backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        

        override func layoutSubviews() {
            super.layoutSubviews()
            let containerWidth = bounds.size.width - 30
            containerView.frame = CGRect(x: 15, y: (bounds.height - containerWidth) / 2.0, width: containerWidth, height: containerWidth)
            infoLabel.frame = CGRect(x: 15, y: bounds.height - 122, width: bounds.width - 30, height: 22)
            line.frame = CGRect(x: infoLabel.frame.minX, y: containerView.frame.minY, width: containerWidth, height: 60)
        }
        
        private var enabled = false
        func animation(_ isEnable: Bool) {
            line.isHidden = !isEnable
            if enabled {
                return
            }
            enabled = isEnable // 保证动画开启的代码只会执行一次，不然会开启多个动画
            let distance = containerView.frame.maxY - line.frame.height
            
            UIView.animateKeyframes(withDuration: 2, delay: 0, options: .repeat) {
                self.line.frame.origin.y = distance
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 4/5) {
                    self.line.alpha = 1
                }
                UIView.addKeyframe(withRelativeStartTime: 4/5, relativeDuration: 1/5) {
                    self.line.alpha = 0
                }
            } completion: { (flag) in
                
            }

        }
        
    }
    
}
