//
//  UIView+ViewModel.swift
//  Store
//
//  Created by choarkinphe on 2020/9/1.
//  Copyright © 2020 Konnech. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if !COCOAPODS
import FunBox
#endif
import RxSwift
import RxCocoa
import RxDataSources
#if os(iOS)
typealias FunTableViewDataSource<Section, Element> = RxTableViewSectionedReloadDataSource<SectionModel<Section, Element>>
typealias FunCollectionViewDataSource<Section, Element> = RxCollectionViewSectionedReloadDataSource<SectionModel<Section, Element>>

fileprivate var ioQueue = DispatchQueue(label: "com.corekit.viewmodel.ioqueue")

public protocol FunIndexable {
    var indexPath: IndexPath { get }
}

extension Int: FunIndexable {
    public var indexPath: IndexPath {
        return IndexPath(item: self, section: 0)
    }
}

extension IndexPath: FunIndexable {
    public var indexPath: IndexPath {
        return self
    }
}

public protocol FunViewModelable: AnyObject {
    associatedtype Section
    associatedtype Element
    
    var disposeBag: DisposeBag { get }
    
    var sections: BehaviorSubject<[SectionModel<Section?,Element>]> { get }
    
    var container: UIView? { set get }
    
    var isEmpty: Bool { get }
    
    var holderType: UIView.Holder? { get }
    /// showHolderView
    /// - Parameter holderType: holderType
    func showHolder(_ holderType: UIView.Holder)
    /// remove holderView
    func dismissHolder()
    // bind view
    func bind(view: UIView)
    // 当前数据
    var values: [SectionModel<Section?,Element>]? { get }
    
    /// 生成一组数据
    /// - Parameters:
    ///   - model: 组数据
    ///   - items: 行数据
    /// - Returns: 返回一组
    func compose(section: Section?, items: [Element]) -> SectionModel<Section?,Element>
    
    /// 获取对应组的数据
    /// - Parameter section: 组号
    /// - Returns: 一组数据
    func items(for section: Int) -> [Element]?
    
    /// 获取对应的数据组
    /// - Parameter indexPaths: 序号数组
    /// - Parameter completion: 一组数据的回调
    func items(for indexPaths: [FunIndexable], completion: @escaping (([Element]?)->Void))
    
    /// 获取对应组别
    /// - Parameter section: 组别号
    /// - Returns: 对应组别
    func section(for section: Int) -> SectionModel<Section?,Element>?
    
    /// 获取指定的一条数据
    /// - Parameter indexPath: 位置
    /// - Returns: 数据
    func element(for index: FunIndexable) -> Element?
    
    /// 插入一条数据
    /// - Parameters:
    ///   - element: 数据内容
    ///   - indexPath: 位置
    func insert(element: Element, for index: FunIndexable)
    
    /// 插入多组别数据
    /// - Parameters:
    ///   - sections: 组别数据（SectionModel）
    ///   - section: 组号
    func insert(sections array: [SectionModel<Section?,Element>], for section: Int)
    
    /// 插入一组别数据
    /// - Parameters:
    ///   - model: 组别数据（SectionModel）
    ///   - section: 组号
    func insert(section model: SectionModel<Section?,Element>, for section: Int)
    
    /// 插入一组数据
    /// - Parameters:
    ///   - elements: 数据
    ///   - section: 组号
    func insert(elements: [Element]?, for index: FunIndexable)

    /// 删除一条数据
    /// - Parameter indexPath: 位置
    func remove(for index: FunIndexable)
    
    /// 删除一组数据
    /// - Parameter section: 组号
    func remove(for section: Int)
    
    /// 替换一条数据
    /// - Parameters:
    ///   - element: 内容
    ///   - indexPath: 位置
    func replace(element: Element, for index: FunIndexable)
    
    /// 替换一条数据的内容
    /// - Parameters:
    ///   - indexPath: 位置
    ///   - element: 内容
    func replace(for index: FunIndexable, element: @escaping ((inout Element)->Void))
    
    
    /// 替换一组数据
    /// - Parameters:
    ///   - elements: 数据
    ///   - section: 组号
    func replace(elements: [Element]?, for section: Int)
    
    /// 替换一组别数据
    /// - Parameters:
    ///   - model: 组别数据（SectionModel）
    ///   - section: 组号
    func replace(section model: SectionModel<Section?,Element>, for section: Int)
    
    /// 拼一组数据
    /// - Parameters:
    ///   - elements: 组数据
    ///   - section: 组别序号
    func append(elements: [Element]?, for section: Int)
    
    /// 拼一组别数据
    /// - Parameter model: 组别数据
    func append(section model: SectionModel<Section?,Element>)
    
    /// 替换数据的最终方法
    /// - Parameter values: 数据
    func accept(_ values: [SectionModel<Section?,Element>])
}

// MARK: - default BaseViewModelable
extension FunViewModelable {
    
    public func showHolder(_ holderType: UIView.Holder) {
        container?.holder.show(holderType)
    }
    
    public func dismissHolder() {
        container?.holder.dismiss()
    }
    
    public func bind(view: UIView) {
        container = view
    }
    
    public var values: [SectionModel<Section?,Element>]? {
        return try? sections.value()
    }
    
    public func compose(section: Section?=nil, items: [Element]) -> SectionModel<Section?,Element> {
        return SectionModel(model: section, items: items)
    }
    
    public func items(for section: Int) -> [Element]? {
        
        if let values = try? sections.value() {
            if values.count > section {
                return values[section].items
            }
        }
        return nil
    }
    
    public func items(for indexPaths: [FunIndexable], completion: @escaping (([Element]?)->Void))  {
        ioQueue.async { [weak self] in
            var items = [Element]()
            
            indexPaths.forEach { (indexPath) in
                if let item = self?.element(for: indexPath) {
                    items.append(item)
                }
            }
            
            DispatchQueue.main.async {
                if items.count > 0 {
                    completion(items)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    public func section(for section: Int) -> SectionModel<Section?,Element>? {
        if let values = try? sections.value() {
            if values.count > section {
                return values[section]
            }
        }
        return nil
    }
    
    public func element(for index: FunIndexable) -> Element? {
        
        if let items = items(for: index.indexPath.section) {
            
            if items.count > index.indexPath.row {
                
                return items[index.indexPath.row]
                
            }
            
        }
        return nil
    }
    
    public func insert(element: Element, for index: FunIndexable) {
        if var values = values,
           values.count > index.indexPath.section {
            if values[index.indexPath.section].items.count > index.indexPath.row {
                
                values[index.indexPath.section].items.insert(element, at: index.indexPath.row)
            } else {
                values[index.indexPath.section].items.append(element)
            }
            accept(values)
        }
    }
    
    public func insert(sections array: [SectionModel<Section?,Element>], for section: Int) {
        if var values = values {
            if values.count > section {
                values.insert(contentsOf: array, at: section)
            } else {
                values.append(contentsOf: array)
            }
            accept(values)
        }
    }
    
    public func insert(section model: SectionModel<Section?,Element>, for section: Int) {
        if var values = values {
            if values.count > section {
                values.insert(model, at: section)
            } else {
                values.append(model)
            }
            accept(values)
        }
    }
    
    public func insert(elements: [Element]?, for index: FunIndexable = 0) {
        if let elements = elements, var sectionModel = self.section(for: index.indexPath.section) {
            if sectionModel.items.count > index.indexPath.item {
                sectionModel.items.insert(contentsOf: elements, at: index.indexPath.item)
            } else {
                sectionModel.items.append(contentsOf: elements)
            }
            self.replace(section: sectionModel, for: index.indexPath.section)
        }
    }
    
    public func remove(for index: FunIndexable) {
        if var values = values,
           values.count > index.indexPath.section,
           values[index.indexPath.section].items.count > index.indexPath.row {
            
            values[index.indexPath.section].items.remove(at: index.indexPath.row)
            
            accept(values)
        }
    }
    
    public func remove(for section: Int) {
        if var values = values,
           values.count > section {
            
            values.remove(at: section)
            
            accept(values)
        }
    }
    
    public func replace(element: Element, for index: FunIndexable) {
        if var values = values,
           values.count > index.indexPath.section,
           values[index.indexPath.section].items.count > index.indexPath.row {
            
            values[index.indexPath.section].items[index.indexPath.row] = element
            
            accept(values)
        }
    }
    
    public func replace(for index: FunIndexable, element: @escaping ((inout Element)->Void)) {
        ioQueue.async { [weak self] in
            if var values = self?.values,
               values.count > index.indexPath.section,
               values[index.indexPath.section].items.count > index.indexPath.row {
                
                element(&values[index.indexPath.section].items[index.indexPath.row])
                
                DispatchQueue.main.async {
                    self?.accept(values)
                }
            }
        }
        
    }
    
    public func replace(elements: [Element]?, for section: Int = 0) {
        if let elements = elements, var sectionModel = self.section(for: section) {
            sectionModel.items = elements
            self.replace(section: sectionModel, for: section)
        }
    }
    
    public func replace(section model: SectionModel<Section?,Element>, for section: Int) {
        if var values = values {
            if values.count > section {
                values[section] = model
            } else {
                values.append(model)
            }
            
            accept(values)
        }
    }
    
    public func append(elements: [Element]?, for section: Int = 0) {
        if let elements = elements, var sectionModel = self.section(for: section) {
            sectionModel.items.append(contentsOf: elements)
            self.replace(section: sectionModel, for: section)
        }
    }
    
    public func append(section model: SectionModel<Section?,Element>) {
        if var values = values {
            
            values.append(model)
            
            accept(values)
        }
    }
    
    public func accept(_ values: [SectionModel<Section?,Element>]) {
        sections.onNext(values)
        if let holderType = holderType, isEmpty {
            showHolder(holderType)
        } else {
            dismissHolder()
        }
    }
}

open class FunViewModel<Section,Element>: FunViewModelable {
    fileprivate var holderBehavior = BehaviorRelay<UIView.Holder?>(value: nil)
    
    public var holderType: UIView.Holder? {
        get {
            return holderTypeBehavior.value
        }
        set {
            holderTypeBehavior.accept(newValue)
        }
    }
    
    private var holderTypeBehavior = BehaviorRelay<UIView.Holder?>(value: nil)
    
    public var disposeBag = DisposeBag()
    
    // 绑定的view
    public var container: UIView? {
        didSet {
            
        }
    }
    
    public init() {
        // holderType发生变更时查询数据情况，无数据的话就直接展示对应的占位图
        holderTypeBehavior.bind { [weak self] (holderType) in
            if let holderType = holderType {
                self?.container?.holder.set(holderType)
            } else {
                self?.dismissHolder()
            }
        }.disposed(by: disposeBag)
        
        sections.bind { (next) in
            
        }.disposed(by: disposeBag)
    }
    // 订阅数据
    public private(set) var sections = BehaviorSubject<[SectionModel<Section?,Element>]>(value: [SectionModel(model: nil, items: [Element]())])

    open var isEmpty: Bool {
        if let sections = try? sections.value(), sections.count > 0 {
            
            return false
        }
        
        return true
    }
}

// MARK: UITableViewViewModel
public typealias FunTableViewSectionViewModel = UITableView.FunViewModel.Section
public typealias FunTableViewViewModel = UITableView.FunViewModel.Single
extension UITableView {
    public class FunViewModel { }
}
extension UITableView.FunViewModel {
    
    open class Section<Section,Element>: FunViewModel<Section, Element> {
        
        public override init() {
            super.init()
        }
        
        private var source = BehaviorRelay<FunTableViewDataSource<Section?, Element>?>(value: nil)
        
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
            let dataSource = FunTableViewDataSource<Section?, Element>(configureCell: configureCell,
                                                                      titleForHeaderInSection: titleForHeaderInSection,
                                                                      titleForFooterInSection: titleForFooterInSection,
                                                                      canEditRowAtIndexPath: canEditRowAtIndexPath,
                                                                      canMoveRowAtIndexPath: canMoveRowAtIndexPath,
                                                                      sectionIndexTitles: sectionIndexTitles,
                                                                      sectionForSectionIndexTitle: sectionForSectionIndexTitle)
            
            source.accept(dataSource)
        }

        
    }
    
    
    
    open class Single<Element>: UITableView.FunViewModel.Section<String,Element> {
        
        public override init() {
            super.init()
        }
        
        public override func bind(tableView: UITableView, dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String?,Element>>?=nil, disposeBag: DisposeBag?=nil) {
            
            super.bind(tableView: tableView, dataSource: dataSource, disposeBag: disposeBag)
            
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
        
        open override var isEmpty: Bool {
            if let items = items(for: 0), items.count > 0 {
                
                return false
            }
            
            return true
        }
    }
}


// MARK: UICollectionViewViewModel
public typealias FunCollectionSectionViewModel = UICollectionView.FunViewModel.Section
public typealias FunCollectionViewModel = UICollectionView.FunViewModel.Single
extension UICollectionView {
    public class FunViewModel { }
}
extension UICollectionView.FunViewModel {
    open class Section<Section,Element>: FunViewModel<Section,Element> {
        public override init() {
            super.init()
        }
        
        private var source = BehaviorRelay<FunCollectionViewDataSource<Section?, Element>?>(value: nil)
        
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
            let dataSource = FunCollectionViewDataSource<Section?, Element>(configureCell: configureCell,
                                                                           configureSupplementaryView: configureSupplementaryView,
                                                                           moveItem: moveItem,
                                                                           canMoveItemAtIndexPath: canMoveItemAtIndexPath)
            
            source.accept(dataSource)
        }

    }
    
    open class Single<Element>: UICollectionView.FunViewModel.Section<String,Element> {
        public override init() {}
        
        public override func bind(collectionView: UICollectionView, dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String?,Element>>?=nil, disposeBag: DisposeBag?=nil) {
            
            super.bind(collectionView: collectionView, dataSource: dataSource, disposeBag: disposeBag)
            
        }
        
        public override func dataSource(configureCell: @escaping CollectionViewSectionedDataSource<SectionModel<String?,Element>>.ConfigureCell,
                                        configureSupplementaryView: CollectionViewSectionedDataSource<SectionModel<String?,Element>>.ConfigureSupplementaryView? = nil,
                                        moveItem: @escaping CollectionViewSectionedDataSource<SectionModel<String?,Element>>.MoveItem = { _, _, _ in () },
                                        canMoveItemAtIndexPath: @escaping CollectionViewSectionedDataSource<SectionModel<String?,Element>>.CanMoveItemAtIndexPath = { _, _ in false }) {
            super.dataSource(configureCell: configureCell, configureSupplementaryView: configureSupplementaryView, moveItem: moveItem, canMoveItemAtIndexPath: canMoveItemAtIndexPath)
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
#endif
