//
//  TestTableViewController.swift
//  FunBox_Example
//
//  Created by 肖华 on 2021/2/9.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import HandyJSON
struct Test {
    
    struct Element: Codable {
//        enum State: String,Codable {
//            case done = "完成"
//            case send = "已发送"
//            case cancel = "已取消"
//        }
        var state: String?// = .done
        var name: String?
        var time: String?
        
//        var array: [String]?
        
        
    }
    
    class ViewModel: UITableView.FunViewModel.Single<Element> {
        
        func reloadData() {
            if let source = JSONSerialization.fb.decode(fileName: "Test.json", type:[Test.Element].self) {
                
                replace(elements: source)
//                if let source = try? JSONDecoder().decode([Work.Element].self, from: json) {


//                    sections = source
//
//                    collectionView?.reloadData()
//                    for (index,item) in source.enumerated() {
//                        if let title = item.title, let items = item.items {
//
//                            replace(section: compose(section: title, items: items), for: index)
//                        }
//                    }

//                }

            }
            
//        }
        }
        
    }
    
    class TableView: UITableView {
        
        var viewModel = ViewModel()
        
        
        func bind(viewModel: Test.ViewModel) {
            viewModel.dataSource { (ds, table, indexPath, element) -> UITableViewCell in
                let cell = table.fb.dequeueCell(Test.Cell.self, reuseIdentifier: "testCell")
                
                
                cell.element = element
                return cell
            }
            
            viewModel.bind(tableView: self)

        }
    }
    
    class Cell: UITableViewCell {
        
        var element: Element? {
            didSet {
                statusL.text = element?.state//.rawValue
                desL.text = "报告人: \(element?.name ?? "") ,   上报时间:  \(element?.time ?? "")"
                if element?.state == "已完成" {
                    contanier.layer.borderWidth = 0.5
                    contanier.layer.borderColor = UIColor.lightGray.cgColor
                    contanier.backgroundColor = .white
                } else {
                    if element?.state == "已发送" {
                        contanier.backgroundColor = UIColor(red: 224.0/255.0, green: 232.0/255.0, blue: 240.0/255.0, alpha: 1)
                    } else {
                        contanier.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1)
                    }
                    contanier.layer.borderWidth = 0
                    contanier.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
        
        let contanier = UIView()
        let statusIcon = UIImageView()
        let statusL = UILabel()
        let desL = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            selectionStyle = .none
            
            contentView.backgroundColor = .white
            contentView.addSubview(contanier)
            contanier.layer.cornerRadius = 6
            contanier.layer.masksToBounds = true
            
            contanier.snp.makeConstraints { (make) in
                make.top.equalTo(5)
                make.left.equalTo(12)
                make.right.equalTo(-12)
                make.bottom.equalTo(contentView)
            }
            contanier.addSubview(statusIcon)
            statusIcon.snp.makeConstraints { (make) in
                make.left.equalTo(12)
                make.top.equalTo(15)
                make.width.height.equalTo(20)
//                make.right.equalTo(-12)
            }
            
            statusL.font = UIFont.systemFont(ofSize: 14)
            statusL.textColor = .darkText
            contanier.addSubview(statusL)
            statusL.snp.makeConstraints { (make) in
                make.left.equalTo(statusIcon.snp.right).offset(4)
                make.centerY.equalTo(statusIcon)
//                make.right.equalTo(-12)
            }
            
            desL.font = UIFont.systemFont(ofSize: 14)
            desL.textColor = .darkGray
            contanier.addSubview(desL)
            desL.snp.makeConstraints { (make) in
                make.left.equalTo(12)
                make.right.equalTo(-12)
                make.top.equalTo(statusL.snp.bottom).offset(10)
                make.bottom.equalTo(-12)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}

class TestTableViewCController: UIViewController {
    
    var viewModel = Test.ViewModel()
    
    
    lazy var tableView = Test.TableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        fb.contentView = tableView
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = .white
        
        tableView.bind(viewModel: viewModel)
        
        viewModel.reloadData()
    }
}


