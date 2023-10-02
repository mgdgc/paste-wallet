//
//  CryptoHelper.swift
//  paste-wallet
//
//  Created by 최명근 on 9/10/23.
//

import Foundation
import CryptoSwift

class CryptoHelper {
    
    static func encrypt(_ string: String, key: String) -> String {
        let keyHash = key.sha256()
        let keyHash32 = keyHash[keyHash.startIndex..<keyHash.index(keyHash.startIndex, offsetBy: 32)]
        let ivHash = keyHash[keyHash.startIndex..<keyHash.index(keyHash.startIndex, offsetBy: 16)]
        
        let encrypted = try! generateAES(key: String(keyHash32), iv: String(ivHash)).encrypt(string.bytes)
        
        return Data(encrypted).base64EncodedString()
    }
    
    static func decrypt(_ encoded: String, key: String) -> String? {
        guard let data = Data(base64Encoded: encoded) else {
            return nil
        }
        
        let keyHash = key.sha256()
        let keyHash32 = keyHash[keyHash.startIndex..<keyHash.index(keyHash.startIndex, offsetBy: 32)]
        let ivHash = keyHash[keyHash.startIndex..<keyHash.index(keyHash.startIndex, offsetBy: 16)]
        
        let bytes = data.bytes
        let decode = try! generateAES(key: String(keyHash32), iv: String(ivHash)).decrypt(bytes)
        
        return String(bytes: decode, encoding: .utf8)
    }
    
    private static func generateAES(key: String, iv: String) -> AES {
        let keyDecodes = Array(key.utf8)
        let ivDecodes = Array(iv.utf8)
        let aes = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs7)
        
        return aes
    }
}
