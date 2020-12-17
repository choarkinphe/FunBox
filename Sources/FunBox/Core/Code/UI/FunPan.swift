//
//  FunPan.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/4.
//

import UIKit
public typealias FunPanHandler = ((Set<UITouch>,UIEvent)->Void)
public typealias FunPan = FunBox.Pan
public extension FunBox {
    class Pan: UIPanGestureRecognizer {
        
        private var beganHandler: FunPanHandler?
        public func touchesBegan(_ handler: FunPanHandler?) {
            beganHandler = handler
        }
        private var movedHandler: FunPanHandler?
        public func touchesMoved(_ handler: FunPanHandler?) {
            movedHandler = handler
        }
        private var cancelHandler: FunPanHandler?
        public func touchesCancelled(_ handler: FunPanHandler?) {
            cancelHandler = handler
        }
        
        private var endHandler: FunPanHandler?
        public func touchesEnded(_ handler: FunPanHandler?) {
            endHandler = handler
        }
        
        public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesBegan(touches, with: event)
            
            if let handler = beganHandler {
                handler(touches,event)
            }
        }
        
        public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesMoved(touches, with: event)
            if let handler = movedHandler {
                handler(touches,event)
            }
        }
        
        public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesCancelled(touches, with: event)
            if let handler = cancelHandler {
                handler(touches,event)
            }
        }
        
        public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesEnded(touches, with: event)
            
            if let handler = endHandler {
                handler(touches,event)
            }
        }
    }
}
