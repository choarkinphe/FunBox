//
//  VPNManager.swift
//  FunBox_Example
//
//  Created by 肖华 on 2021/7/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import NetworkExtension

class VPNManager {
    static let serviceName = "let.us.try.vpn.in.ipsec" //隨便自定義
    static let vpnPwdIdentifier = "vpnPassword" //keychain的密碼存取key
    static let vpnPrivateKeyIdentifier = "sharedKey" //keychain中共享金鑰存取key
    enum Status {
        case off
        case connecting
        case on
        case disconnecting
    }
    static let shared = VPNManager()
    var observerAdded: Bool = false

    fileprivate(set) var vpnStatus: VPNManager.Status = .off {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.NEVPNStatusDidChange, object: nil)
        }
    }
    
    init() {
        loadProviderManager{
            guard let manager = $0 else{return}
            self.updateVPNStatus(manager)
        }
        addVPNStatusObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addVPNStatusObserver() {
        guard !observerAdded else{
            return
        }
        loadProviderManager { [unowned self] (manager) -> Void in
            if let manager = manager {
                self.observerAdded = true
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
                    self.updateVPNStatus(manager)
                    })
            }
        }
    }
    
    
    func updateVPNStatus(_ manager: NEVPNManager) {
        switch manager.connection.status {
        case .connected:
            self.vpnStatus = .on
        case .connecting, .reasserting:
            self.vpnStatus = .connecting
        case .disconnecting:
            self.vpnStatus = .disconnecting
        case .disconnected, .invalid:
            self.vpnStatus = .off
        @unknown default:
            break
        }
        print(self.vpnStatus)
    }
    
    static var `default`: NEVPNManager {
        let instance = NEVPNManager.shared()
        
        instance.localizedDescription = "FunBox"

        instance.isOnDemandEnabled = true
        
        

        
        return instance
    }
    
    static func start() {
        
        VPNManager.createKeychainValue("6MqwMavJ2HBfAHRz", VPNManager.vpnPwdIdentifier)
        VPNManager.createKeychainValue("zyJVhbYK7DMWksqREcRc", VPNManager.vpnPrivateKeyIdentifier)
        
        VPNManager.default.loadFromPreferences { error in
            
            var set = NEVPNProtocolIPSec()
            //VPN用戶名
            set.username = "vpnuser"
            //VPN密碼
//            set.passwordReference = "6MqwMavJ2HBfAHRz".data(using: .utf8)
            set.passwordReference = VPNManager.searchKeychainCopyMatching(VPNManager.vpnPwdIdentifier)
            //ip地址
            set.serverAddress = "120.78.200.221"
            //        conf.username = "vpnuser"
            //        conf.identityDataPassword = "6MqwMavJ2HBfAHRz"
            //        conf.passwordReference = "6MqwMavJ2HBfAHRz"
            //        conf.passwordReference = "zyJVhbYK7DMWksqREcRc".data(using: .utf8)
    //            set.identityReference = "".data(using: .utf8)
//            set.sharedSecretReference = "zyJVhbYK7DMWksqREcRc".data(using: .utf8)
            set.sharedSecretReference = VPNManager.searchKeychainCopyMatching(VPNManager.vpnPrivateKeyIdentifier)
            
//            set.localIdentifier = "zyJVhbYK7DMWksqREcRc"
//            set.localIdentifier = VPNManager.searchKeychainCopyMatching(VPNManager.vpnPrivateKeyIdentifier)
            
            set.authenticationMethod = .sharedSecret
            
            set.useExtendedAuthentication = true
            
            set.disconnectOnSleep = false
            
            VPNManager.default.protocolConfiguration = set
            
            VPNManager.default.saveToPreferences { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            if let error = error {
                print(error.localizedDescription)
                
         
            } else {
                
                

                

            }
            do {
                try VPNManager.default.connection.startVPNTunnel()
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
}

// load VPN Profiles
extension VPNManager {

    

    

    

/*
                 self.manager.protocolConfiguration = set;

                 self.manager.localizedDescription = @"hrjd";//VPN的描述

                 [self.manager setOnDemandEnabled:YES];

                 [self.manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {

                   

                     NSError * error1 ;

     //連接VPN

                     [manager.connection startVPNTunnelAndReturnError:&error1];

                     if (error) {

                         NSLog(@"VPN連接失敗");

                     }else{

                         NSLog(@"VPN連接成功");

                     }

                    

                 }];

                

             }];

      

     [vpnManager.connection stopVPNTunnel];

     //斷開VPN
     */
    
    fileprivate func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let conf = NETunnelProviderProtocol()
        conf.serverAddress = "FunBox"
//        conf.username = "vpnuser"
//        conf.identityDataPassword = "6MqwMavJ2HBfAHRz"
//        conf.passwordReference = "6MqwMavJ2HBfAHRz"
//        conf.passwordReference = "zyJVhbYK7DMWksqREcRc".data(using: .utf8)
        manager.protocolConfiguration = conf
        manager.localizedDescription = "FUN VPN"
        return manager
    }
    
    
    func loadAndCreatePrividerManager(_ complete: @escaping (NETunnelProviderManager?) -> Void ){
        NETunnelProviderManager.loadAllFromPreferences{ (managers, error) in
            guard let managers = managers else{return}
            let manager: NETunnelProviderManager
            if managers.count > 0 {
                manager = managers[0]
                self.delDupConfig(managers)
            }else{
                manager = self.createProviderManager()
            }
            
            manager.isEnabled = true
            self.setRulerConfig(manager)
            manager.saveToPreferences {
                if $0 != nil{complete(nil);return;}
                manager.loadFromPreferences{
                    if $0 != nil{
                        print($0.debugDescription)
                        complete(nil);return;
                    }
                    self.addVPNStatusObserver()
                    complete(manager)
                }
            }
            
        }
    }
    
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void){
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let managers = managers {
                if managers.count > 0 {
                    let manager = managers[0]
                    complete(manager)
                    return
                }
            }
            complete(nil)
        }
    }
    
    
    func delDupConfig(_ arrays:[NETunnelProviderManager]){
        if (arrays.count)>1{
            for i in 0 ..< arrays.count{
                print("Del DUP Profiles")
                arrays[i].removeFromPreferences(completionHandler: { (error) in
                    if(error != nil){print(error.debugDescription)}
                })
            }
        }
    }
}

// Actions
extension VPNManager {
    func connect() {
        loadAndCreatePrividerManager { (manager) in
            guard let manager = manager else{return}
            do{
                try manager.connection.startVPNTunnel(options: [:])
            }catch let err{
                print(err)
            }
        }
    }
    
    func disconnect(){
        loadProviderManager{$0?.connection.stopVPNTunnel()}
    }
}

// Generate and Load ConfigFile
extension VPNManager {
    fileprivate func getRuleConf() -> String {
        let Path = Bundle.main.path(forResource: "NEKitRule", ofType: "conf")
        let Data = try? Foundation.Data(contentsOf: URL(fileURLWithPath: Path!))
        let str = String(data: Data!, encoding: String.Encoding.utf8)!
        return str
    }
    
    fileprivate func setRulerConfig(_ manager:NETunnelProviderManager){
        var conf = [String:Any]()
        conf["ss_address"] = "120.78.200.221"
        conf["ss_port"] = 1025
        conf["ss_method"] = "CHACHA20" // 大写 没有横杠 看Extension中的枚举类设定 否则引发fatal error
        conf["ss_password"] = "zyJVhbYK7DMWksqREcRc"
        conf["ymal_conf"] = getRuleConf()
        let orignConf = manager.protocolConfiguration as! NETunnelProviderProtocol
        orignConf.providerConfiguration = conf
        manager.protocolConfiguration = orignConf
    }
}

extension VPNManager {
    
    /**
     * 存取keychain用到的dictionary
     */
    static func newSearchDictionary(_ identifier : String) -> NSMutableDictionary {
        let searchDictionary = NSMutableDictionary()
        let encodedIdentifier: Data = identifier.data(using: .utf8)!
        searchDictionary.addEntries(from: [
            kSecClass as NSString: kSecClassGenericPassword as NSString,
            kSecAttrGeneric as NSString: encodedIdentifier,
            kSecAttrAccount as NSString: encodedIdentifier,
            kSecAttrService as NSString: serviceName
        ])
        return searchDictionary
    }
    /**
     * 搜尋對應的keychain資料
     */
    static func searchKeychainCopyMatching(_ identifier : String) -> Data{
        let searchDictionary = newSearchDictionary(identifier)
        searchDictionary.addEntries(from: [
            kSecMatchLimit as NSString: kSecMatchLimitOne as NSString,
            kSecReturnPersistentRef as NSString: true
        ])
        var result: CFTypeRef? = nil
    
        SecItemCopyMatching(searchDictionary as CFMutableDictionary, &result)
        return result as! Data
    }
    /**
     * 建立對應的keychain資料
     */
    static func createKeychainValue(_ password: String, _ identifier: String) -> Bool{
        let dictionary = newSearchDictionary(identifier)
        var status: OSStatus = SecItemDelete(dictionary as CFMutableDictionary)
        let passwordData: Data = password.data(using: .utf8)!
        dictionary.setObject(passwordData, forKey: kSecValueData as NSString)
        status = SecItemAdd(dictionary as CFDictionary, nil)
        return status == errSecSuccess
    }
}
