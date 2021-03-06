//
//  FunSheet.swift
//  FunBox
//
//  Created by 肖华 on 2019/10/15.
//

import UIKit


public typealias FunActionSheetHandler = (FunBox.Sheet.Action) -> Void
public typealias FunActionSheetMultiHandler = ([FunBox.Sheet.Action]) -> Void
public typealias FunSheet = FunBox.Sheet
public extension FunBox {
    static var sheet: Sheet {
        
        return Sheet.default
    }
    class Sheet {
        
        public static var `default`: Sheet {
            
            let sheet = Sheet()
            return sheet
        }
        
        // 事件的实际控制器
        public lazy var sheetController = FunBox.Sheet.Controller()
        // 事件集合
        private var _actions = [FunBox.Sheet.Action]()
        
        
        public init() {
            // 创建sheet时，初始化构建样式
            sheetController.config.contentInsets = UIEdgeInsets.init(top: 170, left: 0, bottom: 0, right: 0)
            sheetController.config.cornerRadius = 8
        }
        
        // 构建选择器
        public func build(_ selectType: FunBox.Sheet.Controller.Config.SelectType) -> FunBox.Sheet.Controller {
            let controller = FunBox.Sheet.Controller()
            
            controller.actions = _actions
            
            controller.config.selectType = selectType
            
            return controller
        }
        
        // 弹出方法
        public func present(sheetHandler a_sheetHandler: ((FunBox.Sheet.Controller)->Void)?=nil) {
            
            if let handler = a_sheetHandler {
                handler(sheetController)
            }
            
            sheetController.actions = _actions
            
            var rootViewController = UIApplication.shared.fb.currentWindow?.rootViewController
            if let presentedViewController = rootViewController?.presentedViewController {
                rootViewController = presentedViewController
            }
            let coverView = UIView.init(frame: UIScreen.main.bounds)
            coverView.backgroundColor = UIColor.init(white: 0, alpha: 0)
            
            rootViewController?.view.addSubview(coverView)
            UIView.animate(withDuration: 0.3) {
                coverView.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
            }
            
            DispatchQueue.main.async {
                
                rootViewController?.present(self.sheetController, animated: true) {
                    
                    self.sheetController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
                    coverView.removeFromSuperview()
                }
            }
            
        }
    }
}

// 快速构建的相关方法
public extension FunBox.Sheet {
    // 添加一个事件
    func addAction(_ action: FunSheetActionConvertible) -> Self {
        _actions.append(action.asAction())
        
        return self
    }
    
    // 添加一组事件
    func addActions(_ actions: [FunSheetActionConvertible]) -> Self {
        for action in actions {
            _actions.append(action.asAction())
        }
        
        return self
    }
    
    // 设置已勾选的结果
    func resultActions(_ actions: [FunSheetActionConvertible]?) -> Self {
        
        var result_actions = [FunBox.Sheet.Action]()
        if let actions = actions {
            for action in actions {
                result_actions.append(action.asAction())
            }
            sheetController.resultActions = result_actions
        }
        
        return self
    }
    
    // 设置头部提示标语
    func setHeaderTips(_ tips: String?) -> Self {

        sheetController.toolBar.titleLabel.text = tips
        
        return self
    }
    
    // 修改头部视图
    func setHeaderView(_ headerView: UIView) -> Self {
        
        sheetController.topView = headerView
        
        return self
    }
    
    // 单选的回调
    func handler(_ handler: @escaping FunActionSheetHandler) -> Self {
        sheetController.handler = handler
        return self
    }
    
    // 多选的回调
    func multiHandler(_ multiHandler: @escaping FunActionSheetMultiHandler) -> Self {
        sheetController.multiHandler = multiHandler
        return self
    }
    
    // 内边距
    func contentInsets(_ contentInsets: UIEdgeInsets) -> Self {
        sheetController.config.contentInsets = contentInsets
        return self
    }
    
    // 圆角
    func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        
        sheetController.config.cornerRadius = cornerRadius
        
        return self
    }
    
    // 设置单选、多选
    func selectType(_ selectType: FunBox.Sheet.Controller.Config.SelectType) -> Self {
        
        sheetController.config.selectType = selectType
        
        return self
    }
    
    // 设置主题颜色
    func tintColor(_ tintColor: UIColor) -> Self {
        
        sheetController.config.tintColor = tintColor
        
        return self
    }
    
    // 设置选中样式的icon
    func selectImage(_ selectImage: UIImage) -> Self {
        
        sheetController.config.selectImage = selectImage
        
        return self
    }
    
    // 未选中样式的icon
    func normalImage(_ normalImage: UIImage) -> Self {
        
        sheetController.config.normalImage = normalImage
        
        return self
    }
}




public extension FunBox.Sheet {
    
    class Controller: UIViewController,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource {
        // 配置
        public lazy var config = Config()
        // 单选回调
        public var handler: FunActionSheetHandler? {
            didSet {
                //                toolBar.isMultiSelector = false
                toolBar.isMultiple = false
            }
        }
        // 多选回调
        public var multiHandler: FunActionSheetMultiHandler? {
            didSet {
                // 多选样式时，设置按钮标题
                toolBar.isMultiple = true
            }
        }
        // 选择结果
        public lazy var resultActions = [FunBox.Sheet.Action]()
        private var resultValues: String?
        private var resultTitles: String?
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            
            modalTransitionStyle = .coverVertical
            modalPresentationStyle = .overFullScreen
            view.backgroundColor = UIColor.init(white: 0, alpha: 0)
        }
        
        
        lazy var toolBar: FunBox.Sheet.ToolBar = {
            let _toolBar = FunBox.Sheet.ToolBar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
            
            _toolBar.tintColor = self.config.tintColor
            _toolBar.backgroundColor = self.tableView.backgroundColor
            weak var weakSelf = self
            
            _toolBar.doneHandler {
                if let actions = weakSelf?.actions {
                    for action in actions {
                        if action.isSelected {
                            weakSelf?.resultActions.append(action)
                        }
                        
                    }
                    if let handler = weakSelf?.multiHandler, let result = weakSelf?.resultActions {
                        handler(result)
                    }
                }
                
                weakSelf?.dismiss(animated: true, completion: nil)
            }
            
            _toolBar.cancelHandler {
                weakSelf?.dismiss(animated: true, completion: nil)
            }
            
            return _toolBar
        }()
        
        public var actions: [FunBox.Sheet.Action]? {
            didSet {
                // 初始化actions
                guard let actions = actions else { return }
                var resultValues_array = self.resultValues?.components(separatedBy: ",") ?? [String]()
                var resultTitles_array = self.resultTitles?.components(separatedBy: ",") ?? [String]()
                
                if resultActions.count > 0 {
                    
                    for result_action in resultActions {
                        if let title = result_action.title {
                            resultTitles_array.append(title)
                        }
                        if let value = result_action.value {
                            resultValues_array.append(value)
                        }
                    }
                    
                    resultActions.removeAll()
                }
                
                for action in actions {
                    if let value = action.value, resultValues_array.contains(value) {
                        action.isSelected = true
                    } else if let title = action.title, resultTitles_array.contains(title) {
                        action.isSelected = true
                    }
                }
                
                tableView.reloadData()
                view.setNeedsLayout()
            }
        }
        
        
        open override func viewDidLoad() {
            super.viewDidLoad()
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapDismissAction(_:)))
            tapGes.delegate = self
            view.addGestureRecognizer(tapGes)
            
            topView = toolBar
        }
        
        open override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            let contentW = view.bounds.size.width - config.contentInsets.left - config.contentInsets.right
            let max_Height = view.bounds.size.height - config.contentInsets.top - config.contentInsets.bottom
            //            let min_Height = contentW
            let actionHeight: CGFloat = CGFloat(49 * (actions?.count ?? 0))
            let contentH = max(contentW, min(max_Height, actionHeight))
            
            let contentY = view.bounds.size.height - contentH - config.contentInsets.bottom
            
            var rect_topView = CGRect.zero
            var rect_tableView = CGRect.init(x: config.contentInsets.left, y: contentY, width: contentW, height: contentH)
            
            if config.position == .center {
                rect_tableView = CGRect.init(x: (view.bounds.size.width - contentW) / 2.0, y: (view.bounds.size.height - contentH) / 2.0, width: contentW, height: contentH)
                //                tableView.center = view.center
            }
            
            
            
            if let a_topView = topView {
                rect_topView = CGRect.init(x: config.contentInsets.left, y: rect_tableView.origin.y, width: contentW, height: a_topView.bounds.size.height)
                if a_topView == toolBar {
                    //                    a_topView.backgroundColor = .white
                    //                    if !toolBar.isMultiSelector, toolBar.tipLabel.text == nil {
                    //                        rect_topView = CGRect.init(x: config.contentInsets.left, y: rect_tableView.origin.y, width: contentW, height: 8)
                    //                        a_topView.backgroundColor = .clear
                    //                    }
                    //                    if multiHandler == nil, toolBar.tipLabel.text == nil { // 单选状态，并且没有标题时
                    if multiHandler == nil, toolBar.titleLabel.text == nil { // 单选状态，并且没有标题时
                        rect_topView = CGRect.init(x: config.contentInsets.left, y: rect_tableView.origin.y, width: contentW, height: max(8, config.cornerRadius ?? 0))
                        a_topView.backgroundColor = .clear
                    }
                }
                
                tableView.contentInset = UIEdgeInsets.init(top: rect_topView.size.height, left: 0, bottom: 0, right: 0)
                
            }
            
            //            UIView.animate(withDuration: 0.25, animations: {
            self.tableView.frame = rect_tableView
            if let a_topView = self.topView {
                a_topView.frame = rect_topView
            }
            //            }) { (complete) in
            
            //            }
            
            if let a_cornerRadius = config.cornerRadius {
                tableView.layer.cornerRadius = a_cornerRadius
                tableView.layer.masksToBounds = true
                if let a_topView = topView {
                    a_topView.layer.cornerRadius = a_cornerRadius
                    a_topView.layer.masksToBounds = true
                }
            }
            
        }
        
        
        @objc private func tapDismissAction(_ tapGes : UITapGestureRecognizer) {
            if FunBox.observer.keyboardShow {
                self.view.endEditing(true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            let rootViewController = UIApplication.shared.fb.currentWindow?.rootViewController
            let coverView = UIView.init(frame: UIScreen.main.bounds)
            coverView.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
            
            rootViewController?.view.addSubview(coverView)
            view.backgroundColor = UIColor.init(white: 0, alpha: 0)
            UIView.animate(withDuration: 0.3) {
                coverView.alpha = 0
            }
            super.dismiss(animated: flag) {
                coverView.removeFromSuperview()
            }
            
        }
        
        open var topView: UIView? {
            willSet {
                if topView == newValue {
                    
                    return
                }
                
                
                if let topView = topView {
                    
                    topView.frame = .zero
                    topView.removeFromSuperview()
                    
                }
                
                if let a_topView = newValue {
                    a_topView.frame = CGRect.init(x: config.contentInsets.left, y: config.contentInsets.top, width: tableView.frame.size.width, height: a_topView.bounds.size.height)
                    
                    view.addSubview(a_topView)
                    
                    tableView.scrollsToTop = true
                }
            }
            
        }
        
        private lazy var tableView: UITableView = {
            let _tableView = UITableView.init(frame: UIScreen.main.bounds, style: .plain)
            _tableView.delegate = self
            _tableView.dataSource = self
            _tableView.rowHeight = UITableView.automaticDimension
            _tableView.estimatedRowHeight = 49
            _tableView.separatorStyle = .none
            _tableView.register(ActionCell.self, forCellReuseIdentifier: ActionCell.reuseID)
            view.addSubview(_tableView)
            return _tableView
        }()
        
        
        // MARK: TapAction
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            print(NSStringFromClass((touch.view?.classForCoder)!))  // touch.view  就是你想要的对象
            
            if NSStringFromClass((touch.view?.classForCoder)!) == "UITableViewCellContentView" {
                return false
            } else if touch.view == self.topView {
                return false
            } else {
                return true
            }
        }
        
        
        // MARK: - DataSource
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if let actions = actions {
                
                
                return actions.count
            }
            return 0
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: ActionCell.reuseID) as! ActionCell
            if let action = actions?[indexPath.row] {
                action.index = indexPath.row
                cell.title = action.title
                cell.subTitle = action.subTitle
                
                if config.selectType == .multi {
                    cell.selectionStyle = .none
                }
                
                cell.selectedBackgroundView?.backgroundColor = config.tintColor
                cell.tintColor = config.tintColor
                
                cell.img_normal = config.normalImage
                cell.img_selected = config.selectImage
                cell.accessoryType = action.isSelected ? .checkmark : .none
                
            }
            return cell
        }
        
        public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if config.selectType == .single {
                // 单选模式
                
                if let action = self.actions?[indexPath.row] {
                    
                    if let actionHandler = self.handler {
                        // 直接给出回调
                        DispatchQueue.main.async {
                            actionHandler(action)
                        }
                        
                    }
                }
                
                dismiss(animated: true, completion: nil)
                
            } else if config.selectType == .multi {
                // 多选模式下
                if let action = actions?[indexPath.row] {
                    // 标记选中状态
                    if action.isSelected {
                        action.isSelected = false
                    } else {
                        action.isSelected = true
                    }
                    
                    if let cell = tableView.cellForRow(at: indexPath) as? ActionCell {
                        cell.accessoryType = action.isSelected ? .checkmark : .none
                    }
                }
            }
            
        }
        private class ActionCell: UITableViewCell {
            
            static let reuseID = "FunAction.ActionCell.ReuseID"
            var title: String? {
                didSet {
                    if let text = title {
                        textLabel?.text = text
                        
                    }
                    
                }
            }
            var subTitle: String? {
                didSet {
                    if let text = subTitle {
                        detailTextLabel?.text = text
                        
                    }
                    
                }
            }
            
            var img_selected: UIImage?
            var img_normal: UIImage?
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
                
                if #available(iOS 13.0, *) {
                    textLabel?.textColor = UIColor.label
                } else {
                    textLabel?.textColor = UIColor.darkText
                }
                textLabel?.font = UIFont.systemFont(ofSize: 15)
                textLabel?.numberOfLines = 0
                if #available(iOS 13.0, *) {
                    line.backgroundColor = UIColor.systemGray6.cgColor
                } else {
                    // Fallback on earlier versions
                    line.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1).cgColor
                }
                contentView.layer.addSublayer(line)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
            }
            
            var line = CALayer()
            override func draw(_ rect: CGRect) {
                super.draw(rect)
                
                line.frame = CGRect(x: 8, y: rect.size.height - 0.5, width: rect.size.width-8, height: 0.5)
            }
            
        }
        
    }
    
    
    
}

extension FunBox.Sheet {
    
    class ToolBar: UIToolbar {
        
        var isMultiple: Bool = false {
            didSet {
                if isMultiple {
                    items = [cancel_item,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),title_item,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),done_item]
                    
                } else {
                    items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),title_item,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
                }
            }
        }
        
        
        
        private lazy var cancel_item = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(sender:)))
        
        private lazy var done_item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(sender:)))
        
        lazy var titleLabel = UILabel()
        
        private lazy var title_item = UIBarButtonItem(customView: titleLabel)
        
        override var tintColor: UIColor! {
            didSet {
                titleLabel.textColor = tintColor
            }
        }
        public override init(frame: CGRect) {
            super.init(frame: frame)
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = tintColor
            titleLabel.textAlignment = .center
            
            items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),title_item,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
            
            
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func cancelAction(sender: UIBarButtonItem) {
            if let handler = cancelHandler {
                DispatchQueue.main.async {
                    
                    handler()
                }
            }
        }
        
        @objc func doneAction(sender: UIBarButtonItem) {
            if let handler = doneHandler {
                DispatchQueue.main.async {
                    
                    handler()
                }
            }
        }
        
        private var doneHandler: (()->Void)?
        public final func doneHandler(_ a_doneHandler: @escaping (()->Void)) {
            doneHandler = a_doneHandler
        }
        
        private var cancelHandler: (()->Void)?
        public final func cancelHandler(_ a_cancelHandler: @escaping (()->Void)) {
            cancelHandler = a_cancelHandler
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
        }
    }
    
}


public extension FunBox.Sheet.Controller {
    struct Config {
        
        // 选择器弹出位置
        public enum Position : Int {
            case `default`      // 默认靠底部
            
            case center         //居中显示
            
        }
        
        public enum SelectType: String {
            case single = "single"
            case multi = "multi"
        }
        
        // 内边距
        public var contentInsets: UIEdgeInsets = .zero
        // 圆角大小
        public var cornerRadius: CGFloat?
        // 显示位置
        public var position: FunBox.Sheet.Controller.Config.Position = .default
        // 多选还是单选
        public var selectType: FunBox.Sheet.Controller.Config.SelectType = .single
        // 主题颜色
        public var tintColor: UIColor = .systemBlue
        // 选中图片
        public var selectImage: UIImage?
        // 未选中图片
        public var normalImage: UIImage?
    }
}

// action的生成协议
public protocol FunSheetActionConvertible {
    
    func asAction() -> FunBox.Sheet.Action
}

// 可以直接用string去生成一个事件（只创建title）
extension String: FunSheetActionConvertible {
    
    public func asAction() -> FunBox.Sheet.Action {
        
        return FunBox.Sheet.Action(title: self, style: .default)
    }
    
}

public extension FunBox.Sheet {
    
    // 事件内容
    class Action: FunSheetActionConvertible {
        public func asAction() -> FunBox.Sheet.Action {
            
            return self
        }
        
        // 事件的类型
        public enum Style : Int {
            case `default`
            
            case cancel
            
            case destructive
        }
        // 值（唯一标示）
        public var value: String?
        // 标题
        public var title: String?
        // 副标题
        public var subTitle: String?
        // 是否选中
        public var isSelected: Bool = false
        // 类型
        public var style: Style = .default
        // 标号（行号）
        public var index: Int = 0
        // 构造方法
        public init(title a_title: String?, subTitle a_subTitle: String?=nil, value a_value: String?=nil, style a_style: Style? = .default) {
            
            self.title = a_title
            self.value = a_value
            self.style = a_style ?? .default
            self.subTitle = a_subTitle
        }
        
    }
}
