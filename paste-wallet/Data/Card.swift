//
//  Card.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import Foundation
import SwiftData

@Model
final class Card {
    @Attribute(.unique) var id: UUID
    var name: String
    var issuer: String?
    var brand: String
    var color: String
    var number: [String]
    var year: Int
    var month: Int
    var cvc: String?
    var memo: String?
    var touch: Date
    
    // MARK: - Wrapped Values
    var wrappedBrand: Brand {
        Brand(rawValue: brand) ?? .etc
    }
    
    var wrappedExpirationDate: String {
        return "\(String(format: "%02d", month)) / \(String(format: "%02d", month))"
    }
    
    // MARK: - Initializer
    init(id: UUID = UUID(), name: String, issuer: String? = nil, brand: Brand, color: String, number: [String], year: Int, month: Int, cvc: String? = nil, memo: String? = nil) {
        self.id = id
        self.name = name
        self.issuer = issuer
        self.brand = brand.rawValue
        self.color = color
        self.number = number
        self.year = year
        self.month = month
        self.cvc = cvc
        self.memo = memo
        self.touch = Date()
    }
    
    // MARK: - SwiftData CRUD
    static func fetchAll(modelContext: ModelContext) -> [Card] {
        let descriptor = FetchDescriptor<Card>(sortBy: [SortDescriptor(\.touch, order: .forward)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(#function, error)
            return []
        }
    }
    
    // MARK: - Util
    static func encryptNumber(_ key: String, _ number: [String]) -> [String] {
        var encrypted: [String] = []
        for n in number {
            encrypted.append(CryptoHelper.encrypt(n, key: key))
        }
        
        return encrypted
    }
    
    // MARK: - Getter
    func decryptNumber(key: String) -> [String] {
        var numbers: [String] = []
        for n in self.number {
            if let decrypted = CryptoHelper.decrypt(n, key: key) {
                numbers.append(decrypted)
            } else {
                print(#function, "decrypting failed")
            }
        }
        
        return numbers
    }
    
    func getWrappedNumber(_ key: String, _ separator: SeparatorStyle) -> String {
        var number = ""
        for i in decryptNumber(key: key).indices {
            number.append("\(self.number[i])")
            if i < self.number.count - 1 {
                switch separator {
                case .none:
                    break
                case .dash:
                    number.append("-")
                    break
                case .space:
                    number.append(" ")
                }
            }
        }
        return number
    }
    
    enum SeparatorStyle: Equatable {
        case none
        case dash
        case space
    }
    
}

extension Card {
    enum Brand: String, Equatable {
        case visa
        case master
        case amex
        case klsc
        case unionPay
        case jcb
        case discover
        case europay
        case local
        case etc
    }
}
