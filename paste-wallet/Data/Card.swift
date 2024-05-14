//
//  Card.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import Foundation
import SwiftData

@Model
final class Card: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String = ""
    var issuer: String?
    var brand: String = "etc"
    var color: String = "#ffffff"
    var number: [String] = ["", "", "", ""]
    var year: Int = 00
    var month: Int = 00
    var cvc: String?
    var memo: String?
    var touch: Date = Date()
    var favorite: Bool = false
    
    // MARK: - Initializer
    init(id: UUID = UUID(), name: String, issuer: String? = nil, brand: Brand, color: String, number: [String], year: Int, month: Int, cvc: String? = nil, memo: String? = nil, favorite: Bool = false) {
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
        self.favorite = favorite
    }
    
    // MARK: - Wrapped Values
    var wrappedBrand: Brand {
        Brand(rawValue: brand) ?? .etc
    }
    
    var wrappedExpirationDate: String {
        return "\(String(format: "%02d", month)) / \(String(format: "%02d", year))"
    }
    
    func getWrappedNumber(_ key: String, _ separator: SeparatorStyle) -> String {
        var number = ""
        for (index, value) in decryptNumber(key: key).enumerated() {
            number.append(value)
            if index < self.number.count - 1 {
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
    
    // MARK: - PreviewItem
    static func previewItems() -> [Card] {
        return [
            Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "x9PiMe/aOJ8Zilssnp5i9Q==", memo: "asdfhjhkasd\nasdf\nasdfasdf\nasdf\nasdf\n\nasdfasdfasdf"),
            Card(name: "ZERO Edition 2 2", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "x9PiMe/aOJ8Zilssnp5i9Q=="),
            Card(name: "ZERO Edition 2 3", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "x9PiMe/aOJ8Zilssnp5i9Q=="),
            Card(name: "ZERO Edition 2 4", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "x9PiMe/aOJ8Zilssnp5i9Q==")
        ]
    }
    
    enum SeparatorStyle: Equatable {
        case none
        case dash
        case space
    }
    
}

// MARK: - SwiftData CRUD
extension Card {
    static func fetchAll(modelContext: ModelContext) -> [Card] {
        let descriptor = FetchDescriptor<Card>(sortBy: [SortDescriptor(\.touch, order: .forward)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(#function, error)
            return []
        }
    }
    
    static func fetchFavorite(modelContext: ModelContext) -> [Card] {
        let predicate = #Predicate<Card> { $0.favorite }
        let descriptor = FetchDescriptor<Card>(predicate: predicate, sortBy: [SortDescriptor(\.touch, order: .forward)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(#function, error)
            return []
        }
    }
    
    static func fetchById(modelContext: ModelContext, id: String) -> Card? {
        let uuid = UUID(uuidString: id)!
        let predicate = #Predicate<Card> { card in
            card.id == uuid
        }
        let descriptor = FetchDescriptor<Card>(predicate: predicate, sortBy: [SortDescriptor(\.touch, order: .forward)])
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print(#function, error)
            return nil
        }
    }
    
    static func changePasscode(modelContext: ModelContext, oldKey: String, newKey: String) {
        let allCards = Card.fetchAll(modelContext: modelContext)
        for card in allCards {
            card.number = Card.encryptNumber(newKey, card.decryptNumber(key: oldKey))
            if let cvc = card.getWrappedCVC(oldKey) {
                card.cvc = Card.encryptCVC(newKey, cvc)
            }
        }
        do {
            try modelContext.save()
        } catch {
            print(#function, error)
        }
    }
}

// MARK: - Encrypt / Decrypt
extension Card {
    // MARK: - Number encryption
    static func encryptNumber(_ key: String, _ number: [String]) -> [String] {
        var encrypted: [String] = []
        for n in number {
            encrypted.append(CryptoHelper.encrypt(n, key: key))
        }
        
        return encrypted
    }
    
    // MARK: - Number decryption
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
    
    // MARK: - CVC encryption
    static func encryptCVC(_ key: String, _ cvc: String) -> String {
        return CryptoHelper.encrypt(cvc, key: key)
    }
    
    // MARK: - CVC decryption
    func getWrappedCVC(_ key: String) -> String? {
        if let cvc = cvc {
            return CryptoHelper.decrypt(cvc, key: key)
        } else {
            return nil
        }
    }
}

extension Card {
    enum Brand: String, Equatable, Codable, Hashable {
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
