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
    
    var wrappedNumber: String {
        var number = ""
        for i in self.number.indices {
            number.append("\(self.number[i])")
            if i < self.number.count - 1 {
                number.append(" ")
            }
        }
        return number
    }
    
    var wrappedNumberIncludeSeparator: String {
        var number = ""
        for i in self.number.indices {
            number.append("\(self.number[i])")
            if i < self.number.count - 1 {
                number.append("-")
            }
        }
        return number
    }
    
    var wrappedNumberWithoutSeparator: String {
        var number = ""
        for i in self.number.indices {
            number.append("\(self.number[i])")
        }
        return number
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
