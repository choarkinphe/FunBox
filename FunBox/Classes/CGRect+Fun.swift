//
//  CGRect+Fun.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/11.
//

import UIKit

extension CGSize {
    init(string: String?) {
        self.init()
        
        let characterSet = CharacterSet(charactersIn: " {}")
        if let size_string = string?.trimmingCharacters(in: characterSet) {
            let array = size_string.components(separatedBy: ",")

            self.width = CGFloat(array.first?.fb.doubleValue ?? 0)
            self.height = CGFloat(array.last?.fb.doubleValue ?? 0)
        }
        
    }
    
    
}
