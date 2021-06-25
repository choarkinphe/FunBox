//
//  Theme.swift
//  CoreKit
//
//  Created by choarkinphe on 2020/9/3.
//

import UIKit
import Hue
// MARK: 主题管理器
public typealias CKColor = Theme.Color
public typealias CKFont = Theme.Font
public typealias CKImage = Theme.Image
public class Theme {
    
    public struct Color {
        // 主题色
        public static var main = UIColor(hex: "D80C18")
        // 系统背景
        public static var systemBackground: UIColor {
            if #available(iOS 13.0, *), Theme.manager.autoUserInterfaceStyle {
                return UIColor.systemBackground
            } else {
                // Fallback on earlier versions
                return .white
            }
        }
        
        public static var gray: UIColor {
            if #available(iOS 13.0, *), Theme.manager.autoUserInterfaceStyle {
                return UIColor.systemGray
            } else {
                // Fallback on earlier versions
                return UIColor(hex: "f5f5f5")
            }
        }
        
        // 浅色背景
        public static var lightBackground: UIColor {
            if #available(iOS 13.0, *), Theme.manager.autoUserInterfaceStyle {
                return UIColor.systemGray6
            } else {
                // Fallback on earlier versions
                return UIColor(hex: "f2f2f7")
            }
        }
        // 深色背景
        public static var darkBackground: UIColor {
            if #available(iOS 13.0, *), Theme.manager.autoUserInterfaceStyle {
                
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor.white
                    } else {
                        return UIColor(hex: "222222")
                    }
                }
            } else {
                // Fallback on earlier versions
                return UIColor(hex: "222222")
            }
            
        }
        
        // 深色背景
        public static var tabBarBackground: UIColor {
            if #available(iOS 13.0, *), Theme.manager.autoUserInterfaceStyle {
                
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(hex: "292a2f")
                    } else {
                        return UIColor.white
                    }
                }
            } else {
                // Fallback on earlier versions
                return UIColor.white
            }
            
        }
        
        // 白色文字
        public static var white: UIColor {
            return .white
        }
        // 浅色文字
        public static var lightText: UIColor {
            if #available(iOS 13.0, *), Theme.manager.autoUserInterfaceStyle {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(hex: "dcdcdc")
                    } else {
                        return UIColor(hex: "666666")
                    }
                }
            } else {
                // Fallback on earlier versions
                return UIColor(hex: "666666")
            }
        }
        // 深色文字
        public static var darkText: UIColor {
            if #available(iOS 13.0, *), Theme.manager.autoUserInterfaceStyle {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(hex: "ececec")
                    } else {
                        return UIColor(hex: "333333")
                    }
                }
            } else {
                // Fallback on earlier versions
                return UIColor(hex: "333333")
            }
        }
        // 分割线
        public static var line: UIColor {
            if #available(iOS 13.0, *), Theme.manager.autoUserInterfaceStyle {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(hex: "f6f6f6")
                    } else {
                        return UIColor(hex: "e3e3e3")
                    }
                }
            } else {
                // Fallback on earlier versions
                return UIColor(hex: "e3e3e3")
            }
        }
        
        
    }
    
    public struct Font {
        public struct Name {
            let rawValue: String
            public init(_ fontName: String) {
                self.rawValue = fontName
            }
            
            public static var `default` = Name(UIFont.systemFont(ofSize: 15).fontName)
            public static var bold = Name(UIFont.boldSystemFont(ofSize: 15).fontName)
        }
        public struct Size {
            let rawValue: CGFloat
            public init(_ size: CGFloat) {
                self.rawValue = size
            }
            
            // 默认字体
            public static var `default` = Size(14)
            // 大字
            public static var largeText = Size(16)
            // 标题
            public static var title = Size(18)
            // 大标题
            public static var largeTitle = Size(22)
            // 小字体
            public static var small = Size(12)
        }
        
        // 默认字体
        public static var `default` = Font.size(.default)
        // 小字体
        public static var small = Font.size(.small)
        // 大字
        public static var largeText = Font.size(.largeText)
        // 标题
        public static var title = Font.size(.title)
        // 粗体标题
        public static var boldTitle = Font.boldSize(.title)
        // 大标题
        public static var largeTitle = Font.boldSize(.largeTitle)
        
        
        public static func get(for font: Font.Name, size: Font.Size) -> UIFont {
            if let font = UIFont(name: font.rawValue, size: size.rawValue) {
                return font
            }
            return UIFont.systemFont(ofSize: size.rawValue)
        }
        
        // 自定义普通字体
        public static func size(_ size: Font.Size) -> UIFont {
            
            return get(for: .default, size: size)
        }
        // 自定义大字体
        public static func boldSize(_ size: Font.Size) -> UIFont {
            
            return get(for: .bold, size: size)
        }
        
    }
    
    public struct Image {
        public static var right_arrow: UIImage? {
            
            return UIImage(named: "ic_arrow_right", in: CoreKit.bundle, compatibleWith: nil)
        }
        
        public static var left_arrow: UIImage? {
            
            return UIImage(named: "ic_arrow_left", in: CoreKit.bundle, compatibleWith: nil)
        }
        public static var more: UIImage? {
            
            return UIImage(named: "ic_more", in: CoreKit.bundle, compatibleWith: nil)
        }
        public static var close: UIImage? {
            
            return UIImage(named: "ic_sys_close", in: CoreKit.bundle, compatibleWith: nil)
        }
    }
    
    public enum Style: String {
        case `default` = "default"
        case dark = "dark"
    }
    
    public var style: Style = .default
    
    public var autoUserInterfaceStyle: Bool = false
    
    private struct Static {
        static let instance = Theme()
    }
    
    public static var manager: Theme {
        return Static.instance
    }
}

//extension HZNamespaceWrapper where T : UIImage {
//
//
//}

// MARK: - 主题用到的协议
public protocol Themeable: NSObject {
    func theme(_ style: Theme.Style) -> Self
    
}

extension Themeable {
    public func theme(_ style: Theme.Style) -> Self {
        self.fb.set(identifier: style.rawValue)
        return self
    }
    
}
fileprivate typealias UIColors = [UIColor?]
public protocol ColorThemeable {
    var current: UIColor? { get }
}

extension UIColor: ColorThemeable, Themeable {
    public var current: UIColor? {
        return self
    }
}

extension UIColors: ColorThemeable {
    public var current: UIColor? {
        let identifier = Theme.manager.style.rawValue
        
        for item in self {
            if item?.fb.identifier == identifier {
                return item
            }
        }
        return self.first as? UIColor
    }
}

fileprivate typealias UIImages = [UIImage?]
public protocol ImageThemeable {
    var current: UIImage? { get }
}

extension UIImage: ImageThemeable, Themeable {
    public var current: UIImage? {
        return self
    }
    
    
}

extension UIImages: ImageThemeable {
    public var current: UIImage? {
        let identifier = Theme.manager.style.rawValue
        
        for item in self {
            if item?.fb.identifier == identifier {
                return item
            }
        }
        return self.first as? UIImage
    }
}

fileprivate typealias UIFonts = [UIFont?]
public protocol FontThemeable {
    var current: UIFont? { get }
}

extension UIFont: FontThemeable, Themeable {
    public var current: UIFont? {
        return self
    }
}

extension UIFonts: FontThemeable {
    public var current: UIFont? {
        let identifier = Theme.manager.style.rawValue
        
        for item in self {
            if item?.fb.identifier == identifier {
                return item
            }
        }
        return self.first as? UIFont
    }
}

// MARK: 给各个可能用到主题的控件增加方法
public extension ThemeNamespaceWrapper where T : UIView {
    func set(backgroundColor: ColorThemeable?) {
        wrappedValue.backgroundColor = backgroundColor?.current
    }
}

public extension ThemeNamespaceWrapper where T : UIButton {
    func set(image: ImageThemeable?, for state: UIControl.State) {
        
        wrappedValue.setImage(image?.current, for: state)
    }
    
    func set(backgroundImage: ImageThemeable?, for state: UIControl.State) {
        
        wrappedValue.setBackgroundImage(backgroundImage?.current, for: state)
    }
    
    func set(titleColor: ColorThemeable?, for state: UIControl.State) {
        wrappedValue.setTitleColor(titleColor?.current, for: state)
    }
    
    func set(titleShadowColor: ColorThemeable?, for state: UIControl.State) {
        wrappedValue.setTitleShadowColor(titleShadowColor?.current, for: state)
    }
}

public extension ThemeNamespaceWrapper where T : UIImageView {
    func set(image: ImageThemeable?) {
        wrappedValue.image = image?.current
    }
}

public extension ThemeNamespaceWrapper where T : UILabel {
    func set(font: FontThemeable?) {
        wrappedValue.font = font?.current
    }
    
    func set(textColor: ColorThemeable?) {
        wrappedValue.textColor = textColor?.current
    }
}

public extension ThemeNamespaceWrapper where T : UIBarItem {
    func set(image: ImageThemeable?) {
        wrappedValue.image = image?.current
    }
    
}

public extension ThemeNamespaceWrapper where T : UIBarButtonItem {
    func set(tintColor: ColorThemeable?) {
        wrappedValue.tintColor = tintColor?.current
    }
}

// MARK: - 创建Theme的命名空间
extension NSObject: ThemeNamespaceWrappable {}
public protocol ThemeNamespaceWrappable {
    associatedtype ThemeWrapperType
    var theme: ThemeWrapperType { get }
    static var theme: ThemeWrapperType.Type { get }
}

public extension ThemeNamespaceWrappable {
    var theme: ThemeNamespaceWrapper<Self> {
        return ThemeNamespaceWrapper(value: self)
    }
    
    static var theme: ThemeNamespaceWrapper<Self>.Type {
        return ThemeNamespaceWrapper.self
    }
}

public struct ThemeNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
