//
//  HZJSBridge.swift
//  HZCoreKit
//
//  Created by choarkinphe on 2020/10/19.
//

import Foundation
import WebKit

//public protocol HZWebBridgeProtocol {
//
//}

public class HZWebBridge: NSObject {
    public typealias Script = ((Any?)->Void)
    
//    var error: WebError?
    
    var scripts: [Action: Script?] {
        set {
            scripts_behavior.accept(newValue)
        }
        get {
            return scripts_behavior.value
        }
    }
    
    // 监听scripts
    var scripts_behavior = BehaviorRelay<[Action: Script?]>(value: [Action: Script?]())

    public override init() {
        super.init()
        
    }
    
    // 添加
    public func feed(action: Action, script: HZWebBridge.Script?=nil) {
        scripts[action] = script
    }
    
    // 通过json批量导入

    
    
    deinit {
        debugPrint("HZWebBridge deinit")
    }
}

extension HZWebBridge {
    
    public struct Action: Hashable {
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

    }
    
    
    
//    public struct Script: HandyJSON {
//        public init() {
//
//        }
//    }
    
    /*
     @[@"telMobile",@"sendSms",@"sendIM",@"gotoResumptionArchives",@"openWebView",@"closeWebView",@"showTip",@"openShareFile",@"tryLogin",@"showDownloadFile"];
     */
}

extension HZRouter.Page {
//static let
    public static func script(message: WKScriptMessage) -> HZRouter.Page {
        
        var url = message.name
        
        if let params = (message.body as? URLParams)?.asQuery(characters: .query) {
            url = url + "?" + params
        } else if let params = message.body as? String {
            url = url + "?" + "params=\(params)"
        }
        return HZRouter.Page(rawValue: "script/\(url)")
    }
}

extension HZRouter.Host {
    static let script = HZRouter.Host(rawValue: "script")
}
