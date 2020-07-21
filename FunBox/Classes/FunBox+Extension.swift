//
//  FunBox+Extension.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/13.
//

import UIKit
import CommonCrypto

// MARK: - NSObject

fileprivate struct FunKey {
    static var identifier = "com.funbox.key.objectIdentifier"
    static var observer = "com.funbox.key.observer"
    struct TextField {
        static var contentRegular = "com.funbox.key.contentRegular"
        static var contentCount = "com.funbox.key.contentCount"
    }
    
}
extension NSObject: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: NSObject {
    var identifier: String? {

        return objc_getAssociatedObject(wrappedValue, &FunKey.identifier) as? String
    }
    
    func set(identifier: String?) {
        objc_setAssociatedObject(wrappedValue, &FunKey.identifier, identifier, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    var observer: FunBox.Observer {
        if let observer = objc_getAssociatedObject(wrappedValue, &FunKey.observer) as? FunBox.Observer {
            return observer
        }
        
        let observer = FunBox.Observer()
        
        objc_setAssociatedObject(wrappedValue, &FunKey.observer, observer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return observer
    }
}

// MARK: - UIBarButtonItem
//extension UIBarButtonItem: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T: UIBarButtonItem {
    static var spaceItem: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
}

public extension FunNamespaceWrapper where T: UIScrollView {
    var refresher: FunBox.Refresher {
        let refresher = FunBox.Refresher()
        wrappedValue.refreshControl = refresher
        return refresher
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
    static func json<T>(fileName: String?, type: T.Type) -> T? {
        guard var fileName = fileName else { return nil }
        if ![".JSON",".json",",Json"].contains(fileName.fb.subString(from: fileName.count - 5)) {
            fileName = fileName + ".JSON"
        }
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else { return nil }
        let url = URL(fileURLWithPath: path)
        
        do {
            
            let data = try Data(contentsOf: url)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            if let json = jsonData as? T {
                
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
    
    func underline(text: String?=nil, color: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: wrappedValue)
        var ns_range = NSRange(location: 0, length: wrappedValue.count)
        if let text = text, let range = wrappedValue.range(of: text) {
            ns_range = wrappedValue.fb.toNSRange(range)
        }
        
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: ns_range)
        attributedString.addAttribute(.underlineColor, value: color, range: ns_range)
        
//        var attributedString = NSAttributedString(string: wrappedValue, attributes:[NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single, NSAttributedString.Key.underlineColor: color], range: NSRange(location: 0, length: wrappedValue.count))
        return attributedString
//        return NSAttributedString(string: wrappedValue, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single,
//                                                                     NSAttributedString.Key.underlineColor: color])
    }
    
    func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: wrappedValue.utf16), let to = range.upperBound.samePosition(in: wrappedValue.utf16) else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(wrappedValue.utf16.distance(from: wrappedValue.utf16.startIndex, to: from), wrappedValue.utf16.distance(from: from, to: to))
    }
    
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = wrappedValue.utf16.index(wrappedValue.utf16.startIndex, offsetBy: range.location, limitedBy: wrappedValue.utf16.endIndex) else { return nil }
        guard let to16 = wrappedValue.utf16.index(from16, offsetBy: range.length, limitedBy: wrappedValue.utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: wrappedValue) else { return nil }
        guard let to = String.Index(to16, within: wrappedValue) else { return nil }
        return from ..< to
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
    
}
// MARK: - UIColor+Fun
public protocol Colourful {
    var rgb: (r:CGFloat,g:CGFloat,b:CGFloat)? { get }
}
extension String: Colourful {
    public var rgb: (r: CGFloat, g: CGFloat, b: CGFloat)? {
        
        var hex = self.hasPrefix("#")
          ? String(self.dropFirst())
          : self
        guard hex.count == 3 || hex.count == 6
          else {
//            self.init(white: 1.0, alpha: 0.0)
            return (1,1,1)
        }
        if hex.count == 3 {
          for (index, char) in hex.enumerated() {
            hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
          }
        }
        
        guard let intCode = Int(hex, radix: 16) else {
//          self.init(white: 1.0, alpha: 0.0)
//          return
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
    public var rgb: (r: CGFloat, g: CGFloat, b: CGFloat)? {
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
    
    static func RGB(_ element: Colourful, alpha: CGFloat?=nil) -> UIColor {
        
        guard let rgb = element.rgb else { return UIColor(white: 1, alpha: 0) }
        return UIColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: alpha ?? 1)
    }
    
//    func alpha(_ a_aplha: CGFloat) -> UIColor {
//        if let components = wrappedValue.cgColor.components {
//            let color = UIColor.init(red: components[0], green: components[1], blue: components[2], alpha: a_aplha)
//            return color
//        }
        
//        return wrappedValue.withAlphaComponent(a_aplha)
//    }

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
public extension FunNamespaceWrapper where T: UIView {
    func effect(_ style: FunBox.Effect.Style) -> FunBox.Effect {
        return FunBox.Effect.default.target(wrappedValue).style(style)
    }
    
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
        return frontController?.navigationController != nil
    }
    
    // 获取当前控制器
    var frontController: UIViewController? {
        
        guard let rootViewController = UIApplication.shared.fb.currentWindow?.rootViewController else {
            return nil
            
        }
        
        return findFrontViewController(rootViewController)
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



