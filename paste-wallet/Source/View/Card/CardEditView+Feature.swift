////
////  CardEditView+Feature.swift
////  paste-wallet
////
////  Created by 최명근 on 10/1/23.
////
//
//import Foundation
//import SwiftUI
//import SwiftData
//import ComposableArchitecture
//
//struct CardEditFeature: Reducer {
//    
//    struct State: Equatable {
//        var modelContext = PasteWalletApp.sharedModelContext
//        let key: String
//        var card: Card
//        
//        var wrappedNumber: [String] {
//            card.decryptNumber(key: key)
//        }
//    }
//    
//    enum Action: Equatable {
//        case setName(String)
//        case setIssuer(String)
//        case setBrand(Card.Brand)
//        case setColor(Color)
//        case setNumber(_ index: Int, _ value: String)
//        case setMonth(Int)
//        case setYear(Int)
//        case setCVC(String?)
//        case setMemo(String?)
//        case save
//    }
//    
//    func reduce(into state: inout State, action: Action) -> Effect<Action> {
//        switch action {
//        case let .setName(name):
//            state.card.name = name
//            return .send(.save)
//            
//        case let .setIssuer(issuer):
//            state.card.issuer = issuer
//            return .send(.save)
//            
//        case let .setBrand(brand):
//            state.card.brand = brand.rawValue
//            if brand == .amex {
//                while state.card.number.count > 3 {
//                    state.card.number.removeLast()
//                }
//            } else {
//                while state.card.number.count < 4 {
//                    state.card.number.append("")
//                }
//            }
//            return .send(.save)
//            
//        case let .setColor(color):
//            state.card.color = color.hex
//            return .send(.save)
//            
//        case let .setNumber(index, value):
//            
//            if 0..<state.card.number.count ~= index {
//                state.card.number[index] = value
//            }
//            return .send(.save)
//            
//        case let .setMonth(month):
//            state.card.month = month
//            return .send(.save)
//            
//        case let .setYear(year):
//            state.card.year = year
//            return .send(.save)
//            
//        case let .setCVC(cvc):
//            state.card.cvc = cvc
//            return .send(.save)
//            
//        case let .setMemo(memo):
//            state.card.memo = memo
//            return .send(.save)
//            
//        case .save:
//            do {
//                try state.modelContext.save()
//            } catch {
//                print(#function, error)
//            }
//            return .none
//        }
//    }
//}
