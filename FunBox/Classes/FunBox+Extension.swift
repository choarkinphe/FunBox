//
//  FunBox+Extension.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/13.
//

import UIKit
import CommonCrypto

// MARK: - NSObject
fileprivate var objectIdentifierKey = "com.funbox.objectIdentifierKey"
extension NSObject: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: NSObject {
    var identifier: String? {

        return objc_getAssociatedObject(self, &objectIdentifierKey) as? String
    }
    
    func set(identifier: String?) {
        objc_setAssociatedObject(self, &objectIdentifierKey, identifier, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
}

// MARK: - UIBarButtonItem
//extension UIBarButtonItem: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: UIBarButtonItem {
    static var spaceItem: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
}

// MARK: - UIScreen
//extension UIScreen: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: UIScreen {
    static var size: CGSize {
        return UIScreen.main.bounds.size
    }
}

// MARK: - GCD
//extension DispatchQueue: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == DispatchQueue {
    private static var _onceTracker = [String]()
    
    static func once(file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           block: () -> Void) {
        let token = "\(file):\(function):\(line)"
        once(token: token, block: block)
    }
    
    static func once(token: String,
                           block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard !_onceTracker.contains(token) else { return }
        
        _onceTracker.append(token)
        block()
    }
}

// MARK: - JSON
//extension JSONSerialization: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == JSONSerialization {
    static func json(fileName: String?) -> [String: Any]? {
        guard var fileName = fileName else { return nil }
        if ![".JSON",".json",",Json"].contains(fileName.fb.subString(from: fileName.count - 5)) {
            fileName = fileName + ".JSON"
        }
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else { return nil }
        let url = URL(fileURLWithPath: path)
        
        do {
            
            let data = try Data(contentsOf: url)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            if let json = jsonData as? [String: Any] {
                
                return json
            }
        }
        catch {
            print("读取本地数据出现错误!",error.localizedDescription)
        }
        
        return nil
    }
    
}

// MARK: - TableView+Fun
//extension UITableView: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == UITableView {
    func dequeueCell<T>(_ type: T.Type, reuseIdentifier: String) -> T where T: UITableViewCell {
        
        guard let cell = wrappedValue.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
            
            return T.init(style: .default, reuseIdentifier: reuseIdentifier)
            
        }
        
        return cell as! T
    }
    
    func dequeueHeaderFooterView<T>(_ type: T.Type, reuseIdentifier: String) -> T where T: UITableViewHeaderFooterView {
        
        guard let headerFooterView = wrappedValue.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) else {
            
            return T.init(reuseIdentifier: reuseIdentifier)
            
        }
        
        return headerFooterView as! T
    }
    
}

// MARK: - TableViewCell+Fun
//extension UITableViewCell: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == UITableViewCell {
    var tableView: UITableView? {
        for view in sequence(first: wrappedValue.superview, next: { $0?.superview }) {
            if let tableView = view as? UITableView {
                return tableView
            }
        }
        
        return nil
    }
}

// MARK: - String+Fun
extension String: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == String {
    
    var intValue: Int? {
        let string = wrappedValue.trimmingCharacters(in: .whitespaces)
        let scan: Scanner = Scanner(string: string)
        
        var val: Int64 = 0
        
        if scan.scanInt64(&val) && scan.isAtEnd {
            return Int(string)
        }
        
        return nil
    }
    
    var floatValue: Float? {
        let string = wrappedValue.trimmingCharacters(in: .whitespaces)
        let scan: Scanner = Scanner(string: string)
        
        var val: Float = 0.0
        
        if scan.scanFloat(&val) && scan.isAtEnd {
            return Float(string)
        }
        
        return nil
        
    }
    
    var doubleValue: Double? {
        let string = wrappedValue.trimmingCharacters(in: .whitespaces)
        let scan: Scanner = Scanner(string: string)
        
        var val: Double = 0.0
        
        if scan.scanDouble(&val) && scan.isAtEnd {
            return Double(string)
        }
        
        return nil
    }
    
    //MARK:- 去除字符串两端的空白字符
    var trimString: String {
        return wrappedValue.trimmingCharacters(in: .whitespaces)
    }
    


    //MARK:- 截取到任意位置
    func subString(to: Int) -> String? {
        if to < 0 {
            return nil
        }
        var to = to
        if to > wrappedValue.count {
            to = wrappedValue.count
        }
        return String(wrappedValue.prefix(to))
    }
    
    //MARK:- 从任意位置开始截取
    func subString(from: Int) -> String? {
        if from < 0 {
            return nil
        }
        if from >= wrappedValue.count {
            return nil
        }
        let startIndex = wrappedValue.index(wrappedValue.startIndex, offsetBy: from)
        let endIndex = wrappedValue.endIndex
        return String(wrappedValue[startIndex..<endIndex])
    }
    
    //MARK:- 从任意位置截取到任意位置
    func subString(from: Int, to: Int) -> String? {
        if from < 0 {
            return nil
        }
        if to < 0 {
            return nil
        }
        if from >= wrappedValue.count {
            return nil
        }
        var to = to
        if to > wrappedValue.count {
            to = wrappedValue.count
        }
        if from < to {
            let startIndex = wrappedValue.index(wrappedValue.startIndex, offsetBy: from)
            let endIndex = wrappedValue.index(wrappedValue.startIndex, offsetBy: to)
            
            return String(wrappedValue[startIndex..<endIndex])
        }
        return ""
    }
    
    var md5: String {
        
        let utf8 = wrappedValue.cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1)
            
        }
    }
    
    func textSize(font: UIFont, maxWidth: CGFloat) -> CGSize {
        return wrappedValue.boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
    }
    
    var localized: String {
        return NSLocalizedString(wrappedValue, tableName: nil, bundle: .main, value: "", comment: "")
    }
}

// MARK: - AttributedString+Fun
//extension NSAttributedString: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: NSAttributedString {
    
    func attributedSize(maxWidth: CGFloat) -> CGSize {
        
        let rect = wrappedValue.boundingRect(with: CGSize.init(width: maxWidth, height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], context: nil)
        
        return rect.size
    }
    
}

// MARK: - Data+Fun
extension Data: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == Data {
    
    var hexString: String {
        var t = ""
        let ts = [UInt8](wrappedValue)
        for one in ts {
            t.append(String.init(format: "%02x", one))
        }
        return t
    }
    
    /// Data to base64 String
    var base64String: String {
        return wrappedValue.base64EncodedString(options: NSData.Base64EncodingOptions())
    }
    
    /// Array of UInt8
    var arrayOfBytes: [UInt8] {
//    public func arrayOfBytes() -> [UInt8] {
        let count = wrappedValue.count / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        (wrappedValue as NSData).getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        return bytesArray
    }

}

// MARK: - CGRect+Fun
extension CGSize {
    init(string: String?) {
        self.init()
        
        let characterSet = CharacterSet(charactersIn: " {}")
        if let size_string = string?.trimmingCharacters(in: characterSet) {
            let array = size_string.components(separatedBy: ",")

            self.width = CGFloat(array.first?.fb.doubleValue ?? 0)
            self.height = CGFloat(array.last?.fb.doubleValue ?? 0)
        }
        
    }
    
    
}

// MARK: - UIImage+Fun
//extension UIImage: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: UIImage {
    static var launchImage: UIImage? {
        let viewSize = UIScreen.main.bounds.size
        var viewOrientation = "Portrait"
        let orientation = UIApplication.shared.statusBarOrientation
        if [.landscapeRight,.landscapeLeft].contains(orientation) {
            viewOrientation = "Landscape"
        }
        
        if let images = Bundle.main.infoDictionary?["UILaunchImages"] as? [Any] {
            print(images)
            for element in images {
                if let dict = element as? [String: String] {
                    
                    let imageSize = CGSize.init(string: dict["UILaunchImageSize"])
                    
                    if viewSize.equalTo(imageSize), viewOrientation == dict["UILaunchImageOrientation"] {
                        if let imageName = dict["UILaunchImageName"] {
                            return UIImage(named: imageName)
                        }
                        
                    }
                }
                
            }
            
        } else {
            
            
        }
        
        return nil
    }
}

// MARK: - UIButton+Fun
//extension UIButton: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: UIButton {
    
    var fitSize: CGSize {
        
        var size = CGSize.zero
        
        if let image = wrappedValue.imageView?.image {
            size = image.size
        }

        if let titleLabel = wrappedValue.titleLabel {
            
            size.width = size.width + titleLabel.fb.fitSize.width + 8
            
            size.height = max(size.height, titleLabel.fb.fitSize.height) + 8
        }

        return size
        
    }
    
}

// MARK: - UILabel+Fun
//extension UILabel: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: UILabel {
    var fitSize: CGSize {
        if let attributedText = wrappedValue.attributedText {
            return attributedText.fb.attributedSize(maxWidth: UIScreen.main.bounds.size.width)
            
            
            
        } else if let text = wrappedValue.text {
            
            return text.fb.textSize(font: wrappedValue.font, maxWidth: UIScreen.main.bounds.size.width)
            
        }
        
        return .zero
    }
    
    
}

//extension UIDevice: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: UIDevice {
    var systemVersion: Float {
        
        return UIDevice.current.systemVersion.fb.floatValue ?? 10.0
    }
    
    var iPhoneXSeries: Bool {
        if #available(iOS 11.0, *) {
            if UIDevice.current.userInterfaceIdiom == .phone {
                
                if let mainWindow = UIApplication.shared.fb.currentWindow {
                    
                    if mainWindow.safeAreaInsets.bottom > CGFloat(0.0) {
                        
                        return true
                    }
                }
                
            }
            
        }
        return false
    }
}

//extension UIApplication: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: UIApplication {

    // 获取当前的window
    var currentWindow: UIWindow? {
        
        if let window = UIApplication.shared.keyWindow {
            return window
        }
        
        if #available(iOS 13.0, *) {

            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                
                if windowScene.activationState == .foregroundActive {
                    
                    return windowScene.windows.first
                    
                }
                
            }

        }
        
        return nil
        
    }
    
    var canPush: Bool {
        return frontController.navigationController != nil
    }
    
    // 获取当前控制器
    var frontController: UIViewController {
        
        let rootViewController = UIApplication.shared.fb.currentWindow?.rootViewController
        
        return findFrontViewController(rootViewController!)
    }
    
    var projectName: String? {

        return Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
    }
    
    private func findFrontViewController(_ currnet: UIViewController) -> UIViewController {
        
        if let presentedController = currnet.presentedViewController {
            
            return findFrontViewController(presentedController)
            
        } else if let svc = currnet as? UISplitViewController, let next = svc.viewControllers.last {
            
            
            return findFrontViewController(next)
            
        } else if let nvc = currnet as? UINavigationController, let next = nvc.topViewController {
            
            return findFrontViewController(next)
            
        } else if let tvc = currnet as? UITabBarController, let next = tvc.selectedViewController {
            
            
            return findFrontViewController(next)
            
            
        } else if currnet.children.count > 0 {
            
            for child in currnet.children {
                
                if currnet.view.subviews.contains(child.view) {
                    
                    return findFrontViewController(child)
                }
            }
            
        }
        
        return currnet
        
    }
    
}



