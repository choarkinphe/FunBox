//
//  FunScanController.swift
//  FunBox
//
//  Created by choarkinphe on 2020/10/15.
//  Copyright © 2020 Konnech. All rights reserved.
//

import AVFoundation
import UIKit
#if !COCOAPODS
import FunBox
import FunUI
#endif
public typealias FunScanController = FunScan.ScanViewController

extension FunScan {
    public class ScanViewController: UIViewController {
        fileprivate var position_buttonHandle: ((UIButton)->Void)?
        // 缓存上次绘制的图层
        private lazy var deleteTempLayers = [CAShapeLayer]()
        
        // 配置样式
        var style: FunScan.Style = .default
        // 扫码结果的回调
        var handle: ((String?)->Void)?
        
//        private var disposeBag = DisposeBag()
        
        // 预览图层
        private let previewLayer = AVCaptureVideoPreviewLayer()
        
        /// 输入
        private var inPut: AVCaptureDeviceInput?
        
        /// 输出
        private var outPut: AVCaptureMetadataOutput = {
            let outPut = AVCaptureMetadataOutput.init()
            outPut.connection(with: .metadata)
            
            return outPut
        }()
        
        // 视频会话对象
        private let session: AVCaptureSession = {
            let session = AVCaptureSession()
            if session.canSetSessionPreset(.high){
                session.sessionPreset = .high
            }
            
            return session
        }()

        // 覆层（动画层）
        private let maskView = MaskView()
        
        public var metadataObjectTypes: [AVMetadataObject.ObjectType] = [.ean13, .ean8, .upce, .code39, .code93, .code128, .code39Mod43, .qr]
        
        // 初始化
        public override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black
            guard let device = AVCaptureDevice.default(for: .video)  else {
                return
            }
            do {
                inPut = try AVCaptureDeviceInput.init(device: device)
            } catch  {
                
            }

            // 扫描区域
            let screen = UIScreen.main.bounds
            let rect = CGRect(x: style.scanInsets.left, y: style.scanInsets.top, width: screen.width - style.scanInsets.left - style.scanInsets.right, height: screen.height - style.scanInsets.top - style.scanInsets.bottom)
            let x = rect.origin.x / screen.size.width
            let y = rect.origin.y / screen.size.height
            let width = rect.size.width / screen.size.width
            let height = rect.size.height / screen.size.height
            outPut.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
            
            outPut.setMetadataObjectsDelegate(self, queue: .main)
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill

            maskView.infoLabel.text = style.title
            
            let navigationBar = FunNavigationBar(template: .default, frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIDevice.current.fb.isInfinity ? 88 : 64))
            
            initNavigationBar(navigationBar: navigationBar)
            
            fb.navigationBar = navigationBar
            
            fb.contentView = maskView
            
            fb.contentInsets = UIEdgeInsets(top: 0.01, left: 0, bottom: 0, right: 0)
            


        }
        
        // 设置导航栏样式
        public func initNavigationBar(navigationBar: FunNavigationBar) {
            navigationBar.backgroundColor = .clear
            navigationBar.backItemImage = UIImage(named: "ic_scan_back", in: FunScan.bundle, compatibleWith: nil)
            navigationBar.backAction { (sender) in
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        private var isNavigationBarHiddenFlag: Bool = false
        
        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            isNavigationBarHiddenFlag = navigationController?.isNavigationBarHidden ?? false
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        public override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            navigationController?.setNavigationBarHidden(isNavigationBarHiddenFlag, animated: false)
        }
        
        // 页面显示后开启扫描
        public override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            start()

        }
        
        // 页面消失后关闭扫描
        public override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            stop()
        }
        
        
        public override var prefersStatusBarHidden: Bool {
            return true
        }
    }
}

extension FunScanController {
    func show() {
        if UIApplication.shared.fb.canPush {
            UIApplication.shared.fb.frontController?.navigationController?.pushViewController(self, animated: true)
        } else {
            UIApplication.shared.fb.frontController?.present(self, animated: true, completion: {
                
            })
        }
    }
    
    func dismiss() {
        if UIApplication.shared.fb.canPush {
            if UIApplication.shared.fb.frontController?.navigationController?.visibleViewController == self {
                UIApplication.shared.fb.frontController?.navigationController?.popViewController(animated: true)
            } else {
                if let index = UIApplication.shared.fb.frontController?.navigationController?.viewControllers.firstIndex(of: self) {
                    UIApplication.shared.fb.frontController?.navigationController?.viewControllers.remove(at: index)
                }
                
            }
        } else {
            UIApplication.shared.fb.frontController?.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    func start() {
        // 开启扫描动画
        maskView.animation(true)
        
        guard let input = inPut else {
            // 错误回调
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(outPut) {
            session.addOutput(outPut)
        }
        
        // 设置元数据处理类型(注意, 一定要将设置元数据处理类型的代码添加到  会话添加输出之后)
        outPut.metadataObjectTypes = metadataObjectTypes
        
        // 添加预览图层
        if view.layer.sublayers?.contains(previewLayer) != true {
            previewLayer.frame = view.bounds
            view.layer.insertSublayer(previewLayer, at: 0)
        }
        
        // 启动会话
        session.startRunning()
        // 一出绘制层
        removeShapLayer()
        
    }
    
    /// 停止扫描
    func stop() {
        // 停止扫描动画
        maskView.animation(false)
        
        session.stopRunning()
        if let input = inPut {
            session.removeInput(input)
        }
        session.removeOutput(outPut)
        removeShapLayer()
    }
    
    
}

extension FunScanController: AVCaptureMetadataOutputObjectsDelegate {

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // 移除上一次的绘制层
        removeShapLayer()
        
        if metadataObjects.count > 1 { // 识别到多个二维码
            
            for (index,obj) in metadataObjects.enumerated() {
                
                guard let codeObj = obj as? AVMetadataMachineReadableCodeObject else {
                    return
                }
                
                // obj 中的四个角, 是没有转换后的角, 需要我们使用预览图层转换
                if let tempObj = previewLayer.transformedMetadataObject(for: codeObj) as? AVMetadataMachineReadableCodeObject {
                    // 多个二维码时绘制图层
                    addShapeLayers(transformObj: tempObj, result: FunScan.Result(label: "二维码\(index+1)", stringValue: codeObj.stringValue))
                }
                
                
                
            }
            
        } else { // 只扫描到一个二维码
            guard let codeObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
                return
            }
            
            // 只有一个二维码时，直接给出回调
            handle?(codeObj.stringValue)
            
        }
        
        
        session.stopRunning()
        // 停止扫描动画
        maskView.animation(false)
    }
    
    /// 添加框框
    private func addShapeLayers(transformObj: AVMetadataMachineReadableCodeObject, result: FunScan.Result) {
        
        // 绘制边框
        let layer = CAShapeLayer()
        layer.strokeColor = style.boardColor.cgColor
        layer.lineWidth = style.boardWidth
        layer.fillColor = UIColor.clear.cgColor
        
        // 创建一个贝塞尔曲线
        let path = UIBezierPath()
        
        for (index,pointDic) in transformObj.__corners.enumerated() {
            
            let dict = pointDic as CFDictionary
            let point = CGPoint(dictionaryRepresentation: dict) ?? CGPoint.zero
            
            if index == 0 {
                path.move(to: point)
                
                // 在第一个点的正上方加一个标签按钮用于跳转
                let position_button = FunButton()
                position_button.setTitleColor(.darkText, for: .normal)
                position_button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                position_button.frame = CGRect(x: max(point.x, 0), y: max((point.y - 44), 0), width: 110, height: 40)
                position_button.layout = .imageRight
                position_button.setTitle(result.label, for: .normal)
                position_button.setImage(style.tagImage, for: .normal)
                position_button.backgroundColor = .white
                position_button.layer.cornerRadius = 20
                position_button.layer.masksToBounds = true
                view.addSubview(position_button)
                
                position_button.addTarget(self, action: #selector(position_buttonAction(sender:)), for: .touchUpInside)
                
                position_buttonHandle = { [weak self] (sender) in
                    self?.handle?(result.stringValue)
                }
//                position_button.rx.tap.response { [weak self] in
//
//                }.disposed(by: disposeBag)
                
            } else {
                path.addLine(to: point)
            }
            print(point)
            
        }
        
        path.close()
        layer.path = path.cgPath
        previewLayer.addSublayer(layer)
        deleteTempLayers.append(layer)
        
    }
    
    
    
    @objc private func position_buttonAction(sender: UIButton) {
        position_buttonHandle?(sender)
//        self?.handle?(result.stringValue)
    }
    
    /// 移除二维码边框图层
    private func removeShapLayer() {
        for layer in deleteTempLayers {
            layer.removeFromSuperlayer()
        }
        view.fb.removeAllSubviews(type: FunButton.self)
        deleteTempLayers.removeAll()
    }
}





