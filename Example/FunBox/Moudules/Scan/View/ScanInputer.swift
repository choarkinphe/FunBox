//
//  ScanInputer.swift
//  PollCall
//
//  Created by choarkinphe on 2020/12/31.
//  Copyright © 2020 Konnech Inc'. All rights reserved.
//

import UIKit
//import FunScan


class ScanInputer: UIView {
    let titleLabel = UILabel()
    let textField = UITextField()
    let scan_button = UIButton()
    init(title: String, frame: CGRect = .zero) {
        super.init(frame: frame)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .darkText
        titleLabel.text = title
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(10)
        }
        
        scan_button.addTarget(self, action: #selector(scanAction(sender:)), for: .touchUpInside)
        scan_button.backgroundColor = .red
        addSubview(scan_button)
        scan_button.snp.makeConstraints { (make) in
            make.right.equalTo(-12)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalTo(-8)
            make.width.equalTo(scan_button.snp.height)
        }
        
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Scan Item Barcode"
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.bottom.equalTo(scan_button)
            make.right.equalTo(scan_button.snp.left).offset(-8)
//                make.bottom.equalTo(-8)
        }
        
//            textField.rightView = scan_button
//            textField.rightViewMode = .always
        
        textField.addTarget(self, action: #selector(textChangedAction(textField:)), for: .valueChanged)
        
    }
    
    private var textChanged: ((String)->Void)?
    func textChanged(_ handle: @escaping ((String)->Void)) {
        textChanged = handle
    }
    @objc func textChangedAction(textField: UITextField) {
        textChanged?(textField.text ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//            titleLabel.frame = CGRect(x: 12, y: 0, width: bounds.width-24, height: 20)
//            scan_button.frame = CGRect(x: bounds.width - 68, y: 0, width: 44, height: 44)
//            textField.frame = CGRect(x: 12, y: titleLabel.frame.maxY+4, width: bounds.width - 68, height: bounds.height)
    }
    
    @objc private func scanAction(sender: UIButton) {
        FunScan.default.response { (navigation) in
            
            if let content = navigation.content {
                FunBox.alert
                    .title("Tips\n")
                    .message("Input \(content)?")
                    .addAction(title: "Cancel", style: .cancel) { (action) in
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            navigation.dismiss(false)
                        }
                    }
                    .addAction(title: "Sure", style: .default) { (action) in
                        self.textField.text = content
                        navigation.dismiss(true)
                    }.present()
            }
        }
    }
}
extension ScanInputer: UITextFieldDelegate {
    
}



class PCInputCard: UIView {
    let titleLabel: UILabel
    let textView: FunTextView
    init(title: String, frame: CGRect = .zero) {
        titleLabel = UILabel(title: title, color: .darkText, font: .boldSystemFont(ofSize: 16))
        textView = FunTextView()
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(12)
        }
        
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.darkGray.cgColor
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.right.equalTo(-12)
            make.bottom.equalTo(-12)
//                make.height.greaterThanOrEqualTo(64)
        }
        
        textView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    private var textChanged: ((String)->Void)?
    func textChanged(_ handle: @escaping ((String)->Void)) {
        textChanged = handle
    }
}

extension PCInputCard: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textChanged?(textView.text)
    }
}
fileprivate extension UILabel {
    convenience init(title: String?=nil, color: UIColor = .darkText, font: UIFont = .systemFont(ofSize: 14)) {
        self.init()
        self.text = title
        self.textColor = color
        self.font = font
    }
}

extension UIView {
    
    convenience init(bottomView: UIView) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 49))
        
        addSubview(bottomView)
        bottomView.layer.cornerRadius = 8
        bottomView.layer.masksToBounds = true
        
        bottomView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(self)
            make.height.equalTo(44)
        }
        
    }
}
