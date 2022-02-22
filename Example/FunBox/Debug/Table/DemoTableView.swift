//
//  DemoTableView.swift
//  orange
//
//  Created by 肖华 on 2022/2/17.
//

import Foundation
import HandyJSON
import RxRelay
import RxSwift
import UIKit
import Alamofire
import FunAlamofire
struct Demo {
    
}

extension Demo {
    struct News: HandyJSON, Codable {
        var path: String?
        var image: String?
        var title: String?
        var passtime: String?
        /*
        enum Provider: TargetType {
            case news(params: APIParamterable)
//            var method: Moya.Method {
//                return .get
//            }
            var path: String {
                
                switch self {
                case .news:
                    return "/getWangYiNews"
                }
            }
            var task: Task {
                switch self {
                case .news(let params):
                    return .requestCompositeParameters(bodyParameters: [:], bodyEncoding: URLEncoding.httpBody, urlParameters: params.asParams())
//                    return .requestCompositeParameters(urlParameters: params.asParams())
//                    return .requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    //            default:
//                    return .requestPlain
                    
                }
            }
            
            var baseURL: URL {
                return URL(string: "http:/api.apiopen.top")!
            }
        }
         */
    }
    

    
    class ViewModel: UITableView.ViewModel<News> {
     
//        var provider = API.Provider<News.Provider>()
        
        func reload() {

            FunAlamofire.default // 默认请求实例
                .request(to: "http://api.apiopen.top/getWangYiNews")                        // 创建请求任务
                .params(["page":0,"count":100])                                             // 添加请求参数
                .options([.cache(timeOut: 5)])                                              // 请求的可选项，是否缓存，绑定响应器（请求期间响应器不响应事件）等
                .mapObject(Service.Result<News>.self, completion: { [weak self] result in   // 依据HandyJSON或Codable解析返回值
                    
                    // result就是Service.Result类型，array就是News类型
                    
                    if let array = result.array {
                        
//                        var result = Service.PageElement<Demo.News>()
//
//                        result.rows = array
//                        self?.feed(pageSource: result)
                        // 把数据添加给viewModel的数据源，tableView就会自动更新数据
                        self?.append(elements: array)
                    }
                })
                .resume() // 开启请求任务
                            
        }
    }
}

extension API {
//    static var demo = MoyaProvider<DemoType>()

}

class DemoViewController: UIViewController {
    
    var viewModel = Demo.ViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fb.contentView = contentView
        
        contentView.bind(viewModel: viewModel)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        contentView.refresher.beginRefresh(animated: true)
    }
    
    
    lazy var contentView: Demo.TableView = {
        let tableView = Demo.TableView(frame: view.bounds, style: .grouped)
        return tableView
    }()
}
extension Demo {
    
    class TableView: UITableView {
        override init(frame: CGRect, style: UITableView.Style) {
            super.init(frame: frame, style: style)
            
            if #available(iOS 11.0, *) {
                contentInsetAdjustmentBehavior = .never
            } else {
                // Fallback on earlier versions
            }
            separatorStyle = .none
//            backgroundColor = Theme.Color.darkBackground.withAlphaComponent(0.8)
            backgroundColor = Theme.Color.systemBackground
            
            keyboardDismissMode = .onDrag
            
            estimatedRowHeight = 88.0
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func bind(viewModel: Demo.ViewModel) {
//            delegate = viewModel
//            dataSource = viewModel

//            let source = CKTableViewDataSource

//            viewModel.dataSource { source, tableView, indexPath, element in
//
//            }
            let source = CKTableViewDataSource<String?,Demo.News>(
                    
                    configureCell: { (dataSource, tableView, indexPath, element) in
                        let cell = tableView.fb.dequeueCell(Cell.self, reuseIdentifier: "Key.cell_id")
                        
                        cell.titleLabel.text = element.title
                        cell.iconView.fb.webImageSource(element.image).response { result in
                            
                        }
                        
                        return cell
                        
            })
            
            viewModel.bind(tableView: self, dataSource: source)
            
            refresher.pullDown { refresher in
                viewModel.reload()
            }
            
        }
        
        class Cell: UITableViewCell {
            
            let iconView: UIImageView
            let titleLabel: UILabel
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                iconView = UIImageView()
                titleLabel = UILabel()
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                contentView.addSubview(iconView)
                iconView.snp.makeConstraints { (make) in
                    make.top.left.equalTo(14)
//                    make.centerX.equalTo(self.contentView)
                    make.width.height.equalTo(49)
                    make.bottom.equalTo(-14)
                }
                titleLabel.textColor = .darkText
//                titleLabel.textAlignment = .center
                titleLabel.numberOfLines = 0
                contentView.addSubview(titleLabel)
                titleLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(iconView)
                    make.left.equalTo(iconView.snp.right).offset(10)
                    make.right.equalTo(-14)
//                    make.left.equalTo(12)
                }
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
//                iconView.frame = CGRect(x: (bounds.width - 49.0)/2.0, y: 14.0, width: 49.0, height: 49.0)
//
//                titleLabel.frame = CGRect(x: 12, y: imageView.frame.maxY+10, width: bounds.width - 24, height: 18)
            }
        }
    }
    
    
}
