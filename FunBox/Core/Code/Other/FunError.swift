//
//  FunError.swift
//  FunBox
//
//  Created by 肖华 on 2020/3/25.
//

import Foundation

public typealias FunError = FunBox.LocalError
public extension FunBox {
    struct LocalError: LocalizedError {
        // description会直接传入给localizedDescription
        public init(description: String?) {
            self.description = description
        }
        // 内部变量暂存错误信息
        private var description: String?
        
        public var errorDescription: String? {
            return description
        }
    }
}

//public typealias FunError = FunBox.LocalError
//public extension FunBox {
//    struct LocalError: LocalizedError {
//        // desc会直接传入给localizedDescription
//        public init(code: Int?=nil, description: String?) {
//            self.code = code ?? 0
//            self.description = description
//        }
//        private(set) var code: Int
//        // 内部变量暂存错误信息
//        private var description: String?
//
//        public var localizedDescription: String? {
//            return description
//        }
//    }
//}

