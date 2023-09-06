//
//  Memo.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import Foundation
import SwiftData

@Model
final class Memo: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var value: String
    var isCredential: Bool
    
    @Relationship(inverse: \MemoField.memo) var fields: [MemoField]?
    
    init(id: UUID, title: String, value: String, isCredential: Bool) {
        self.id = id
        self.title = title
        self.value = value
        self.isCredential = isCredential
    }
}
