//
//  ViewController.swift
//  FunBox
//
//  Created by xiaohua on 05/08/2020.
//  Copyright (c) 2020 xiaohua. All rights reserved.
//

import UIKit
import FunBox
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        FunRouter.default.regist(url: "zz://AAA", class_name: "TableViewController")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        FunRouter.default.push2(url: "zz://AAA?aaa=2&bbb=c", params: AAModel())
//        FunBox.router.present2(url: "zz://AAA?aaa=2&bbb=c", params: nil, animated: true, completion: nil)
        FunBox.toast.message("哈哈").showActivity()
    }
}

struct AAModel {
    
}

