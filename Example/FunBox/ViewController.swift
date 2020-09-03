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

    var progress: CGFloat = 0.0
    // 创建一个计时器
    let timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        // 每0.1s执行一次
        timer.schedule(wallDeadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(0))
        // 开启计时器
        timer.setEventHandler {
            self.progress = self.progress + 0.01
            FunBox.toast.message("正在下载...").mode(.progress).inView(self.view).progress(self.progress).show { (done) in
                if done {
                    // 下载完成
//                    FunBox.toast.dismissActivity(inView: self.view)
                    FunBox.toast.message("下载成功").inView(self.view).show()
                    self.timer.cancel()
                }
            }
            print(self.progress)
        }
        
        timer.resume()
        
//        FunRouter.default.push2(url: "zz://AAA?aaa=2&bbb=c", params: AAModel())
//        FunBox.router.present2(url: "zz://AAA?aaa=2&bbb=c", params: nil, animated: true, completion: nil)
//        FunBox.toast.message("我来报个提示，可能是出错了吧").mode(.activity).image(UIImage(named: "ic_home_info")).inView(view).show()
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//            FunBox.toast.message("提示1").image(UIImage(named: "ic_home_info")).inView(self.view).show()
//        FunBox.toast.message("提示2").image(UIImage(named: "ic_home_info")).inView(self.view).show()
//        FunBox.toast.message("提示3").image(UIImage(named: "ic_home_info")).inView(self.view).show()
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
//            FunBox.toast.dismiss(inView: self.view)
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now()+8) {
//            FunBox.toast.dismissActivity(inView: self.view)
//        }
//        FunBox.router.scheme = "funbox://"
        
//        Service.router.open(url: URL(string: "funbox://testOC?aaa=2&bbb=c"), params: ["aaa":1], animated: true, handler: nil)
//        Service.router.open(url: "funbox://testList?aaa=2&bbb=c", params: AAModel(), animated: true) { (action) in
            
//        }
//        Service.router.open(page: .message)
//        Service.router.open(page: .alert(message: "提示"), params: nil, animated: true) { (action) in
//            print(action.error?.localizedDescription)
//        }
        
        
    }
}

struct AAModel {
    var aaa: Int = 1
}

