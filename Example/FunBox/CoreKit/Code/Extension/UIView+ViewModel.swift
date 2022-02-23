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

protocol PageSourceable: FunViewModelable where Element: HandyJSON {
    
    //    var pageSource: BehaviorSubject<Service.PageElement<Element>> { get set }
    
    /// 添加一条分页数据
    /// - Parameters:
    ///   - pageSource: 页面数据
    ///   - section: 分组
    ///   - offset: 偏移量（可能手动增加、删除过接口返回的数据，加上偏移量修正接口的请求参数）
    func feed(pageSource: Service.PageElement<Element>, section: Int, offset: Int)
}

extension PageSourceable {
    
    public func feed(pageSource: Service.PageElement<Element>, section: Int = 0, offset: Int = 0) {
        
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

// MARK: UIScrollViewViewModel
extension UIScrollView {
    open class SectionViewModel<Section,Element>: FunViewModel<Section,Element>, PageSourceable where Element: HandyJSON {
        
    }
    
}

// MARK: UITableViewViewModel
extension UITableView {
    
    open class SectionViewModel<Section,Element>: FunTableViewSectionViewModel<Section, Element>, PageSourceable where Element: HandyJSON {
        
    }
    
    
    
    open class ViewModel<Element>: FunTableViewViewModel<Element>, PageSourceable where Element: HandyJSON {
        
    }
}


// MARK: UICollectionViewViewModel
extension UICollectionView {
    open class SectionViewModel<Section,Element>: FunCollectionSectionViewModel<Section,Element>, PageSourceable where Element: HandyJSON {
        
    }
    
    open class ViewModel<Element>: FunCollectionViewModel<Element>, PageSourceable where Element: HandyJSON {
        
    }
}

// MARK: - 绑定分页请求
/*
 extension ObservableType where Element == Response {
 
 public func sendPage<T>(to viewModel: UIScrollView.SectionViewModel<String, T>, complete: ((Service.Result<Service.PageElement<T>>)->Void)?=nil) where T: HandyJSON {
 
 mapResult(Service.PageElement<T>.self).response { (result) in
 if let page = result.object {
 viewModel.feed(pageSource: page)
 }
 complete?(result)
 }.disposed(by: viewModel.disposeBag)
 }
 
 public func sendElements<T>(to viewModel: UIScrollView.SectionViewModel<String, T>, complete: ((Service.Result<T>)->Void)?=nil) where T: HandyJSON {
 
 mapResult(T.self).response { (result) in
 viewModel.replace(elements: result.array)
 
 complete?(result)
 
 }.disposed(by: viewModel.disposeBag)
 }
 
 }
 */

public struct SourceConfig<Section,Element> {
    var configureCell: TableViewSectionedDataSource<SectionModel<Section?, Element>>.ConfigureCell?
    var titleForHeaderInSection: TableViewSectionedDataSource<SectionModel<Section?, Element>>.TitleForHeaderInSection? // = { _, _ in nil }
    var titleForFooterInSection: TableViewSectionedDataSource<SectionModel<Section?, Element>>.TitleForFooterInSection?// = { _, _ in nil },
    var canEditRowAtIndexPath: TableViewSectionedDataSource<SectionModel<Section?, Element>>.CanEditRowAtIndexPath?// = { _, _ in false },
    var canMoveRowAtIndexPath: TableViewSectionedDataSource<SectionModel<Section?, Element>>.CanMoveRowAtIndexPath?// = { _, _ in false },
    var sectionIndexTitles: TableViewSectionedDataSource<SectionModel<Section?, Element>>.SectionIndexTitles?// = { _ in nil },
    var sectionForSectionIndexTitle: TableViewSectionedDataSource<SectionModel<Section?, Element>>.SectionForSectionIndexTitle?// = { _, _, index in index }
    
    public mutating func configureCell(_ configureCell: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.ConfigureCell) -> SourceConfig {
        self.configureCell = configureCell
        return self
    }
    public mutating func titleForHeaderInSection(_ titleForHeaderInSection: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.TitleForHeaderInSection) -> SourceConfig {
        self.titleForHeaderInSection = titleForHeaderInSection
        return self
    }
    public mutating func titleForFooterInSection(_ titleForFooterInSection: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.TitleForFooterInSection) -> SourceConfig {
        self.titleForFooterInSection = titleForFooterInSection
        return self
    }
    public mutating func canEditRowAtIndexPath(_ canEditRowAtIndexPath: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.CanEditRowAtIndexPath) -> SourceConfig {
        self.canEditRowAtIndexPath = canEditRowAtIndexPath
        return self
    }
    public mutating func canMoveRowAtIndexPath(_ canMoveRowAtIndexPath: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.CanMoveRowAtIndexPath) -> SourceConfig {
        self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
        return self
    }
    public mutating func sectionIndexTitles(_ sectionIndexTitles: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.SectionIndexTitles) -> SourceConfig {
        self.sectionIndexTitles = sectionIndexTitles
        return self
    }
    public mutating func sectionForSectionIndexTitle(_ sectionForSectionIndexTitle: @escaping TableViewSectionedDataSource<SectionModel<Section?, Element>>.SectionForSectionIndexTitle) -> SourceConfig {
        self.sectionForSectionIndexTitle = sectionForSectionIndexTitle
        return self
    }
    
}

