//
//  SecurityCard.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import Foundation
import SwiftData

@Model
final class SecurityCard: Identifiable {
    @Attribute(.unique) var id: UUID
    var numbers: [Int:Int]
    var serial: String
    
    var bank: Bank?
    
    init(id: UUID = UUID(), numbers: [Int : Int], serial: String) {
        self.id = id
        self.numbers = numbers
        self.serial = serial
    }
}
