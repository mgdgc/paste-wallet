//
//  CardVO.swift
//  paste-wallet-widgetExtension
//
//  Created by 최명근 on 9/14/23.
//

import Foundation

struct CardVO: Identifiable, Equatable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var issuer: String?
    var brand: Card.Brand
    var color: String
    var number: [String]
    var year: Int
    var month: Int
    var cvc: String?
    var memo: String?
    var touch: Date
    var favorite: Bool
    
    static var previewItem = CardVO(id: UUID(), name: "Zero Edition 2", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["1234", "5678", "9012", "3456"], year: 24, month: 01, cvc: "456", memo: nil, touch: Date(), favorite: false)
}
