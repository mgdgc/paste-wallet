//
//  MemoField.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import Foundation
import SwiftData

@Model
final class MemoField: Identifiable {
    var id: UUID
    var title: String
    var value: String
    var touch: Date
    
    var memo: Memo?
    
    init(id: UUID = UUID(), title: String, value: String) {
        self.id = id
        self.title = title
        self.value = value
        self.touch = Date()
    }
}

extension MemoField {
    static func encrypt(_ value: String, _ key: String) -> String {
        return CryptoHelper.encrypt(value, key: key)
    }
    
    func decrypt(_ key: String) -> String {
        return CryptoHelper.decrypt(self.value, key: key) ?? ""
    }
}
