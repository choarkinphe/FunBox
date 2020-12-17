//
//  FunSecurity.swift
//  FunBox
//
//  Created by 肖华 on 2020/5/18.
//

import Foundation
import CoreFoundation
import CommonCrypto
//fileprivate let kTypeOfWrapPadding = SecPadding.PKCS1
public protocol FunRSAConvertable {
    func asEncryptData() -> Data?
    func asDecryptData() -> Data?
//    func asString() -> String?
}

extension Data: FunRSAConvertable {
    public func asEncryptData() -> Data? {
        return self
    }
    
    public func asDecryptData() -> Data? {
        return self
    }
    
    public func asDecryptString() -> String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }
    
    public func asEncryptString() -> String? {
        return fb.base64String
    }
}

extension String: FunRSAConvertable {
    public func asEncryptData() -> Data? {

        return data(using: String.Encoding.utf8)
    }
    
    public func asDecryptData() -> Data? {
        return Data(base64Encoded: self)
    }
    
}


extension FunBox {
    public class RSA {
        
        /// 公钥引用
        static var publicKeyRef: SecKey?
        
        /// 私钥引用
        static var privateKeyRef: SecKey?
        
        /// rsa 加密字符串
        ///
        /// - Parameters:
        /// - text: 要加密的字符串
        /// - publicKey: 公钥路径
//        public func rsaEncrypt(_ data: FunRSAConvertable?, publicKey: SecKey?=nil) -> String? {
//            guard let encodeData = data?.asData() else {
//                print("String to be encrypted is nil")
//                return nil
//            }
//
//            guard let encryptData = rsaEncrypt(data: encodeData, publicKey: publicKey) else {
//                return nil
//
//            }
//
//            return encryptData.fb.base64String
//        }
        
        /// rsa 加密二进制数据
        ///
        /// - Parameters:
        /// - data: 要加密的二进制数据
        /// - publicKey: 公钥路径
        public static func encrypt(_ sourceData: FunRSAConvertable?, publicKey: SecKey?=nil) -> Data? {
            guard let publicKeyRef = (publicKey ?? FunBox.RSA.publicKeyRef) else {
                print("path of public key is nil.")
                
                return nil
            }
            guard let dt = sourceData?.asEncryptData() else { return nil }
            
            guard dt.count > 0 && dt.count < SecKeyGetBlockSize(publicKeyRef) - 11
                else {
                    print("The content encrypted is too large")
                    
                    return nil
            }
            
            let cipherBufferSize = SecKeyGetBlockSize(publicKeyRef)
            var encryptBytes = [UInt8](repeating: 0, count: cipherBufferSize)
            var outputSize: Int = cipherBufferSize
            let secKeyEncrypt = SecKeyEncrypt(publicKeyRef, SecPadding.PKCS1, dt.fb.arrayOfBytes, dt.count, &encryptBytes, &outputSize)
            if errSecSuccess != secKeyEncrypt {
                print("decrypt unsuccessfully")
                
                return nil
            }
            
//            return Data(bytes: UnsafePointer<UInt8>(encryptBytes), count: outputSize)
//            _ = encryptBytes.withUnsafeBufferPointer { $0 }
            return Data(bytes: encryptBytes, count: outputSize)
        }
        
        /// rsa 解密字符串
        ///
        /// - Parameters:
        /// - text: 要解密的 base64 编码字符串
        /// - privateKey: 私钥
//        public func rsaDecrypt(text: String?, privateKey: SecKey?=nil) -> String? {
//            guard let text = text, let encodeData = Data(base64Encoded: text) else {
//                print("String to be decrypted is nil")
//                return nil
//            }
//
//            guard let decryptedData = rsaDecrypt(data: encodeData) else {
//
//                return nil
//            }
//
//            return String(data: decryptedData, encoding: String.Encoding.utf8)
//        }
        
        /// rsa 解密二进制数据
        ///
        /// - Parameters:
        /// - data: 要解密的二进制数据
        /// - privateKey: 私钥
        public static func decrypt(_ sourceData: FunRSAConvertable?, privateKey: SecKey?=nil) -> Data? {
            guard let pkRef = (privateKey ?? privateKeyRef), let dt = sourceData?.asDecryptData() else {
                print("path of private key is nil.")
                
                return nil
            }
            
            let cipherBufferSize = SecKeyGetBlockSize(pkRef)
            let keyBufferSize = dt.count
            if keyBufferSize > cipherBufferSize {
                print("The content decrypted is too large")
                
                return nil
            }
            
            var decryptBytes = [UInt8](repeating: 0, count: cipherBufferSize)
            var outputSize = cipherBufferSize
            let status = SecKeyDecrypt(pkRef, SecPadding.PKCS1, dt.fb.arrayOfBytes, dt.count, &decryptBytes, &outputSize)
            if errSecSuccess != status {
                print("decrypt unsuccessfully")
                
                return nil
            }

//            return Data(bytes: UnsafePointer<UInt8>(decryptBytes), count: outputSize)
            return Data(bytes: decryptBytes, count: outputSize)

        }
    }
    
}

extension FunBox.RSA {
    
    /// 加载公钥
    ///
    /// - Parameter
    /// - filePath: .der公钥文件路径
    public static func loadPublicKey(_ filePath: String) -> SecKey? {
//        if publicKeyRef != nil {
//            publicKeyRef = nil
//        }
        
        var certificateRef: SecCertificate?
        
        do {
            // 用一个.der格式证书创建一个证书对象
            let certificateData = try Data(contentsOf: URL(fileURLWithPath: filePath))
            certificateRef = SecCertificateCreateWithData(kCFAllocatorDefault, certificateData as CFData)
        } catch {
            print("file of public key is error.")
            return nil
        }
        
        // 返回一个默认 X509 策略的公钥对象
        let policyRef = SecPolicyCreateBasicX509()
        // 包含信任管理信息的结构体
        var trustRef: SecTrust?
        
        // 基于证书和策略创建一个信任管理对象
        var status = SecTrustCreateWithCertificates(certificateRef!, policyRef, &trustRef)
        if status != errSecSuccess {
            print("trust create With Certificates unsuccessfully")
            return nil
        }
        
        // 信任结果
        var trustResult = SecTrustResultType.invalid
        // 评估指定证书和策略的信任管理是否有效
        status = SecTrustEvaluate(trustRef!, &trustResult)
        
        if status != errSecSuccess {
            print("trust evaluate unsuccessfully")
            return nil
        }
        
        // 评估之后返回公钥子证书
        let publicKeyRef = SecTrustCopyPublicKey(trustRef!)
        if publicKeyRef == nil {
            print("public Key create unsuccessfully")
            return nil
        }
        
        return publicKeyRef
    }
    
    /// 加载私钥
    ///
    /// - Parameters:
    /// - filePath: .p12私钥文件路径
    /// - password: 私钥密码
    public static func loadPrivateKey(_ filePath: String, _ password: String) -> SecKey? {
        if filePath.count <= 0  {
            print("path of public key is nil.")
            return nil
        }
        
        var privateKeyRef: SecKey?
//        if privateKeyRef != nil {
//            privateKeyRef = nil
//        }
        
        var pkcs12Data: Data?
        do {
            pkcs12Data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        } catch {
            print(error)
            return nil
        }
        
        let kSecImportExportPassphraseString = kSecImportExportPassphrase as String
        let options = [kSecImportExportPassphraseString: password]
        var items : CFArray?
        let status = SecPKCS12Import(pkcs12Data! as CFData, options as CFDictionary, &items)
        if status != errSecSuccess {
            print("Imports the contents of a PKCS12 formatted blob unsuccessfully")
            return nil
        }
        
        if CFArrayGetCount(items) <= 0 {
            print("the number of values currently in the array <= 0")
            return nil
        }
        
        let kSecImportItemIdentityString = kSecImportItemIdentity
        
        let dict = unsafeBitCast(CFArrayGetValueAtIndex(items, 0),to: CFDictionary.self)
        let key = Unmanaged.passUnretained(kSecImportItemIdentityString).toOpaque()
        let value = CFDictionaryGetValue(dict, key)
        let secIdentity = unsafeBitCast(value, to: SecIdentity.self)
        
        let secIdentityCopyPrivateKey = SecIdentityCopyPrivateKey(secIdentity, &privateKeyRef)
        if secIdentityCopyPrivateKey != errSecSuccess {
            print("return the private key associated with an identity unsuccessfully")
            return nil
        }
        return privateKeyRef
    }
    
}
