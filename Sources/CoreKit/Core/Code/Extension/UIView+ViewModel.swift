//
//  UIView+ViewModel.swift
//  Store
//
//  Created by choarkinphe on 2020/9/1.
//  Copyright © 2020 Konnech. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HandyJSON
import FunBox
import RxDataSources
import FunModules

typealias HZTableViewDataSource<Section, Element> = RxTableViewSectionedReloadDataSource<SectionModel<Section, Element>>
typealias HZCollectionViewDataSource<Section, Element> = RxCollectionViewSectionedReloadDataSource<SectionModel<Section, Element>>

public protocol ViewModelable: AnyObject {
    var disposeBag: DisposeBag { get }
}

open class BaseViewModel<Section,Element>: FunViewModel<Section, Element> where Element: HandyJSON {

    // 订阅数据（不建议使用）
    @available(*, deprecated, message: "use sections instand of it")
    public private(set) var dataList = BehaviorSubject<[SectionModel<String?,Element>]>(value: [SectionModel(model: "", items: [Element]())])

}


// MARK: UIScrollViewViewModel
extension UIScrollView {
    open class SectionViewModel<Section,Element>: BaseViewModel<Section,Element> where Element: HandyJSON {
        // 分页
        open var pageSource = BehaviorSubject(value: CKPageElement<Element>())
        
        public override init() {
            super.init()
            
            pageSource.bind { [weak self] (next) in
                
                self?.feed(pageSource: next)
            }.disposed(by: disposeBag)
            
        }
        
        /// 添加一条分页数据
        /// - Parameters:
        ///   - pageSource: 页面数据
        ///   - section: 分组
        ///   - offset: 偏移量（可能手动增加、删除过接口返回的数据，加上偏移量修正接口的请求参数）
        public func feed(pageSource: CKPageElement<Element>, section: Int = 0, offset: Int = 0) {
            
            guard var values = try? sections.value(),
                  values.count > section,
                  let scrollView = container as? UIScrollView else { return  }
            
            //模型数据添加新数据
            if let elements = pageSource.rows {
                if scrollView.refresher.page.offset == 0 {
                    values[section].items = elements
                } else {
                    values[section].items.append(contentsOf: elements)
                }
                
                scrollView.refresher.page.offset = scrollView.refresher.page.offset + elements.count - offset
                scrollView.refresher.page.total = pageSource.total
                scrollView.refresher.page.index = pageSource.currentPage + 1
            }
            
            accept(values)
            
            scrollView.refresher.endRefesh()
            
        }
        
    }
    
}

// MARK: UITableViewViewModel
extension UITableView {
    
    open class SectionViewModel<Section,Element>: UIScrollView.SectionViewModel<Section, Element> where Element: HandyJSON {
        
        public override init() {
            super.init()
        }
        
        private var source = BehaviorRelay<HZTableViewDataSource<Section?, Element>?>(value: nil)
        
        public func bind(tableView: UITableView, dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Section?,Element>>?=nil, disposeBag: DisposeBag?=nil) {
            
            bind(view: tableView)
            
            if let dataSource = dataSource {
                source.accept(dataSource)
            }
            
            source.bind { [weak self] (dataSource) in
                if let dataSource = dataSource, let this = self {
                    
                    this.sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag ?? this.disposeBag)
                }
            }.disposed(by: disposeBag ?? self.disposeBag)
            
        }
        
        public func dataSource(configureCell: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.ConfigureCell,
                               titleForHeaderInSection: @escaping  TableViewSectionedDataSource<SectionModel<Section?, Element>>.TitleForHeaderInSection = { _, _ in nil },
                               titleForFooterInSection: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.TitleForFooterInSection = { _, _ in nil },
                               canEditRowAtIndexPath: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.CanEditRowAtIndexPath = { _, _ in false },
                               canMoveRowAtIndexPath: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.CanMoveRowAtIndexPath = { _, _ in false },
                               sectionIndexTitles: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.SectionIndexTitles = { _ in nil },
                               sectionForSectionIndexTitle: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.SectionForSectionIndexTitle = { _, _, index in index }) {
            let dataSource = HZTableViewDataSource<Section?, Element>(configureCell: configureCell,
                                                                      titleForHeaderInSection: titleForHeaderInSection,
                                                                      titleForFooterInSection: titleForFooterInSection,
                                                                      canEditRowAtIndexPath: canEditRowAtIndexPath,
                                                                      canMoveRowAtIndexPath: canMoveRowAtIndexPath,
                                                                      sectionIndexTitles: sectionIndexTitles,
                                                                      sectionForSectionIndexTitle: sectionForSectionIndexTitle)
            
            source.accept(dataSource)
        }
        
        public override func feed(pageSource: CKPageElement<Element>, section: Int = 0, offset: Int = 0) {
            super.feed(pageSource: pageSource, section: section, offset: offset)
        }
        
    }
    
    
    
    open class ViewModel<Element>: SectionViewModel<String,Element> where Element: HandyJSON {
        
        public override init() {
            super.init()
        }
        
        public override func bind(tableView: UITableView, dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String?,Element>>?=nil, disposeBag: DisposeBag?=nil) {
            
            super.bind(tableView: tableView, dataSource: dataSource, disposeBag: disposeBag)
            
            dataList.bind { [weak self] (elements) in
                //                self?.sections.onNext(elements)
                self?.accept(elements)
            }.disposed(by: disposeBag ?? self.disposeBag)
            
        }
        
        public override func dataSource(configureCell: @escaping TableViewSectionedDataSource<SectionModel<String?, Element>>.ConfigureCell,
                                        titleForHeaderInSection: @escaping  TableViewSectionedDataSource<SectionModel<String?, Element>>.TitleForHeaderInSection = { _, _ in nil },
                                        titleForFooterInSection: @escaping TableViewSectionedDataSource<SectionModel<String?, Element>>.TitleForFooterInSection = { _, _ in nil },
                                        canEditRowAtIndexPath: @escaping TableViewSectionedDataSource<SectionModel<String?, Element>>.CanEditRowAtIndexPath = { _, _ in false },
                                        canMoveRowAtIndexPath: @escaping TableViewSectionedDataSource<SectionModel<String?, Element>>.CanMoveRowAtIndexPath = { _, _ in false },
                                        sectionIndexTitles: @escaping TableViewSectionedDataSource<SectionModel<String?, Element>>.SectionIndexTitles = { _ in nil },
                                        sectionForSectionIndexTitle: @escaping TableViewSectionedDataSource<SectionModel<String?, Element>>.SectionForSectionIndexTitle = { _, _, index in index }) {
            super.dataSource(configureCell: configureCell, titleForHeaderInSection: titleForHeaderInSection, titleForFooterInSection: titleForFooterInSection, canEditRowAtIndexPath: canEditRowAtIndexPath, canMoveRowAtIndexPath: canMoveRowAtIndexPath, sectionIndexTitles: sectionIndexTitles, sectionForSectionIndexTitle: sectionForSectionIndexTitle)
        }
        
        public override func feed(pageSource: CKPageElement<Element>, section: Int = 0, offset: Int = 0) {
            super.feed(pageSource: pageSource, section: section, offset: offset)
        }
        
        open override var isEmpty: Bool {
            if let items = items(for: 0), items.count > 0 {
                
                return false
            }
            
            return true
        }
    }
}


// MARK: UICollectionViewViewModel
extension UICollectionView {
    open class SectionViewModel<Section,Element>: UIScrollView.SectionViewModel<Section,Element> where Element: HandyJSON {
        public override init() {
            super.init()
        }
        
        private var source = BehaviorRelay<HZCollectionViewDataSource<Section?, Element>?>(value: nil)
        
        public func bind(collectionView: UICollectionView, dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Section?,Element>>?=nil, disposeBag: DisposeBag?=nil) {

            bind(view: collectionView)
            
            if let dataSource = dataSource {
                source.accept(dataSource)
            }
            
            source.bind { [weak self] (dataSource) in
                if let dataSource = dataSource, let this = self {
                    
                    this.sections.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag ?? this.disposeBag)
                }
            }.disposed(by: disposeBag ?? self.disposeBag)
            
        }
        
        public func dataSource(configureCell: @escaping CollectionViewSectionedDataSource<SectionModel<Section?,Element>>.ConfigureCell,
                               configureSupplementaryView: CollectionViewSectionedDataSource<SectionModel<Section?,Element>>.ConfigureSupplementaryView? = nil,
                               moveItem: @escaping CollectionViewSectionedDataSource<SectionModel<Section?,Element>>.MoveItem = { _, _, _ in () },
                               canMoveItemAtIndexPath: @escaping CollectionViewSectionedDataSource<SectionModel<Section?,Element>>.CanMoveItemAtIndexPath = { _, _ in false }) {
            let dataSource = HZCollectionViewDataSource<Section?, Element>(configureCell: configureCell,
                                                                           configureSupplementaryView: configureSupplementaryView,
                                                                           moveItem: moveItem,
                                                                           canMoveItemAtIndexPath: canMoveItemAtIndexPath)
            
            source.accept(dataSource)
        }
        
        public override func feed(pageSource: CKPageElement<Element>, section: Int = 0, offset: Int = 0) {
            super.feed(pageSource: pageSource, section: section, offset: offset)
        }
        
    }
    
    open class ViewModel<Element>: SectionViewModel<String,Element> where Element: HandyJSON {
        public override init() {}
        
        public override func bind(collectionView: UICollectionView, dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String?,Element>>?=nil, disposeBag: DisposeBag?=nil) {
            
            super.bind(collectionView: collectionView, dataSource: dataSource, disposeBag: disposeBag)
            
            dataList.bind { [weak self] (elements) in
                //                self?.sections.onNext(elements)
                self?.accept(elements)
            }.disposed(by: disposeBag ?? self.disposeBag)
            
        }
        
        public override func dataSource(configureCell: @escaping CollectionViewSectionedDataSource<SectionModel<String?,Element>>.ConfigureCell,
                                        configureSupplementaryView: CollectionViewSectionedDataSource<SectionModel<String?,Element>>.ConfigureSupplementaryView? = nil,
                                        moveItem: @escaping CollectionViewSectionedDataSource<SectionModel<String?,Element>>.MoveItem = { _, _, _ in () },
                                        canMoveItemAtIndexPath: @escaping CollectionViewSectionedDataSource<SectionModel<String?,Element>>.CanMoveItemAtIndexPath = { _, _ in false }) {
            super.dataSource(configureCell: configureCell, configureSupplementaryView: configureSupplementaryView, moveItem: moveItem, canMoveItemAtIndexPath: canMoveItemAtIndexPath)
        }
        
        public override func feed(pageSource: CKPageElement<Element>, section: Int = 0, offset: Int = 0) {
            super.feed(pageSource: pageSource, section: section, offset: offset)
        }
        
        // 是否为空
        open override var isEmpty: Bool {
            if let items = items(for: 0), items.count > 0 {
                
                return false
            }
            
            return true
        }
    }
}

// MARK: - 绑定分页请求
extension ObservableType where Element == Response {
    
    public func sendPage<T>(to viewModel: UIScrollView.SectionViewModel<String, T>, complete: ((CKResult<CKPageElement<T>>)->Void)?=nil) where T: HandyJSON {
        
        mapResult(CKPageElement<T>.self).response { (result) in
            if let page = result.object {
                viewModel.feed(pageSource: page)
            }
            complete?(result)
        }.disposed(by: viewModel.disposeBag)
    }
    
    public func sendElements<T>(to viewModel: UIScrollView.SectionViewModel<String, T>, complete: ((CKResult<T>)->Void)?=nil) where T: HandyJSON {
        
        mapResult(T.self).response { (result) in
            viewModel.replace(elements: result.array)
            
            complete?(result)
            
        }.disposed(by: viewModel.disposeBag)
    }
    
}
