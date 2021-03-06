//
//  FunBox+Extension.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/13.
//

import UIKit
import CommonCrypto
import MobileCoreServices
// MARK: - NSObject

typealias FunKey = FunBox.ObjectKey
extension FunBox {
    struct ObjectKey {
        static var identifier = "com.funbox.key.objectIdentifier"
        static var observer = "com.funbox.key.observer"
    }
}

public protocol DateFormatterable {
    func asFormatter() -> DateFormatter
}

extension DateFormatter: DateFormatterable {
    public func asFormatter() -> DateFormatter {
        return self
    }
}

extension String: DateFormatterable  {
    public func asFormatter() -> DateFormatter {
        let fomatter = DateFormatter()
        fomatter.dateFormat = self
        return fomatter
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
    
    var address: String? {
        return String(format: "%p", wrappedValue)
    }
    
//    var observer: FunBox.Observer {
//        if let observer = objc_getAssociatedObject(wrappedValue, &FunKey.observer) as? FunBox.Observer {
//            return observer
//        }
//        
//        let observer = FunBox.Observer()
//        
//        objc_setAssociatedObject(wrappedValue, &FunKey.observer, observer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        
//        return observer
//    }
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

        return json(filePath: Bundle.main.path(forResource: fileName, ofType: nil), type: type)
    }
    
    static func json<T>(filePath: String?, type: T.Type) -> T? {
        
        guard let path = filePath else { return nil }
        let url = URL(fileURLWithPath: path)
        
        do {
            
            let data = try Data(contentsOf: url)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            if let json = jsonData as? T {
                
                return json
            }
        }
        catch {
            print("FunBox: load local file error!",error.localizedDescription)
        }
        
        return nil
    }
    
    static func decode<T>(fileName: String?, type: T.Type) -> T? where T: Codable {
        guard var fileName = fileName else { return nil }
        if ![".JSON",".json",",Json"].contains(fileName.fb.subString(from: fileName.count - 5)) {
            fileName = fileName + ".JSON"
        }

        return decode(filePath: Bundle.main.path(forResource: fileName, ofType: nil), type: type)
    }
    
    static func decode<T>(filePath: String?, type: T.Type) -> T? where T: Codable {
        
        guard let path = filePath else { return nil }
        let url = URL(fileURLWithPath: path)
        
        do {
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(T.self, from: data)
            
            return jsonData
        }
        catch {
            print("FunBox: load local file error!",error.localizedDescription)
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
    
    //MARK:- remove trim
    var trimString: String {
        return wrappedValue.trimmingCharacters(in: .whitespaces)
    }
    

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
        
        if let utf8 = wrappedValue.cString(using: .utf8), !utf8.isEmpty {
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(utf8, CC_LONG(utf8.count - 1), &digest)
            return digest.reduce("") { $0 + String(format:"%02X", $1)
                
            }
        }
        return wrappedValue
    }
    
    func textSize(font: UIFont, maxWidth: CGFloat) -> CGSize {
        return wrappedValue.boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
    }
    
//    var localized: String {
//        return NSLocalizedString(wrappedValue, tableName: nil, bundle: .main, value: "", comment: "")
//    }
    func localized(in bundle: Bundle? = nil, table: String? = nil) -> String {
        return NSLocalizedString(wrappedValue, tableName: table ?? "Localization", bundle: bundle ?? .main, value: "", comment: "")
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
    
    func date(fomatter: DateFormatterable) -> Date? {
        return fomatter.asFormatter().date(from: wrappedValue)
    }
    
}

extension Date: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == Date {
    func string(fomatter: DateFormatterable) -> String? {
        return fomatter.asFormatter().string(from: wrappedValue)
    }
}

extension URL: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == URL {
    /*
     .html,.html text/html
     .txt text/plain
     .rtf application/rtf
     .gif image/gif
     .ipeg,.jpg image/jpeg
     .au audio/basic
     .mid,.midi audio/midi,audio/x-midi
     .ra, .ram audio/x-pn-realaudio
     .mpg,.mpeg video/mpeg
     .avi video/x-msvideo
     .gz application/x-gzip
     .tar application/x-tar
     */
    
    //根据后缀获取对应的Mime-Type
    var mimeType: String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                           wrappedValue.pathExtension as NSString,
                                                           nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
                .takeRetainedValue() as String? {
                return mimetype.lowercased()
            }
        }
        //文件资源类型如果不知道，传万能类型application/octet-stream，服务器会自动解析文件类
        return "application/octet-stream"
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
        return wrappedValue.base64EncodedString(options: .lineLength64Characters)
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

extension Double: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0,Double(places))
        return (wrappedValue * divisor).rounded() / divisor
    }
}
extension Int: FunNamespaceWrappable {}
public extension FunNamespaceWrapper where T == Int {
    var format2Han: String {
        if wrappedValue > 0, wrappedValue < 9999 {
            return "\(wrappedValue)"
        }
        if wrappedValue < 99999999 {
            
            let odd = "\(wrappedValue%10000)".fb.subString(to: 1)
            
            return "\(wrappedValue/10000).\(odd ?? "0")万"
        }
        if wrappedValue > 99999999 {
            return "\(wrappedValue / 100000000)亿"
        }

        return ""
    }
}





