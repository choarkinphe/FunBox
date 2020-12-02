//
//  WorkViewModel.swift
//  Store
//
//  Created by choarkinphe on 2020/6/20.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit

extension Work {
    class ViewModel: NSObject {
        var collectionView: UICollectionView?
        var sections = [Work.Element]()
        
//
//        private var tabsHandler: (([Work.Tab])->Void)?
//        func tabs(_ handler: (([Work.Tab])->Void)?) {
//            tabsHandler = handler
//        }
//
        func reloadData(_ complete: (([Work.Element])->Void)? = nil) {
            if let source = JSONSerialization.fb.decode(fileName: "WorkItems.JSON", type:[Work.Element].self) {
//                if let source = try? JSONDecoder().decode([Work.Element].self, from: json) {


                    sections = source
                    
                    collectionView?.reloadData()
//                    for (index,item) in source.enumerated() {
//                        if let title = item.title, let items = item.items {
//
//                            replace(section: compose(section: title, items: items), for: index)
//                        }
//                    }

//                }

            }
        }

    }
}

extension Work.ViewModel: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.collectionView = collectionView
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "work_item", for: indexPath) as! Work.CollectionView.Cell
        if let element = sections[indexPath.section].items?[indexPath.item] {
            
            if let icon = element.icon {
                cell.imageView.image = UIImage(named: icon)
            }
            cell.titleLabel.text = element.name
        }
        return cell
    }
    
//    SupplementaryView
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "work_header", for: indexPath) as! Work.CollectionView.Header
        let element = sections[indexPath.section]
        header.titleLabel.text = element.title
    
        return header
    }
 
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let element = sections[indexPath.section].items?[indexPath.item] {
            Router.default.open(url: element.linkUrl, params: nil, animated: true, handler: { (action) in
                print(action.identifier)
                switch action.identifier {
                //                    case "popMenu":
                
                default:
                    break
                }
            })
        }
    }
}


