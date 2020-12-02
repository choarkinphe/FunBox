//
//  WorkViewController.swift
//  Store
//
//  Created by choarkinphe on 2020/6/9.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit
//extension Work {
    class NavigationController: UINavigationController {
        override func viewDidLoad() {
            super.viewDidLoad()


        }
    }
    class WorkViewController: UIViewController {
        
        var viewModel = Work.ViewModel()
        
        func initNavigationBar(navigationBar: FunNavigationBar) {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            button.setTitle("POP ", for: .normal)
            button.setTitleColor(.darkText, for: .normal)
            button.addTarget(self, action: #selector(popMenu(sender:)), for: .touchUpInside)
            navigationBar.rightView = button
        }
        
        @objc func popMenu(sender: UIButton) {
            let manager = FunPopMenuManager.default
            // Set actions
//            manager.actions =
            manager.addActions([
                                FunPopMenu(title: "Click me to"),
                                FunPopMenu(title: "Pop another menu"),
                                FunPopMenu(title: "Try it out!")
                                ])
            manager.addActions(["标题1","标题2","标题3"])
//            manager.addAction(FunPopMenu(title: "Pop another menu"))
//            manager.addAction(FunPopMenu(title: "Try it out!"))
            // Customize appearance
            manager.appearance.font = UIFont(name: "AvenirNext-DemiBold", size: 16)!
            manager.appearance.backgroundStyle = .dimmed(color: .clear, opacity: 0.2)
            manager.appearance.contentOffset = CGPoint(x: 0, y: 32)
            manager.appearance.colorStyle = .configure(background: .solid(fill: .darkGray), action: .tint(.white))
            manager.dismissOnSelection = false
//                        manager.popMenuDelegate = self
            manager.select { (action) in
                print(action.title)
            }
            // Present menu
            manager.present(sourceView: sender)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
//            HZCoreKit.router.feedPages(JSON: JSONSerialization.fb.json(filePath: Bundle.main.path(forResource: "RouteTable", ofType: "JSON"), type: [String: String].self))
            Router.default.scheme = "funbox"
            Router.default.feedPages(JSON: JSONSerialization.fb.json(filePath: Bundle.main.path(forResource: "RouteTable", ofType: "JSON"), type: [String: String].self))
            
            title = "工作台"
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
//            collectionView.rx.modelSelected(Work.Tab.self).subscribe(onNext: { (element) in
//                guard !(element.linkUrl?.isEmpty ?? true) else {
//                    HZHUD.toast(.error, message: Work.Tips.working)
//                    return
//                }
//                HZCoreKit.router.open(url: element.linkUrl, params: nil, animated: true, handler: { (action) in
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
            let navigationBar = FunNavigationBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: UIDevice.current.fb.isInfinity ? 88 : 64))
            fb.navigationBar = navigationBar
            
            initNavigationBar(navigationBar: navigationBar)

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
        }
        
        @objc private func showMessage(sender: UIBarButtonItem) {
//            HZHUD.toast(.info, message: Work.Tips.working)
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
