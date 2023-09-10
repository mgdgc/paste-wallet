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
        let ivHash = keyHash[keyHash.startIndex..<keyHash.index(keyHash.startIndex, offsetBy: 128)]
        return try! generateAES(key: keyHash, iv: String(ivHash)).encrypt(string.bytes).toBase64()
    }
    
    static func decrypt(_ encoded: String, key: String) -> String? {
        guard let data = Data(base64Encoded: encoded) else {
            return nil
        }
        
        let keyHash = key.sha256()
        let ivHash = keyHash[keyHash.startIndex..<keyHash.index(keyHash.startIndex, offsetBy: 128)]
        
        let bytes = data.bytes
        let decode = try! generateAES(key: keyHash, iv: String(ivHash)).decrypt(bytes)
        
        return String(bytes: decode, encoding: .utf8)
    }
    
    private static func generateAES(key: String, iv: String) -> AES {
        let keyDecodes : Array<UInt8> = Array(key.utf8)
        let ivDecodes : Array<UInt8> = Array(iv.utf8)
        let aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs5)
        
        return aesObject
    }
}
