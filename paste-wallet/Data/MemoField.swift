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
    @Attribute(.unique) var id: UUID
    var title: String
    var value: String
    var isCredential: Bool
    
    var memo: Memo?
    
    init(id: UUID, title: String, value: String, isCredential: Bool) {
        self.id = id
        self.title = title
        self.value = value
        self.isCredential = isCredential
    }
}
