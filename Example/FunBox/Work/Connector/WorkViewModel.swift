//
//  WorkViewModel.swift
//  Store
//
//  Created by choarkinphe on 2020/6/20.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit
import FunModules

struct AAA<T> {
    var a: T?
}

extension Work {
    class ViewModel: NSObject {
        var collectionView: UICollectionView?
        var sections = [Work.Element]()
        let timer = DispatchSource.makeTimerSource()
        
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

                switch element.name {
//                case "百度":
                    
                    
                    case "Toast":
//                        break
//                        var progress: CGFloat = 0.01
//                        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .microseconds(10))
//
//                        timer.setEventHandler {
//                            progress = progress + 0.01
//                        FunBox.toast.style(.system).duration(2.5).mode(.progress(0.5)).tapToDismiss(false).title("提示").message("静音模式开启").haptic(true).show()
//                            FunHUD.toast(.success, message: "dgdgdg")
//                        FunHUD(.loading).style(.system).message("ddd").show()
//
//                        }
//
//                        timer.resume()
                        
                        FunBox.toast.title("提示").haptic(true).show()
                        FunBox.toast.title("提示").haptic(true).show()
                        FunBox.toast.title("提示").haptic(true).show()
                        FunBox.toast.title("提示").haptic(true).message("哈哈").show()
                        FunBox.toast.title("提示").haptic(true).message("哈哈").show()
                        FunBox.toast.title("提示").haptic(true).message("呵呵").show()
                        FunBox.toast.title("提示").haptic(true).show()
                        FunBox.toast.title("提示").haptic(true).message("嘻嘻").show()
                        FunBox.toast.title("提示").haptic(true).show()
                        FunHUD.toast(.loading, message: "等等等等")
                        
                    case "扫码":
//                        break
                        var style = FunScan.Style()
                        style.boardColor = .blue
                        FunScan.default.feed(style: style).response { (navigation) in
                            print(navigation.content)
//                            self.navigationController?.pushViewController(WebViewController(), animated: true)
//                            navigation.dismiss(true)
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                                navigation.dismiss(false)
                            }
                        }
                    case "Call":
//                        break
//                        FunCall.call(nil)
//                        FunHUD.toast(.success, message: "等等等等")
                        FunBox.datePicker.set(date: "2021/1/24").present()
                default:
                    break
                    FunHUD.dismissActivity()
                    Router.default.open(url: element.linkUrl, params: nil, animated: true, handler: { (action) in
                        print(action.identifier)
                    })
                }
        }
    }
}


