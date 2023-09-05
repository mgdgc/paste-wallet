//
//  CardForm+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/5/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct CardFormFeature: Reducer {
    
    struct State: Equatable {
        var name: String = ""
        var issuer: String = ""
        var brand: Card.Brand = .visa
        var color: Color = Color.white
        var number: [String] = ["", "", "", ""]
        var year: Int?
        var month: Int?
        var cvc: String?
        var memo: String?
    }
    
    enum Action: Equatable {
        case nameChanged(text: String)
        case issuerChanged(text: String)
        case brandChanged(brand: Card.Brand)
        case colorChanged(color: Color)
        case numberChanged(index: Int, number: String)
        case yearChanged(year: Int?)
        case monthChanged(month: Int?)
        case cvcChanged(cvc: String)
        case memoChanged(memo: String)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .nameChanged(text):
            state.name = text
            return .none
            
        case let .issuerChanged(text):
            state.issuer = text
            return .none
            
        case let .brandChanged(brand):
            state.brand = brand
            if brand == .amex {
                state.number = ["", "", ""]
            } else {
                state.number = ["", "", "", ""]
            }
            return .none
            
        case let .colorChanged(color):
            state.color = color
            return .none
            
        case let .numberChanged(index, number):
            state.number[index] = number
            return .none
            
        case let .yearChanged(year):
            state.year = year
            return .none
            
        case let .monthChanged(month):
            state.month = month
            return .none
            
        case let .cvcChanged(cvc):
            state.cvc = cvc.isEmpty ? nil : cvc
            return .none
            
        case let .memoChanged(memo):
            state.memo = memo
            return .none
            
        }
    }
}
