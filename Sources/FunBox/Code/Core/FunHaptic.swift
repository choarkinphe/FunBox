//
//  FunHaptic.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/22.
//

import UIKit
public typealias FunHaptic = FunBox.Haptic
extension FunBox {
    /// Haptic Generator Helper.
    public enum Haptic {
        
        /// Impact style.
        @available(iOS 10.0, *)
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        
        /// Notification style.
        @available(iOS 10.0, *)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        
        /// Selection style.
        case selection
        
        /// Trigger haptic generator.
        public func generate() {
            guard #available(iOS 10, *) else { return }
            
            switch self {
            case .impact(let style):
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
            case .notification(let type):
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(type)
            case .selection:
                let generator = UISelectionFeedbackGenerator()
                generator.prepare()
                generator.selectionChanged()
            }
        }
    }
}
