//
//  FunReachability.swift
//  FunBox
//
//  Created by 肖华 on 2020/12/24.
//

import Foundation
import Alamofire
import FunBox
import UIKit
// MARK: - Reachability
public typealias FunReachability = FunBox.Reachability
extension FunBox {
    public enum Reachability: Int {
        
        case unknow = -1
        case notReachable = 0
        case WWAN = 1
        case WiFi = 2
        
        static func status(_ status: NetworkReachabilityManager.NetworkReachabilityStatus?) -> Reachability {
            guard let status = status else { return .unknow }
            switch status {
            case .notReachable:
                return .notReachable
            case .unknown:
                return .unknow
            case .reachable(.cellular):
                return .WWAN
            case .reachable(.ethernetOrWiFi):
                return .WiFi
            }
        }
        
        private static var af_reachability = NetworkReachabilityManager.default
        // 监听网络环境变化（立即异步回调当前网络状态）
        public static func statusChanged(_ completion: @escaping ((Reachability)->Void)) {
            af_reachability?.startListening(onUpdatePerforming: { (status) in
                
                completion(Reachability.status(status))
            })
            
            completion(status)
            
        }
        
        // 获取当前网络环境
        public static var status: Reachability {
            return Reachability.status(af_reachability?.status)
        }
        
        // 监听网络环境变化（立即同步返回当前网络状态）
        public static func checkReachability(changed: ((Reachability)->Void)?=nil) -> Reachability {
            af_reachability?.startListening(onUpdatePerforming: { (status) in
                
                changed?(Reachability.status(status))
            })
            
            return status
        }
        
        public static func release() {
            af_reachability?.stopListening()
        }
    }
}

extension UIView: ReachabilityNamespaceWrappable {}
public extension ReachabilityNamespaceWrapper where T : UIView {
    var status: FunReachability {
        return FunReachability.status(NetworkReachabilityManager.default?.status)
    }
    
}

// 创建一个hz的命名空间，方便扩展方法
public protocol ReachabilityNamespaceWrappable {
    associatedtype ReachabilityWrapperType
    var reachability: ReachabilityWrapperType { get }
    static var reachability: ReachabilityWrapperType.Type { get }
}

public extension ReachabilityNamespaceWrappable {
    var reachability: ReachabilityNamespaceWrapper<Self> {
        return ReachabilityNamespaceWrapper(value: self)
    }
    
    static var reachability: ReachabilityNamespaceWrapper<Self>.Type {
        return ReachabilityNamespaceWrapper.self
    }
}

public struct ReachabilityNamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
