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
        
//        FunRouter.default.regist(url: "funbox://testList", class_name: "TableViewController")
        FunRouter.default.hz.regist()
        fb.observer.deviceOrientation { (orientation) in
            print(orientation,"AAA")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        FunRouter.default.push2(url: "zz://AAA?aaa=2&bbb=c", params: AAModel())
//        FunBox.router.present2(url: "zz://AAA?aaa=2&bbb=c", params: nil, animated: true, completion: nil)
//        FunBox.toast.message("哈哈").showActivity()
        FunBox.router.scheme = "funbox://"
        
        Service.router.push2(url: "funbox://testOC?aaa=2&bbb=c", params: AAModel(), animated: true, completion: nil)


        Service.router.open(page: .alert(message: "提示"), params: nil, animated: true) { (action) in
            print(action.error?.localizedDescription)
        }
    }
}

struct AAModel {
    var aaa: Int = 1
}

