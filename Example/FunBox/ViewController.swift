//
//  ViewController.swift
//  FunBox
//
//  Created by xiaohua on 05/08/2020.
//  Copyright (c) 2020 xiaohua. All rights reserved.
//

import UIKit
import FunBox
import Photos
class ViewController: UIViewController {

    let work = WorkViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addChild(work)
        work.view.frame = view.bounds
        view.addSubview(work.view)
//        FunRouter.default.regist(url: "funbox://testList", class_name: "TableViewController")
//        FunRouter.default.hz.regist()
        fb.observer.deviceOrientation { (orientation) in
            print(orientation,"AAA")
        }
//        FunBox.cache.removeAllCache()
//        FunBox.FPS.default.set(frame: CGRect(x: 40, y: 24, width: 88, height: 28)).show()
        
//        FunBox.Location.default
        
        FunRouter.default.regist(host: .init(rawValue: "Sub"), router: SubRouter.self)
        
//        PHPhotoLibrary.fb.save(album: .default, resource: UIImage()) { (result) in
//            
//        }
//        
//        PHPhotoLibrary.fb.save(resource: URL(fileURLWithPath: "")) { (result) in
//            
//            // 保存到相册的对象
//            result.asset
//            
//            // 错误信息
//            result.error
//        }
        
        FunLoger.record("我是第一条记录")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var progress: CGFloat = 0.0
    // 创建一个计时器
    let timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /*
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
        */
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
        
//        FunBox.router.regist(url: <#T##FunRouterPathable?#>, class_name: <#T##String?#>)
        
//        FunBox.router.scheme = "fb"
        
//        Service.router.open(url: URL(string: "funbox://testOC?aaa=2&bbb=c"), params: ["aaa":1], animated: true, handler: nil)
//        Service.router.open(url: "funbox://testList?aaa=2&bbb=c", params: AAModel(), animated: true) { (action) in
            
//        }
//        Service.router.open(page: .message)
//        Service.router.open(page: .alert(message: "提示"), params: nil, animated: true) { (action) in
//            print(action.error?.localizedDescription)
//        }
        
//        let image = UIImage(named: "fb_tips_error", in: FunBox.bundle, compatibleWith: nil)
//
//        print(image)
        
//        FunBox.cache.cache(key: "哈哈", data: "XXX".data(using: .utf8))
//        if let data = FunBox.cache.loadCache(key: "哈哈"), let text = String(data: data, encoding: .utf8) {
//            FunBox.toast.template(.error).title("测粉丝当试").message(text).style(.system).inView(self.view).show()
//        }
        
//        let url = "fb://Alert?message=哈哈哈&title=呵呵"
//        let url = "fb://Aub/bbb/ccc"
//        FunBox.router.regist(url: "fb://Aub/bbb/ccc", class_name: "ViewController")
//        if let URL = url.asURL() {
//            print("host: \(URL.host)")
//            print("relativePath: \(URL.relativePath)")
//        }
//        
//        FunBox.router.open(url: url)
        
//        navigationController?.pushViewController(WebViewController(), animated: true)
//        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//        FunBox.cache.cache(key: "AAA", data: "AAA_Value".data(using: .utf8))
////        }
////            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
//        FunBox.cache.cache(key: "BBB", data: "BBB_Value".data(using: .utf8))
////            }
////                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
//        FunBox.cache.cache(key: "CCC", data: "CCC_Value".data(using: .utf8))
////                }
////                    DispatchQueue.main.asyncAfter(deadline: .now()+4) {
//        FunBox.cache.cache(key: "DDD", data: "DDD_Value".data(using: .utf8))
////                    }
//
//        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
//            let indexes = FunBox.cache.indexes
//
//                print(indexes)
//
//
//
//        }
//
//
//        let indexes = FunLoger.indexes
//
//        print(indexes)
//        if let log = FunLoger.read(index: indexes.first) {
//            print(log.message)
//        }
//
//        FunBox.toast.template(.info).message("哈哈").position(.center).inView(self.view).show()
        
    }
}

struct AAModel {
    var aaa: Int = 1
}

class SubRouter: FunRouterable {
    func open(url: FunRouterPathable?, handler: ((FunRouter.Response) -> Void)?) {
        print(url)
    }
    
    static func current() -> FunRouterable {
        return SubRouter()
    }
    
    
}

