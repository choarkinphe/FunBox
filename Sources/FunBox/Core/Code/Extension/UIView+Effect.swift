//
//  UIView+Effect.swift
//  FunBox
//
//  Created by choarkinphe on 2019/11/22.
//

import UIKit

public extension UIView {
    class Effect {
        
        public enum Direction {
            case top
            case left
            case right
            case bottom
        }
        
        private var config: Config?
        private var mask_name = Effect.Key.mask
        private var border_name = Effect.Key.border
        private var target: UIView?
        
        public static var `default`: Effect {
            let effect = Effect()
            effect.config = Effect.Config()
            return effect
        }
        
        public func target(_ a_target: UIView?) -> Self {
            target = a_target
            return self
        }
        
        public func identifier(_ identifier: String) -> Self {
            config?.identifier = identifier
            
            mask_name = mask_name + identifier
            border_name = border_name + identifier
            
            return self
        }
        
        public func style(_ style: Style) -> Self {
            config?.style = style
            
            return self
        }
        
        public func lineLength(_ lineLength: CGFloat) -> Self {
            config?.lineLength = lineLength
            
            return self
        }
        
        public func lineSpacing(_ lineSpacing: CGFloat) -> Self {
            config?.lineSpacing = lineSpacing
            
            return self
        }
        
        public func animation(_ animation: Bool) -> Self {
            config?.animation = animation
            
            if animation {
                config?.animation_config = Animation()
            }
            
            return self
        }
        
        public func animation_config(_ animation_config: Animation) -> Self {
            config?.animation_config = animation_config
            
            return self
        }
        
        public func positaion(_ positaion: LinePosition) -> Self {
            config?.positaion = positaion
            
            return self
        }
        
        public func borderWidth(_ borderWidth: CGFloat) -> Self {
            config?.borderWidth = borderWidth
            
            return self
        }
        
        public func borderColor(_ borderColor: UIColor) -> Self {
            config?.borderColor = borderColor
            
            return self
        }
        
        public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
            config?.cornerRadius = cornerRadius
            
            return self
        }
        
        public func rectCornerType(_ rectCornerType: UIRectCorner) -> Self {
            config?.rectCornerType = rectCornerType
            
            return self
        }
        
        public func rect(_ rect: CGRect) -> Self {
            config?.rect = rect
            
            return self
        }
        
        public func gradientColors(_ colors: [UIColor]) -> Self {
            
            var array = [CGColor]()
            for color in colors {
                array.append(color.cgColor)
            }
            config?.gradientColors = array
            return self
        }
        
        public func direction(_ direction: Direction) -> Self {
            config?.direction = direction
            
            return self
        }
        
        public func clearLayer(identifier: String? = nil) {
            
            if let view = target {
                
                var layer_mask: CALayer?
                var layer_border: CALayer?
                
                if let a_identifier = identifier {
                    mask_name = mask_name + a_identifier
                    border_name = border_name + a_identifier
                }
                
                if view.layer.sublayers != nil {
                    for (_, item_layer) in view.layer.sublayers!.enumerated() {
                        
                        if item_layer.name == mask_name {
                            layer_mask = item_layer
                        }
                        
                        if item_layer.name == border_name {
                            layer_border = item_layer
                        }
                    }
                    
                    if (layer_mask != nil) {
                        layer_mask?.removeFromSuperlayer()
                    }
                    
                    if (layer_border != nil) {
                        layer_border?.removeFromSuperlayer()
                    }
                }
            }
            
        }
        
        public func draw() {
            
            if let view = target {
                
                clearLayer(identifier: nil)
                
                view.layer.rasterizationScale = UIScreen.main.scale
                
                if let config = config {
                    if let style = config.style {
                        switch style {
                        case .corner:
                            draw_corner(view: view,config: config)
                        case .line:
                            draw_line(view: view,config: config)
                        case .gradientColor:
                            draw_gradientColors(view: view, config: config)
                        case .ariangle:
                            draw_ariangle(view: view, config: config)
                        }
                    }
                }
            }
        }
        
        private func draw_ariangle(view: UIView, config: Config) {
            guard let rect = config.rect else { return }
            let direction = config.direction
            let bezierPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: .zero)
//            let bezierPath = UIBezierPath(rect: rect)
            
            var strat_point = CGPoint(x: rect.minX, y: rect.maxY)
            var center_point = CGPoint(x: rect.midX, y: rect.minY)
            var end_point = CGPoint(x: rect.maxX, y: rect.maxY)
            if direction == .bottom {
                strat_point.y = rect.minY
                center_point.y = rect.maxY
                end_point.y = rect.minY
            }
            bezierPath.move(to: strat_point)
            bezierPath.addLine(to: center_point)
            bezierPath.addLine(to: end_point)
            
            let shaperLayer = CAShapeLayer()
            shaperLayer.fillColor = config.borderColor?.cgColor
//            shaperLayer.masksToBounds = true

            view.layer.addSublayer(shaperLayer)
            shaperLayer.path = bezierPath.cgPath
            
        }
        
        private func draw_gradientColors(view: UIView, config: Config) {
            guard let colors = config.gradientColors else { return }
            //CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
            let gradientLayer = CAGradientLayer()
            
            gradientLayer.frame = view.bounds
            
            //  创建渐变色数组，需要转换为CGColor颜色
            gradientLayer.colors = colors
            
            //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            
            //  设置颜色变化点，取值范围 0.0~1.0
            gradientLayer.locations = [0,1]
            
            // 将渐变色图层压倒最下
            //        [wrappedValue.layer. insertSublayer:gradientLayer atIndex:0];
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        private func draw_line(view: UIView, config: Config) {
            let rect = config.rect ?? view.bounds
            let lineWith = config.borderWidth ?? 0
            
            let borderLayer = CAShapeLayer()
            borderLayer.frame = rect
            borderLayer.name = border_name
            borderLayer.fillColor = UIColor.clear.cgColor
            if let borderColor = config.borderColor {
                borderLayer.strokeColor = borderColor.cgColor
            }
            
            borderLayer.lineWidth = lineWith
            borderLayer.lineJoin = CAShapeLayerLineJoin.round
            
            //每一段虚线长度 和 每两段虚线之间的间隔
            borderLayer.lineDashPattern = [NSNumber.init(value: Double(config.lineLength)), NSNumber.init(value: Double(config.lineSpacing))]
            
            let path = CGMutablePath()
            
            var x_start: CGFloat = 0.0
            var y_start: CGFloat = 0.0
            
            var x_end: CGFloat = 0.0
            var y_end: CGFloat = 0.0
            
            switch config.positaion {
            case .top:
                x_start = 0.0
                y_start = 0.0
                x_end = rect.size.width
                y_end = 0.0
            case .left:
                x_start = 0.0
                y_start = 0.0
                x_end = rect.size.width
                y_end = rect.size.height
            case .bottom:
                x_start = 0.0
                y_start = rect.size.height - lineWith
                x_end = rect.size.width
                y_end = rect.size.height - lineWith
            case .right:
                x_start = rect.size.width - lineWith
                y_start = 0.0
                x_end = rect.size.width - lineWith
                y_end = rect.size.height
                
            }
            
            path.move(to: CGPoint(x: x_start, y: y_start))
            path.addLine(to: CGPoint(x: x_end, y: y_end))
            borderLayer.path = path
            
            if config.animation {
                add_animation(shapeLayer: borderLayer, config: config.animation_config)
            }
            
            view.layer.insertSublayer(borderLayer, at: 0)
        }
        
        private func draw_corner(view: UIView, config: Config) {
            let rect = config.rect ?? view.bounds
            let cornerRadius = config.cornerRadius ?? 0
            let rectCornerType = config.rectCornerType ?? .allCorners
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.frame = rect
            maskLayer.name = mask_name
            
            let borderLayer = CAShapeLayer()
            borderLayer.frame = rect
            borderLayer.name = border_name
            
            if let borderColor = config.borderColor {
                borderLayer.strokeColor = borderColor.cgColor
            }
            
            borderLayer.lineWidth = config.borderWidth ?? 0
            
            borderLayer.fillColor = UIColor.clear.cgColor
            
            let bezierPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: rectCornerType, cornerRadii: CGSize.init(width: cornerRadius, height: cornerRadius))
            
            maskLayer.path = bezierPath.cgPath
            borderLayer.path = bezierPath.cgPath
            
            view.layer.insertSublayer(borderLayer, at: 0)
            view.layer.mask = maskLayer
        }
        
        private func add_animation(shapeLayer: CAShapeLayer, config: Animation?) {
            if let a_config = config {
                let baseAnimation = CABasicAnimation(keyPath: a_config.name)
                baseAnimation.duration = a_config.duration   //持续时间
                baseAnimation.fromValue = a_config.fromValue  //开始值
                baseAnimation.toValue = a_config.toValue    //结束值
                baseAnimation.repeatDuration = a_config.repeatDuration  //重复次数
            }
            
        }
        
    }
}

private extension UIView.Effect {
    struct Key {
        static var mask = "com.funbox.effect.key.mask"
        static var border = "com.funbox.effect.key.border"
    }
}
public extension UIView.Effect {
    
    enum Style: String {
        case corner = "corner"
        case line = "line"
        case gradientColor = "gradientColor"
        case ariangle = "ariangle"
    }
    
    enum LinePosition: String {
        case top
        case left
        case bottom
        case right
    }
    
    struct Config {
        
        public var gradientColors: [CGColor]?
        
        public var borderWidth: CGFloat?
        
        public var borderColor: UIColor?
        
        public var cornerRadius: CGFloat?
        
        public var rectCornerType: UIRectCorner?
        
        public var direction: Direction = .top
        
        public var rect: CGRect?
        
        public var style: Style?
        
        public var lineLength: CGFloat = 10.0
        
        public var lineSpacing: CGFloat = 5.0
        
        public var positaion: LinePosition = .bottom
        
        public var animation: Bool = false
        
        public var animation_config: Animation?
        
        public var identifier: String?
    }
    
    struct Animation {
        public var duration: Double = 0.5
        public var fromValue: Double = 0.0
        public var toValue: Double = 0.5
        public var repeatDuration: Double = 1.0
        public var name: String = "strokeEnd"
        
        public static func building(duration: Double? = nil, fromValue: Double? = nil, toValue: Double? = nil, repeatDuration: Double? = nil, name: String? = nil) -> Animation {
            var config = Animation()
            
            if let a_duration = duration {
                config.duration = a_duration
            }
            
            if let a_fromValue = fromValue {
                config.fromValue = a_fromValue
            }
            
            if let a_toValue = toValue {
                config.toValue = a_toValue
            }
            
            if let a_repeatDuration = repeatDuration {
                config.repeatDuration = a_repeatDuration
            }
            
            if let a_name = name {
                config.name = a_name
            }
            
            return config
        }
    }
}

public extension FunNamespaceWrapper where T: UIView {
    func effect(_ style: UIView.Effect.Style) -> UIView.Effect {
        return UIView.Effect.default.target(wrappedValue).style(style)
    }
}
