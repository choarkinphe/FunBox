//
//  UIView+Fun.swift
//  FunBox
//
//  Created by choarkinphe on 2020/8/25.
//

import UIKit
extension FunKey {
    struct TextField {
        static var contentRegular = "com.funbox.key.contentRegular"
        static var contentCount = "com.funbox.key.contentCount"
    }
}
extension FunBox.CacheKey {
    static let uuid = FunBox.CacheKey(rawValue: "uuid")
}

// MARK: - UIView
public extension FunNamespaceWrapper where T: UIView {
    var viewController: UIViewController? {
        for view in sequence(first: wrappedValue.superview, next: {$0?.superview}){
            
            if let responder = view?.next{
                
                if responder.isKind(of: UIViewController.self){
                    
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    
    func removeAllSubviews<T>(type: T.Type?=nil) where T: UIView {
        wrappedValue.subviews.forEach { (item) in
            if type != nil {
                if item is T {
                    item.removeFromSuperview()
                }
            } else {
                item.removeFromSuperview()
            }
        }
    }
    
    var firstResponder: UIView? {
        guard !wrappedValue.isFirstResponder else { return wrappedValue }
        for subview in wrappedValue.subviews {
            if let firstResponder = subview.fb.firstResponder {
                return firstResponder
            }
        }
        return nil
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
    // 屏幕尺寸
    static var size: CGSize {
        return UIScreen.main.bounds.size
    }
    // 是否全面屏
    static var isInfinity: Bool {
        return UIDevice.current.fb.isInfinity
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
fileprivate var imageCache: NSCache<UIColor, UIImage>!
public extension FunNamespaceWrapper where T: UIImage {
    static func size(url: FunURLConvertable?) -> CGSize {
        guard let tempUrl = url?.realURL,
              let imageSourceRef = CGImageSourceCreateWithURL(tempUrl as CFURL, nil),
              let imageP = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) else {
                
                return .zero
        }
        
        let imageDict = imageP as Dictionary

        let width = imageDict[kCGImagePropertyPixelWidth] as? CGFloat ?? 0
            
        let height = imageDict[kCGImagePropertyPixelHeight] as? CGFloat ?? 0
     
        return CGSize(width: width, height: height)
    }
    
    static var appIcon: UIImage? {
        
        if let infoPlist = Bundle.main.infoDictionary,
            let icons = infoPlist["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let files = primaryIcon["CFBundleIconFiles"] as? [String],
            let name = files.first {
                
            return UIImage(named: name)
                
        }
        
        return nil
    }
    
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
    
    static func color(_ color: UIColor, size: CGSize?=nil) -> UIImage {
        DispatchQueue.fb.once {
            imageCache = NSCache()
        }

        if let image = imageCache.object(forKey: color) {
            return image
        }
        
        let image_size = size ?? CGSize(width: 1, height: 1)
        let rect = CGRect(x: 0, y: 0, width: image_size.width, height: image_size.height)
        UIGraphicsBeginImageContext(image_size)

        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)

        context?.fill(rect)
                
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        imageCache.setObject(image, forKey: color)
        
        return image
    }
    
    static func color(_ color: UIColor, toColor: UIColor, size: CGSize?=nil) -> UIImage? {
        let contentView = UIView(frame: CGRect(origin: .zero, size: size ?? UIScreen.main.bounds.size))
        
        contentView.fb.effect(.gradientColor).gradientColors([color,toColor]).draw()
        
        return contentView.fb.snapshot

    }
    
    static func QRCodeImage(content: String?, size: CGSize?=nil) -> UIImage? {
        guard let stringData = content?.data(using: String.Encoding.utf8) else { return nil }
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setDefaults()
        colorFilter?.setValuesForKeys(["inputImage" : (qrFilter?.outputImage)!,"inputColor0":CIColor.init(cgColor: UIColor.black.cgColor),"inputColor1":CIColor.init(cgColor: UIColor.white.cgColor)])
        
        let qrImage = colorFilter?.outputImage
        let cgImage = CIContext(options: nil).createCGImage(qrImage!, from: (qrImage?.extent)!)
        
        UIGraphicsBeginImageContext(size ?? CGSize(width: 1024, height: 1024))
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = .none
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(cgImage!, in: (context?.boundingBoxOfClipPath)!)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return codeImage
    }

//
//    static func QRCodeImage(content: String?, size: CGSize?=nil) -> UIImage? {
//        guard let stringData = content?.data(using: String.Encoding.utf8) else { return nil }
//
//        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
//        qrFilter?.setValue(stringData, forKey: "inputMessage")
//        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
//
//        let colorFilter = CIFilter(name: "CIFalseColor")
//        colorFilter?.setDefaults()
//        colorFilter?.setValuesForKeys(["inputImage" : (qrFilter?.outputImage)!,"inputColor0":CIColor.init(cgColor: UIColor.black.cgColor),"inputColor1":CIColor.init(cgColor: UIColor.white.cgColor)])
//
//        let qrImage = colorFilter?.outputImage
//        let cgImage = CIContext(options: nil).createCGImage(qrImage!, from: (qrImage?.extent)!)
//
//        UIGraphicsBeginImageContext(size ?? CGSize(width: 1024, height: 1024))
//        let context = UIGraphicsGetCurrentContext()
//        context?.interpolationQuality = .none
//        context?.scaleBy(x: 1.0, y: -1.0)
//        context?.draw(cgImage!, in: (context?.boundingBoxOfClipPath)!)
//        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return codeImage
//    }
    
    /**
    *  修正图片信息
    *
    *  aImage 待修正的图片
    *
    *  @return 已修正的图片
    *
    *  @note 用相机拍摄出来的照片含有EXIF信息，UIImage的imageOrientation属性指的就是EXIF中的orientation信息。
    *  如果我们忽略orientation信息，而直接对照片进行像素处理或者drawInRect等操作，得到的结果是翻转或者旋转90之后
    *  的样子。这是因为我们执行像素处理或者drawInRect等操作之后，imageOrientaion信息被删除了，imageOrientaion
    *  被重设为0，造成照片内容和imageOrientaion不匹配。所以，在对照片进行处理之前，先将照片旋转到正确的方向，并且
    *  返回的imageOrientaion为0。
    */
    
    var fixOrientation: UIImage {
        if wrappedValue.imageOrientation == .up {
            return wrappedValue
        }
        
        var transform = CGAffineTransform.identity
        
        switch wrappedValue.imageOrientation {
        case .down,.downMirrored:
            transform = transform.translatedBy(x: wrappedValue.size.width, y: wrappedValue.size.height)
            transform = transform.rotated(by: .pi)
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: wrappedValue.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: wrappedValue.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
            
        default:
            break
        }
        
        switch wrappedValue.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: wrappedValue.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: wrappedValue.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(wrappedValue.size.width), height: Int(wrappedValue.size.height), bitsPerComponent: wrappedValue.cgImage!.bitsPerComponent, bytesPerRow: 0, space: wrappedValue.cgImage!.colorSpace!, bitmapInfo: wrappedValue.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch wrappedValue.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(wrappedValue.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(wrappedValue.size.height), height: CGFloat(wrappedValue.size.width)))
            break
             
        default:
            ctx?.draw(wrappedValue.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(wrappedValue.size.width), height: CGFloat(wrappedValue.size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!

        
        return UIImage(cgImage: cgimg)
    }
    
    func scale(_ toSize: CGSize) -> UIImage? {
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(toSize)
        // 绘制改变大小的图片
        wrappedValue.draw(in: CGRect(origin: .zero, size: toSize))
        // 从当前context中创建一个改变大小后的图片
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        // 使当前的context出堆栈
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func encode(to encoder: FunEncoder = .base64) -> String? {
        guard let data = wrappedValue.jpegData(compressionQuality: 1) else { return nil }
        switch encoder {
            case .base64:
                return data.fb.base64String
            default:
                return nil
        }
    }

}
// MARK: - UIColor+Fun
public protocol Colourful {
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat)? { get }
}
extension String: Colourful {
    public var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        
        var hex = self.hasPrefix("#")
          ? String(self.dropFirst())
          : self
        guard hex.count == 3 || hex.count == 6
          else {
            return (1,1,1)
        }
        if hex.count == 3 {
          for (index, char) in hex.enumerated() {
            hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
          }
        }
        
        guard let intCode = Int(hex, radix: 16) else {
            return (1,1,1)
        }
          let red = CGFloat((intCode >> 16) & 0xFF) / 255.0
          let green = CGFloat((intCode >> 8) & 0xFF) / 255.0
          let blue = CGFloat((intCode) & 0xFF) / 255.0
        
        return (red,green,blue)
        
    }
}

fileprivate typealias Ints = [Int]
extension Ints: Colourful {
    public var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        if self.count >= 3 {
            let red = CGFloat(self[0]) / 255.0
            let green = CGFloat(self[1]) / 255.0
            let blue = CGFloat(self[2]) / 255.0

            return (red,green,blue)
        }
        
        return (1,1,1)
    }
}
public extension FunNamespaceWrapper where T: UIColor {
    static var random: UIColor {
        let red = CGFloat(arc4random_uniform(255))/255.0
        let green = CGFloat(arc4random_uniform(255))/255.0
        let blue = CGFloat(arc4random_uniform(255))/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    static func random(alpha: CGFloat) -> UIColor {
        let red = CGFloat(arc4random_uniform(255))/255.0
        let green = CGFloat(arc4random_uniform(255))/255.0
        let blue = CGFloat(arc4random_uniform(255))/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func RGB(_ element: Colourful, alpha: CGFloat=1) -> UIColor {
        
        guard let rgb = element.rgb else { return UIColor(white: 1, alpha: 0) }
        return UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: alpha)
    }
        
    /// Get color rgba components in order.
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let components = wrappedValue.cgColor.components
        let numberOfComponents = wrappedValue.cgColor.numberOfComponents
        
        switch numberOfComponents {
        case 4:
            return (components![0], components![1], components![2], components![3])
        case 2:
            return (components![0], components![0], components![0], components![1])
        default:
            // FIXME: Fallback to black
            return (0, 0, 0, 1)
        }
    }
    
    /// Check the black or white contrast on given color.
    var contrasting: UIColor {
        let rgbaT = rgba
        let value = 1 - ((0.299 * rgbaT.red) + (0.587 * rgbaT.green) + (0.114 * rgbaT.blue));
        return value < 0.5 ? UIColor.black : UIColor.white
    }
    
    var light: UIColor {
        let rgbaT = rgba
        let value = 1 - ((0.299 * rgbaT.red) + (0.587 * rgbaT.green) + (0.114 * rgbaT.blue));
        return value < 0.5 ? UIColor(white: 0.25, alpha: 1) : UIColor(white: 0.75, alpha: 1)
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
    
    func set(lineSpacing: CGFloat) {
        guard let text = wrappedValue.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = wrappedValue.lineBreakMode
        paragraphStyle.alignment = wrappedValue.textAlignment
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.setAttributes([.paragraphStyle:paragraphStyle], range: NSRange(location: 0, length: text.count))
        
        wrappedValue.attributedText = attributedString
    }
    
}
public extension FunNamespaceWrapper where T: UIView {
    
    var snapshot: UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(wrappedValue.bounds.size, wrappedValue.isOpaque, 0)
        
        if let context = UIGraphicsGetCurrentContext() {
            
            wrappedValue.layer.render(in: context)
            
            let snap = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return snap
        }
        
        
        return nil
        
    }
    
    var controller: UIViewController? {
        
        return find(wrappedValue)
    }
    
    private func find(_ responder: UIResponder?) -> UIViewController {
        if let responder = responder as? UIViewController {
            return responder
        }
        return find(responder?.next)
    }

}

// MARK: - UITextField+Fun
public extension FunNamespaceWrapper where T: UITextField {
    
    var contentCount: Int {
        
        if let count = objc_getAssociatedObject(wrappedValue, &FunKey.TextField.contentCount) as? Int {
            return count
        }
        
        return 0
    }
    
    func set(contentCount: Int) {
        objc_setAssociatedObject(wrappedValue, &FunKey.TextField.contentCount, contentCount, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        
        wrappedValue.addTarget(wrappedValue, action: #selector(wrappedValue.inputCountMonitor(textField:)), for: .editingChanged)
        
    }
    
    var contentRegular: String? {

        return objc_getAssociatedObject(wrappedValue, &FunKey.TextField.contentRegular) as? String
    }
    
    func set(contentRegular: String?) {
        objc_setAssociatedObject(wrappedValue, &FunKey.TextField.contentRegular, contentRegular, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        wrappedValue.addTarget(wrappedValue, action: #selector(wrappedValue.inputRegularMonitor(textField:)), for: .editingChanged)
        
    }
    
    
}

fileprivate extension UITextField {
    @objc func inputCountMonitor(textField: UITextField) {

        if textField.fb.contentCount > 0, let inputText = textField.text {
            if inputText.count > textField.fb.contentCount {
                text = inputText.fb.subString(to: textField.fb.contentCount)
            }
        }
        
    }
    
    @objc func inputRegularMonitor(textField: UITextField) {
        if let inputText = textField.text, let regular = textField.fb.contentRegular {
            do {

                let regex = try NSRegularExpression.init(pattern: regular, options: .dotMatchesLineSeparators)

                let newText = regex.stringByReplacingMatches(in: inputText, options: .reportCompletion, range: NSRange(location: 0, length: inputText.count), withTemplate: "")
                
                if let selRange = textField.selectedTextRange {
                    
                    let idx = textField.offset(from: textField.beginningOfDocument, to: selRange.start)
                    let offset = newText.count - inputText.count
                    
                    if offset >= 0 {
                        return
                    }
                    
                    text = newText
                    
                    let newStart = (idx + offset) < 0 ? 0 : (idx + offset)

                    if let start = textField.position(from: beginningOfDocument, offset: newStart),
                        let end = textField.position(from: beginningOfDocument, offset: newStart) {
                    
                        textField.selectedTextRange = textField.textRange(from: start, to: end)
                    }
                }

            }
            catch {

                print(error.localizedDescription)
                
            }
        }
    }
}

// MARK: - UIDevice
public extension FunNamespaceWrapper where T: UIDevice {
    
    // 获取系统版本
    var systemVersion: Float {
        
        return UIDevice.current.systemVersion.fb.floatValue ?? 10.0
    }
    
    // 获取uuid（自动缓存，除非重新安装APP或者超过300天<缓存有效期>）
    var uuid: String {

        if let data = FunBox.cachePool.load(key: .uuid), let uuid = String(data: data, encoding: .utf8) {
            return uuid
        } else {

            let uuid = UUID().uuidString

            FunBox.cachePool.cache(key: .uuid, data: uuid.data(using: .utf8))

            return uuid
        }

    }
    
    // 判断设备是否为iPhoneX 系列
    @available(*, deprecated, message: "use isInfinity instand of it")
    var iPhoneXSeries: Bool {
        return isInfinity
    }
    
    // 是否全面屏
    var isInfinity: Bool {
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
// MARK: - UIApplication
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
    
    // 可否push
    var canPush: Bool {
        return frontController?.navigationController != nil
    }
    
    // 获取当前控制器
    var frontController: UIViewController? {
        
        guard let rootViewController = UIApplication.shared.fb.currentWindow?.rootViewController else {
            return nil
            
        }
        
        return findFrontViewController(rootViewController)
    }
    // 获取工程名
    var projectName: String? {

        return Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
    }
    // 获取 bundle version版本号

    var version: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    // 获取build版本
    var build: String? {
        let info = Bundle.main.infoDictionary
        
        return info?["CFBundleVersion"] as? String
    }
    
    // 获取BundleID
    var bundleID: String?{
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    }

    // 获取app的名字
    var appName: String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
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

extension UIEdgeInsets: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == UIEdgeInsets {
    func contect(_ inset: UIEdgeInsets) -> UIEdgeInsets {
        var new = wrappedValue
        new.top += inset.top
        new.left += inset.left
        new.bottom += inset.bottom
        new.right += inset.bottom
        return new
    }
    
    var horizontalValue: CGFloat {
        return wrappedValue.left + wrappedValue.right
    }
    
    var verticalValue: CGFloat {
        return wrappedValue.top + wrappedValue.bottom
    }
}

