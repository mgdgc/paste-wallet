//
//  Bank.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import Foundation
import SwiftData

@Model
final class Bank: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var bank: String
    var color: String
    var number: String
    var memo: String?
    
    @Relationship([.encrypt], deleteRule: .cascade, inverse: \SecurityCard.bank) var securityCard: SecurityCard?
    
    init(id: UUID = UUID(), name: String, bank: String, color: String, number: String, memo: String? = nil) {
        self.id = id
        self.name = name
        self.bank = bank
        self.color = color
        self.number = number
        self.memo = memo
    }
}
