//
//  FunPan.swift
//  HZCommon
//
//  Created by choarkinphe on 2020/8/25.
//  Copyright © 2020 hongzheng. All rights reserved.
//

import Foundation
public typealias FunPanHandler = ((Set<UITouch>,UIEvent)->Void)
public typealias FunPan = FunBox.Pan
public extension FunBox {
    class Pan: UIPanGestureRecognizer {
        
        private var beganHandler: FunPanHandler?
        func touchesBegan(_ handler: FunPanHandler?) {
            beganHandler = handler
        }
        private var movedHandler: FunPanHandler?
        func touchesMoved(_ handler: FunPanHandler?) {
            movedHandler = handler
        }
        private var cancelHandler: FunPanHandler?
        func touchesCancelled(_ handler: FunPanHandler?) {
            cancelHandler = handler
        }
        
        private var endHandler: FunPanHandler?
        func touchesEnded(_ handler: FunPanHandler?) {
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
