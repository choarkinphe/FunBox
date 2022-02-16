//
//  RichTextViewController.swift
//  FunBox_Example
//
//  Created by 肖华 on 2022/2/10.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import RichTextView
class RichTextViewController: UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentView)
        
        if let filePath = Bundle.main.path(forResource: "demo", ofType: "html") {

        do {

            let html = try String(contentsOfFile: filePath, encoding: .utf8)
        
            contentView.update(input: html)
//            contentView.input

//        webView.loadHTMLString(htmlString as String  , baseURL: NSURL.fileURLWithPath(filePath!))

//        self.view.addSubview(webView)

        }

        catch{

        }
        }
        
    }
    
    lazy var contentView: RichTextView = {
        let _contentView = RichTextView(font: .systemFont(ofSize: 16), frame: view.bounds)
        _contentView.backgroundColor = .lightGray
        return _contentView
    }()
}
