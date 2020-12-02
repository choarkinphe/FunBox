//
//  WorkItem.swift
//  Store
//
//  Created by choarkinphe on 2020/6/20.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit

extension Work {
    class CollectionView: UICollectionView {
        
        override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
            super.init(frame: frame, collectionViewLayout: layout)
            
            register(Cell.self, forCellWithReuseIdentifier: "work_item")
            register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "work_header")
            backgroundColor = .white
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func bind(viewModel: Work.ViewModel) {
            delegate = viewModel
            dataSource = viewModel
//            // 配置数据源
//            viewModel.dataSource { (dataSource, collectionView, indexPath, element) -> UICollectionViewCell in
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
//                                                              for: indexPath) as! Cell
//                
//                if let icon = element.icon {
//                    cell.imageView.image = UIImage(named: icon)
//                }
//                cell.titleLabel.text = element.name
//                return cell
//            } configureSupplementaryView: { (dataSource, collectionView, title, indexPath) -> UICollectionReusableView in
//                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! Header
//                
//                header.titleLabel.text = dataSource[indexPath.section].model
//                
//                return header
//            }
//            
//            
//            
//            viewModel.bind(collectionView: self)
//            
//            refresher.pullDown(style: .system) { (refresher) in
//                
//                viewModel.reloadData { (items) in
//                    
//                    refresher.endRefesh()
//                }
//            }
        }
        
        class Header: UICollectionReusableView {
            let titleLabel: UILabel
            
            override init(frame: CGRect) {
                titleLabel = UILabel()
                super.init(frame: frame)
                
                addSubview(titleLabel)

            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                titleLabel.frame = CGRect(x: 12, y: (bounds.height - 20.0) / 2.0, width: bounds.width - 24, height: 20.0)
            }
            
        }
        
        class Cell: UICollectionViewCell {
            
            let imageView: UIImageView
            let titleLabel: UILabel
            
            override init(frame: CGRect) {
                imageView = UIImageView()
                titleLabel = UILabel()
                super.init(frame: frame)
                
                contentView.addSubview(imageView)
//                imageView.snp.makeConstraints { (make) in
//                    make.top.equalTo(14)
//                    make.centerX.equalTo(self.contentView)
//                    make.width.height.equalTo(49)
//                }
                
                titleLabel.textAlignment = .center
                contentView.addSubview(titleLabel)
//                titleLabel.snp.makeConstraints { (make) in
//                    make.top.equalTo(imageView.snp.bottom).offset(10)
//                    make.centerX.equalTo(imageView)
//                    make.left.equalTo(12)
//                }
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                imageView.frame = CGRect(x: (bounds.width - 49.0)/2.0, y: 14.0, width: 49.0, height: 49.0)
                
                titleLabel.frame = CGRect(x: 12, y: imageView.frame.maxY+10, width: bounds.width - 24, height: 18)
            }
        }
    }
}
