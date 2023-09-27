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
    var touch: Date
    var favorite: Bool
    
    init(id: UUID = UUID(), name: String, bank: String, color: String, number: String, memo: String? = nil) {
        self.id = id
        self.name = name
        self.bank = bank
        self.color = color
        self.number = number
        self.memo = memo
        self.touch = Date()
        self.favorite = false
    }
}

// MARK: - SwiftData CRUD
extension Bank {
    static func fetchAll(modelContext: ModelContext) -> [Bank] {
        let descriptor = FetchDescriptor<Bank>(sortBy: [SortDescriptor(\.touch, order: .forward)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(#function, error)
            return []
        }
    }
    
    static func fetchFavorite(modelContext: ModelContext) -> [Bank] {
        let predicate = #Predicate<Bank> { $0.favorite }
        let descriptor = FetchDescriptor<Bank>(predicate: predicate, sortBy: [SortDescriptor(\.touch, order: .forward)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(#function, error)
            return []
        }
    }
}

// MARK: - Encrypt / Decrypt
extension Bank {
    static func encryptNumber(_ key: String, _ number: String) -> String {
        return CryptoHelper.encrypt(number, key: key)
    }
    
    func decryptNumber(_ key: String) -> String {
        if let decrypted = CryptoHelper.decrypt(self.number, key: key) {
            return decrypted
        } else {
            print(#function, "decrypting failed")
            return ""
        }
    }
}
