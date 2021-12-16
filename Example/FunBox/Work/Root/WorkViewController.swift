//
//  WorkViewController.swift
//  Store
//
//  Created by choarkinphe on 2020/6/9.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit
import CoreKit
//extension Work {
    class NavigationController: UINavigationController {
        override func viewDidLoad() {
            super.viewDidLoad()

//            FunBox.alert.title("dd").message("aaa").addAction(title: "取消", style: .cancel).addAction(title: "确定", style: .default, color: .red, handler: { (action) in
//                
//            }).present()
        
        }
    }
    class WorkViewController: UIViewController {
        
        var viewModel = Work.ViewModel()
        /*
        func initNavigationBar(navigationBar: FunNavigationBar) {
//            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
//            button.setTitle("POP ", for: .normal)
//            button.setTitleColor(.darkText, for: .normal)
//            button.addTarget(self, action: #selector(popMenu(sender:)), for: .touchUpInside)
//            navigationBar.rightView = button
//            fb.bottomView = button
            fb.contentInsets = UIEdgeInsets(top: navigationBar.frame.maxY, left: 0, bottom: 0, right: 0)
            
            navigationBar.clipBar.moreAction { (sender) in
                self.popMenu(sender: sender)
            }
        }
        */
        @objc func popMenu(sender: UIButton) {
/*
            let manager = FunPopMenuManager.default
            // Set actions
//            manager.actions =

//            manager.addActions(["标题1","标题2","标题3"])
            manager.appearance.font = UIFont(name: "AvenirNext-DemiBold", size: 16)!
            manager.appearance.backgroundStyle = .dimmed(color: .clear, opacity: 0.2)
            manager.appearance.contentOffset = CGPoint(x: 10, y: 52)
            manager.appearance.showAriangle = true
            manager.appearance.ariangleSize = CGSize(width: 12, height: 12)
            manager.appearance.cornerRadius = 12
            manager.appearance.colorStyle = .configure(background: .solid(fill: .darkGray), action: .tint(.white))
            manager.appearance.showCutLine = true
            manager.dismissOnSelection = false
            manager.addActions([
                                FunPopMenu(title: "Click me to"),
                                FunPopMenu(title: "Pop another menu"),
                                FunPopMenu(title: "Try it out!")
                                ])
//                        manager.popMenuDelegate = self
            manager.select { (action) in
                print(action.title)
                
//                self.present(WorkViewController(), animated: true, completion: nil)
            }
            // Present menu
            manager.present(sourceView: sender)


            */
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .purple
            Service.router.feedPages(JSON: JSONSerialization.fb.json(filePath: Bundle.main.path(forResource: "RouteTable", ofType: "JSON"), type: [String: String].self))
//            Router.default.scheme = "funbox"
//            Router.default.feedPages(JSON: JSONSerialization.fb.json(filePath: Bundle.main.path(forResource: "RouteTable", ofType: "JSON"), type: [String: String].self))
            
//            title = "工作台"
//            navigationController?.navigationBar.prefersLargeTitles = true
//
//            navigationItem.largeTitleDisplayMode = .always
//
//            let searchVC = UISearchController(searchResultsController: SerachResultController())
//            searchVC.searchBar.placeholder = "请输入项目名称"
//            searchVC.searchResultsUpdater = self
//            searchVC.delegate = self
//            navigationItem.searchController = searchVC
//            navigationItem.hidesSearchBarWhenScrolling = true
            
            fb.contentView = collectionView
            
            collectionView.rx.itemSelected
//            collectionView.rx.modelSelected(Work.Tab.self).subscribe(onNext: { (element) in
//                guard !(element.linkUrl?.isEmpty ?? true) else {
//                    CKHUD.toast(.error, message: Work.Tips.working)
//                    return
//                }
//                CoreKit.router.open(url: element.linkUrl, params: nil, animated: true, handler: { (action) in
//                    print(action.identifier)
//                    switch action.identifier {
////                    case "popMenu":
//
//                    default:
//                        break
//                    }
//                })
//
//            }).disposed(by: viewModel.disposeBag)
//            let navigationBar = FunNavigationBar(template: .container)
//            fb.navigationBar = navigationBar
//
//            initNavigationBar(navigationBar: navigationBar)

        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            navigationController?.setNavigationBarHidden(true, animated: false)
            
//            collectionView.refresher.beginRefresh()
            viewModel.reloadData()
            
            
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            navigationController?.setNavigationBarHidden(false, animated: false)
            tabBarController?.hidesBottomBarWhenPushed = true
        }
        
        @objc private func showMessage(sender: UIBarButtonItem) {
//            CKHUD.toast(.info, message: Work.Tips.working)
        }
        
        lazy var header: Work.Header = {
            let header = Work.Header(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 104))
//            header.tabs = [Work.Tab(icon: nil, name: "证书生成"),Work.Tab(icon: nil, name: "团队建设"),Work.Tab(icon: nil, name: "产品知识库")]
            header.bind(viewModel: viewModel)
            return header
        }()
        
        lazy var layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            let width = (UIScreen.main.bounds.width - 30) / 3.0
            layout.itemSize = CGSize(width: width, height: width)
            layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 49)
            return layout
        }()
        
        lazy var collectionView: Work.CollectionView = {
            let collectionView = Work.CollectionView(frame: view.bounds, collectionViewLayout: layout)
            
//            collectionView.tableHeaderView = self.header
            collectionView.bind(viewModel: viewModel)
            return collectionView
        }()
    }
//}

extension WorkViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

class SerachResultController: UIViewController {
//    override func viewDidLoad() {
//
//        UIImageView().webImage.imageUrl(URL(string: "xxxx")).imageUrl("https://sss").show()
//        UIImageView().theme.set(backgroundColor: [UIColor.red.theme(.dark),UIColor.white.theme(.default)])
//
//        UILabel().theme.set(font: [UIFont.systemFont(ofSize: 12).theme(.dark)])
//
//        let label = UILabel([Theme.Color.darkText,Theme.Font.default])
//    }
}
