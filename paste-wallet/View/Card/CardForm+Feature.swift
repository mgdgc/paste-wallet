//
//  CardForm+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/5/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

struct CardFormFeature: Reducer {
    
    struct State: Equatable {
        let modelContext: ModelContext
        var card: Card?
        let key: String
        
        var name: String?
        var issuer: String?
        var brand: Card.Brand = .visa
        var color: Color = Color.white
        var number: [String] = ["", "", "", ""]
        var year: Int?
        var month: Int?
        var cvc: String?
        var memo: String?
        var dismiss: Bool = false
        
        var confirmButtonDisabled: Bool {
            name == nil ||
            issuer == nil ||
            year == nil ||
            month == nil ||
            cvc == nil
        }
        
        init(modelContext: ModelContext = PasteWalletApp.sharedModelContext, key: String, card: Card? = nil) {
            self.modelContext = modelContext
            self.card = card
            self.key = key
            if let card = card {
                self.name = card.name
                self.issuer = card.issuer
                self.brand = Card.Brand(rawValue: card.brand) ?? .etc
                self.color = Color(hexCode: card.color)
                self.number = card.decryptNumber(key: key)
                self.year = card.year
                self.month = card.month
                self.cvc = card.getWrappedCVC(key)
                self.memo = card.memo
            }
        }
    }
    
    enum Action: Equatable {
        case nameChanged(text: String?)
        case issuerChanged(text: String?)
        case brandChanged(brand: Card.Brand)
        case colorChanged(color: Color)
        case numberChanged(index: Int, number: String)
        case yearChanged(year: Int?)
        case monthChanged(month: Int?)
        case cvcChanged(cvc: String?)
        case memoChanged(memo: String?)
        case save
        case saveContext
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
            if let cvc = cvc {
                state.cvc = cvc.isEmpty ? nil : cvc
            } else {
                state.cvc = nil
            }
            
            return .none
            
        case let .memoChanged(memo):
            state.memo = memo
            return .none
            
        case .save:
            if let name = state.name, let issuer = state.issuer, let year = state.year, let month = state.month {
                if state.card != nil {
                    state.card?.name = name
                    state.card?.issuer = issuer
                    state.card?.brand = state.brand.rawValue
                    state.card?.color = state.color.hex
                    state.card?.number = Card.encryptNumber(state.key, state.number)
                    state.card?.year = year
                    state.card?.month = month
                    state.card?.cvc = state.cvc == nil ? nil : Card.encryptCVC(state.key, state.cvc!)
                    state.card?.memo = state.memo
                    
                } else {
                    let card = Card(
                        name: name,
                        issuer: issuer,
                        brand: state.brand,
                        color: state.color.hex,
                        number: Card.encryptNumber(state.key, state.number),
                        year: year,
                        month: month,
                        cvc: state.cvc == nil ? nil : Card.encryptCVC(state.key, state.cvc!),
                        memo: state.memo
                    )
                    
                    state.modelContext.insert(card)
                }
                
                return .send(.saveContext)
                
            }
            
            return .none
            
        case .saveContext:
            do {
                try state.modelContext.save()
            } catch {
                print(#function, error)
            }
            return .none
        }
    }
}
