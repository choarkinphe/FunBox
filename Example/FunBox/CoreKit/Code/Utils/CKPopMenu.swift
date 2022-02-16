//
//  HZPopMenu.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/12/2.
//

import Foundation
#if !COCOAPODS
import FunBox
#endif
public typealias CKPopMenu = FunBox.PopMenu.Manager

extension CKPopMenu {
    public static var konnech: FunBox.PopMenu.Manager {
        let manager = FunBox.PopMenu.Manager()
        manager.appearance.font = Theme.Font.default
        manager.appearance.backgroundStyle = .dimmed(color: .clear, opacity: 0.2)
        manager.appearance.contentOffset = CGPoint(x: 0, y: 32)
        manager.dismissOnSelection = true
        return manager
    }
    
    public static var project: FunBox.PopMenu.Manager {
        let manager = FunBox.PopMenu.Manager()
        manager.appearance.font = Theme.Font.default
        manager.appearance.backgroundStyle = .dimmed(color: .clear, opacity: 0.2)
        manager.appearance.contentOffset = CGPoint(x: 10, y: 52)
        manager.appearance.showAriangle = true
        manager.appearance.colorStyle = .configure(background: .solid(fill: .white), action: .tint(.darkText))
        manager.appearance.showCutLine = true
        manager.dismissOnSelection = true
        return manager
    }
    
    /// Pass a new action to pop menu.
    public func feedAction(_ action: PopMenuElement) -> Self {
        actions.append(action.asPopMenu())
        return self
    }
    
    public func feedActions(_ actions: [PopMenuElement]) -> Self {
        actions.forEach { (action) in
            self.actions.append(action.asPopMenu())
        }
        return self
    }
    
    public func set(contentOffset: CGPoint) -> Self {
        self.appearance.contentOffset = contentOffset
        return self
    }
    
    public func selectHandle(_ handle: @escaping (PopMenuAction) -> Void) -> Self {
        select(handle)
        return self
    }
    
}
