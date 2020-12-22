//
//  FunRefresher.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/22.
//

import UIKit
// MARK: - Refresher
extension FunBox {
    public class Refresher: UIRefreshControl {
        private var handler: ((UIRefreshControl)->Void)?
        private var timeOut: TimeInterval = FunBox.Refresher.Config.timeOut
        public func text(_ text: String) -> Self {
            self.attributedTitle = NSAttributedString(string: text)
            return self
        }
        
        public func timeOut(_ timeOut: TimeInterval) -> Self {
            self.timeOut = timeOut
            return self
        }
        
        public func tintColor(_ tintColor: UIColor) -> Self {
            self.tintColor = tintColor
            return self
        }
        
        public func complete(_ complete: ((UIRefreshControl)->Void)?) {
            addTarget(self, action: #selector(refreshAction(sender:)), for: .valueChanged)
            self.handler = complete
        }
        
        @objc private func refreshAction(sender: UIRefreshControl) {
            if let handler = self.handler {
                handler(sender)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+timeOut) {
                sender.endRefreshing()
            }
        }
        
        public override func layoutSubviews() {
            superview?.layoutSubviews()
            
            
        }
    }
}

public extension FunNamespaceWrapper where T: UIScrollView {
    var refresher: FunBox.Refresher {
        let refresher = FunBox.Refresher()
        wrappedValue.refreshControl = refresher
        return refresher
    }
}

extension FunBox.Refresher {
    struct Config {
        static var timeOut: TimeInterval = 15
    }
}
