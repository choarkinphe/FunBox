//
//  UIScrollView+Refresher.swift
//  Store
//
//  Created by choarkinphe on 2020/6/12.
//  Copyright © 2020 Konnech. All rights reserved.
//

import Foundation
import MJRefresh
extension UIScrollView {
    public class Refresher: NSObject {
        
        fileprivate struct Key {
            static var refresherKey = "com.refresher.scrollView.key"
        }
        
        public enum State {
            case normal
            case refreshing
            case disable
        }
        
        
        public var state: State = .normal
        public var page = Page(size: 20) {
            didSet {
                // 没有加载出数据时，不现实上拉加载控件
                isPullUpEnable = page.count > 0

                if isLoadCompelete, let sender = target?.mj_footer {
                    //加载完全部之后
                    sender.endRefreshingWithNoMoreData()
                }
            }
        }
        public var isLoadCompelete: Bool {
            // 获取总页数
            // 当前页与总页数相同时，加载完毕
            return page.total > 0 && page.count >= page.total
        }
        public var isRefreshing: Bool {
            return state == .refreshing
        }
        
        public enum Style {
            case system
            case `default`
        }
        
        public var tintColor: UIColor? = .darkText
        
        public struct Page {
            public init(size: Int) {
                self.size = size
            }
            // 当前页
            public var index: Int = 0
            // 当前位置
            public var offset: Int = 0
            // 当前数量
            public var count: Int {
                return offset + 1
            }
            // 总数
            public var total: Int = 0
            // 单页个数
            public var size: Int = 20
            // other infomation(custom)
            public var options = [String: Any]()
        }
        
        public var isPullDownEnable: Bool = true {
            didSet {
                
                target?.mj_header?.isHidden = !isPullDownEnable
                target?.refreshControl?.isHidden = !isPullDownEnable
            }
        }
        public var isPullUpEnable: Bool = true {
            didSet {
                if isPullUpEnable {
                    target?.mj_footer?.alpha = 1
                } else {
                    target?.mj_footer?.alpha = 0
                }
            }
        }
        
        private var pullDownHandler: ((Refresher)->Void)?
        private var pullUpHandler: ((Refresher)->Void)?
        private weak var target: UIScrollView?
        init(target: UIScrollView) {
            super.init()
            self.target = target
        }
        
        public func pullDown(style: Style = .default, _ handler: ((Refresher)->Void)?) {
            
            if style == .default {
                let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(pullDownAction(sender:)))
                
                target?.mj_header = header
            } else if  style == .system {
                let header = UIRefreshControl()
                header.addTarget(self, action: #selector(pullDownAction(sender:)), for: .valueChanged)
                if let tintColor = tintColor {
                    header.tintColor = tintColor
                }
                target?.refreshControl = header
            }
            
            
            pullDownHandler = handler
            
            
            
        }
        
        public func pullUp(percent: CGFloat?=nil, _ handler: ((Refresher)->Void)?) {
            
            let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(pullUpAction))
            footer.ignoredScrollViewContentInsetBottom = UIDevice.current.fb.isInfinity ? 34 : 0
            footer.isAutomaticallyChangeAlpha = true
            footer.stateLabel?.font = UIFont.systemFont(ofSize: 13)
            footer.stateLabel?.textColor = UIColor(hex: "999999")
            footer.setTitle(" —————  没有更多啦  ————— ", for: .noMoreData)
            
            //footer出现一半时就执行请求
            footer.triggerAutomaticallyRefreshPercent = percent ?? 0.2
            
            target?.mj_footer = footer
            pullUpHandler = handler
            
        }
        
        @objc private func pullDownAction(sender: Any?) {
            if !isPullDownEnable {
                return
            }
            if isRefreshing {
                //有正在加载的任务，直接忽略
                if let sender = sender as? MJRefreshHeader {
                    sender.endRefreshing()
                } else if let sender = sender as? UIRefreshControl {
                    sender.endRefreshing()
                }
                
                return
            }
            
            //重置页面当前的状态
            page.offset = 0
            page.index = 0
            page.total = 0
            
            // 重置footer状态
            if let footer = target?.mj_footer {
                footer.state = .idle
                
                footer.resetNoMoreData()
               
            }
            
            // 标记刷新状态
            state = .refreshing
            
            if let handler = pullDownHandler {
                handler(self)
                //2秒后强制关闭下拉加载动画
                perform(#selector(endRefesh(sender:)), with: sender, afterDelay: 2.0)
            }
            
        }
        
        @objc private func pullUpAction(sender: MJRefreshFooter?) {
            if !isPullUpEnable {
                sender?.isHidden = true
                return
            }
            if isRefreshing {
                //有任务正在加载不再调用加载方法
                return
            }
            sender?.isHidden = false
            if (isLoadCompelete) {
                
                //加载完全部之后
                sender?.endRefreshingWithNoMoreData()
                
                return
            }
            
            if let handler = pullUpHandler {
                handler(self)
                //1秒后关闭上拉加载动画，允许下一次加载
                perform(#selector(endRefesh(sender:)), with: sender, afterDelay: 1)
            }
        }
        
        //刷新方法
        public func beginRefresh(animated: Bool = false) {
            
            if let sender = target?.mj_header {
                if animated {
                    sender.beginRefreshing()
                } else {
                    pullDownAction(sender: sender)
                }
            } else if let sender = target?.refreshControl {
                if animated {
                    sender.beginRefreshing()
                }
                pullDownAction(sender: sender)
            }
            
            
        }
        
        //关闭刷新
        @objc public func endRefesh(sender: Any?=nil) {
            
            if let header = sender as? MJRefreshNormalHeader {
                
                if header.state == .refreshing {
                    //正在下拉，创建一个震动反馈
                    UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                    header.endRefreshing {
                        
                    }
                }
                
            } else if let footer = sender as? MJRefreshAutoNormalFooter {
                if footer.state == .refreshing {
                    footer.endRefreshing {
                        if (self.isLoadCompelete) {
                            
                            //加载完全部之后
                            footer.endRefreshingWithNoMoreData()
                        }
                    }
                }
            } else if let header = sender as? UIRefreshControl {
                
                //正在下拉，创建一个震动反馈
                UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                header.endRefreshing()
            }
            
            state = .normal
            
        }
    }
}

extension UIScrollView {
    
    public var refresher: Refresher {
        set {
            
            objc_setAssociatedObject(self, &Refresher.Key.refresherKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        
        get {
            
            if let object = objc_getAssociatedObject(self, &Refresher.Key.refresherKey) {
                return object as! Refresher
            } else {
                objc_setAssociatedObject(self, &Refresher.Key.refresherKey, Refresher(target: self), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return self.refresher
        }
    }
    
}

extension UIScrollView.Refresher.Page: APIPageParamterable {
    public func asParams() -> API.Paramter {
        var params = options
        params["index"] = index
        params["size"] = size
        return params
    }
}
