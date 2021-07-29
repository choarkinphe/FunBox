//
//  TestVPN.swift
//  FunBox_Example
//
//  Created by 肖华 on 2021/7/23.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import NetworkExtension

class ProviderManager: NETunnelProviderSession {
    
    func createProviderManager() -> NETunnelProviderManager {
        //首先，我们需要在主程序中像系统生名一个ProviderManager，即设置VPN中的栏目。
        let manager = NETunnelProviderManager()
        let conf = NETunnelProviderProtocol()
        conf.serverAddress = "Rabbit" //任意值,显示在设置-VPN-Detial中
        manager.protocolConfiguration = conf
        manager.localizedDescription = "Rabbit VPN"
        manager.isEnabled = true //使VPN在系统中变为选中的状态
        
        // 将manager保存至系统中。
        manager.saveToPreferences { error in
            if error != nil{print(error);return;}
            //Todo
            // 此时，打开系统-Vpn菜单，即可看见我们新建的Vpn条目
        }
        
        return manager
    }
    func a() {

        
        // 此时如果save方法调用多次，会出现VPN 1 VPN 2等多个描述文件 ，因此，苹果也要求，在创建前应读取当前的managers
        NETunnelProviderManager.loadAllFromPreferences {
            (managers, error) in
            guard let managers = managers else{return}
            let manager: NETunnelProviderManager
            if managers.count > 0 {
                manager = managers[0]
            }else{
//                manager = self
                manager = self.createProviderManager()
            }
            // Todo
            // manager.saveToPreferences.......
        }
 
        
    }
    
//    override func startTunnel(options: [String : Any]? = nil) throws {
//        let ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.1"], subnetMasks: ["255.255.255.0"])
//            // 这里RemoteAddress可任意填写。
//            let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "8.8.8.8")
//            networkSettings.mtu = 1500
//            networkSettings.ipv4Settings = ipv4Settings
//    
//            setTunnelNetworkSettings(networkSettings) {
//                error in
//                guard error == nil else {
//                    nslog(error.debugDescription)
//                    completionHandler(error)
//                    return
//                }
//                completionHandler(nil)
//            }
//    }
    
}
