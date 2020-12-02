//
//  WorkModel.swift
//  Store
//
//  Created by choarkinphe on 2020/6/20.
//  Copyright © 2020 Konnech. All rights reserved.
//

import Foundation
struct Work {
    struct Tips {
        static var working = "功能正在紧急研发中，敬请期待..."
    }
    struct Tab: Codable {
        // 图标
        var icon: String?
        // 名称
        var name: String?
        // 路由
        var linkUrl: String?
    }
    
    struct Element: Codable {
        var title: String?
        
        var items: [Tab]?
    }
}
