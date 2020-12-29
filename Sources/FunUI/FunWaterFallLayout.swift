//
//  WaterFallLayout.swift
//  FunBox
//
//  Created by choarkinphe on 2020/9/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

//import FunBox
import UIKit

public typealias FunWaterFallLayout = UICollectionView.WaterFallLayout
extension UICollectionView {
    public class WaterFallLayout: UICollectionViewLayout {
        public enum Style {
            case vertical
            case horizontal
        }
        
        private var itemSize: ((IndexPath) -> CGSize) = { _ in
            return .zero
        }
        public func itemSize(_ handler: @escaping ((IndexPath) -> CGSize)) {
            itemSize = handler
        }
        
        /// 通过 section 获取 header 高度
        public var headerHeight: (_ section: Int) -> CGFloat = { _ in
            return 0
        }
        
        /// 通过 section 获取 footer 高度
        public var footerHeight: (_ section: Int) -> CGFloat = { _ in
            return 0
        }
        
        /// 水流高度 垂直瀑布是列高度 水平瀑布是行高度
        private var flowHeights = [CGFloat]()
        /// 水流宽度
        private(set) var flowWidth: CGFloat = 0.0
        /// 瀑布宽度
        private var waterfallWidth: CGFloat = 0.0
        /// 缓存布局属性数组
        private var attributesArray = [UICollectionViewLayoutAttributes]()
        /// 瀑布样式
        public var style: Style = .vertical
        /// 行间距
        public var rowMargin: CGFloat = 10
        /// 列间距
        public var columnMargin: CGFloat = 10
        /// 列数
        public var flowCount: Int = 2 {
            didSet {
                prepareValueForCompute()
            }
        }
        /// 四边距
        public var edgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        /// 准备布局
        public override func prepare() {
            super.prepare()
            guard let collectionView = collectionView else {
                return
            }
            // 清除缓存
            flowHeights = Array(repeating: edgeInsets.top, count: flowCount)
            attributesArray.removeAll()
            // 根据风格处缓存用于计算的定值
            prepareValueForCompute()
            
            // 创建新的布局属性
            for section in 0..<collectionView.numberOfSections {
                // 创建头视图属性
                if let attributes = layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    at: IndexPath(item: 0, section: section)) {
                    attributesArray.append(attributes)
                }
                
                // 创建新的 item 视图属性
                for item in 0 ..< collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    if let attributes = layoutAttributesForItem(at: indexPath) {
                        attributesArray.append(attributes)
                    }
                }
                
                // 创建脚视图属性
                if let attributes = layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    at: IndexPath(item: 0, section: section)) {
                    attributesArray.append(attributes)
                }
            }
        }
        
        /// 返回布局属性数组
        public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            return attributesArray
        }
        
        /// 返回头尾布局属性
        public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            switch style {
                case .vertical:
                    attributes.frame = verticalSupplementaryViewFrame(ofKind: elementKind, at: indexPath)
                case .horizontal:
                    attributes.frame = horizontalSupplementaryViewFrame(ofKind: elementKind, at: indexPath)
            }
            return attributes
        }
        
        /// 返回每个 indexPath 对应的 cell 的布局属性
        public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = itemFrame(with: indexPath)
            return attributes
        }
        
        /// contentSize
        public override var collectionViewContentSize: CGSize {
            switch style {
                case .vertical:
                    guard var maxColumnHeight = flowHeights.first else {
                        return .zero
                    }
                    flowHeights.forEach {
                        if maxColumnHeight < $0 {
                            maxColumnHeight = $0
                        }
                    }
                    return CGSize(width: 0, height: maxColumnHeight + edgeInsets.bottom)
                case .horizontal:
                    guard var maxRowWidth = flowHeights.first else {
                        return .zero
                    }
                    flowHeights.forEach {
                        if maxRowWidth < $0 {
                            maxRowWidth = $0
                        }
                    }
                    return CGSize(width: maxRowWidth + edgeInsets.right, height: 0)
            }
        }
    }
}

// MARK: - Helper
private extension FunWaterFallLayout {
    /// 计算需要缓存的定值
    func prepareValueForCompute() {
        guard let collectionView = collectionView else {
            return
        }
        switch style {
            case .vertical:
                waterfallWidth = collectionView.frame.width - edgeInsets.left - edgeInsets.right
                flowWidth = (waterfallWidth - (CGFloat(flowCount) - 1) * columnMargin) / CGFloat(flowCount)
            case .horizontal:
                waterfallWidth = collectionView.frame.height - edgeInsets.top - edgeInsets.bottom
                flowWidth = (waterfallWidth - (CGFloat(flowCount) - 1) * rowMargin) / CGFloat(flowCount)
        }
    }
    
    /// 计算 Item 的 Frame
    func itemFrame(with indexPath: IndexPath) -> CGRect {
        switch style {
            case .vertical:
                return verticalItemFrame(with: indexPath)
            case .horizontal:
                return horizontalItemFrame(with: indexPath)
        }
    }
    
    /// 计算垂直瀑布的Frame
    func verticalItemFrame(with indexPath: IndexPath) -> CGRect {
        // 布局的宽度和高度
        //        let width = flowWidth
        let size = itemSize(indexPath)
        let aspectRatio = size.height / size.width
        let height = flowWidth * aspectRatio
        
        // 查找最短的一列索引和值
        var destColumn = 0
        var minColumnHeight = flowHeights[0]
        for (i, v) in flowHeights.enumerated() {
            if v < minColumnHeight {
                minColumnHeight = v
                destColumn = i
            }
        }
        
        // 布局的坐标点
        let x = edgeInsets.left + CGFloat(destColumn) * (flowWidth + columnMargin)
        var y = minColumnHeight
        if y != edgeInsets.top {
            y += rowMargin
        }
        
        let rect = CGRect(x: x, y: y, width: flowWidth, height: height)
        
        // 更新最短那列的高度
        flowHeights[destColumn] = rect.maxY
        
        return rect
    }
    
    /// 计算水平瀑布的Frame
    func horizontalItemFrame(with indexPath: IndexPath) -> CGRect {
        // 布局的宽度和高度
        let height = flowWidth
        let size = itemSize(indexPath)
        let aspectRatio = size.width / size.height
        let width = height * aspectRatio
        
        // 查找最短的一列索引和值
        var destRow = 0
        var minRowWidth = flowHeights[0]
        for (i, v) in flowHeights.enumerated() {
            if v < minRowWidth {
                minRowWidth = v
                destRow = i
            }
        }
        
        // 布局的坐标点
        var x = minRowWidth
        if x != edgeInsets.top {
            x += rowMargin
        }
        let y = edgeInsets.top + CGFloat(destRow) * (height + rowMargin)
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        // 更新最短那列的高度
        flowHeights[destRow] = rect.maxX
        
        return rect
    }
    
    /// 计算竖直瀑布的 SupplementaryView 属性
    func verticalSupplementaryViewFrame(ofKind elementKind: String,at indexPath: IndexPath) -> CGRect {
        var y = flowHeights.sorted().last!
        if y == 0 {
            y += edgeInsets.top
        }
        let x = edgeInsets.left
        let w = waterfallWidth
        var h: CGFloat = 0
        switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                h = headerHeight(indexPath.section)
            default:
                h = footerHeight(indexPath.section)
                y += rowMargin
        }
        let rect = CGRect(x: x, y: y, width: w, height: h)
        // 对齐瀑布流长度
        flowHeights = Array(repeating: rect.maxY, count: flowCount)
        return rect
    }
    
    /// 计算水平瀑布的 SupplementaryView 属性
    func horizontalSupplementaryViewFrame(ofKind elementKind: String,at indexPath: IndexPath) -> CGRect {
        var x = flowHeights.sorted().last!
        if x == 0 {
            x += edgeInsets.left
        }
        let y = edgeInsets.top
        let h = waterfallWidth
        var w: CGFloat = 0
        switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                w = headerHeight(indexPath.section)
            default:
                w = footerHeight(indexPath.section)
                x += columnMargin
        }
        let rect = CGRect(x: x, y: y, width: w, height: h)
        // 对齐瀑布流长度
        flowHeights = Array(repeating: rect.maxX, count: flowCount)
        return rect
    }
}
