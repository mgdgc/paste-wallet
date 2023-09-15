//
//  Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import ComposableArchitecture

struct CardFeature: Reducer {
    
    struct State: Equatable {
        let modelContext: ModelContext
        let key: String
        
        var cards: [Card] = []
        
        // 새로운 카드 추가 View
        var showAddView: Bool = false
        
        // 카드 Drag and drop
        var draggingItem: Card?
        
        var showCardView: Card?
    }
    
    enum Action: Equatable {
        case fetchAll
        case showAddView(show: Bool)
        case copy(card: Card, separator: Card.SeparatorStyle)
        case delete(card: Card)
        case showCardView(card: Card?)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchAll:
            state.cards = Card.fetchAll(modelContext: state.modelContext)
            print("cards \(state.cards.count)")
            return .none
            
        case let .showAddView(show):
            state.showAddView = show
            return .none
            
        case let .copy(card, separator):
            let number = card.getWrappedNumber(state.key, separator)
            UIPasteboard.general.setValue(number, forPasteboardType: UTType.plainText.identifier)
            return .none
            
        case let .delete(card):
            state.modelContext.delete(card)
            return .send(.fetchAll)
            
        case let .showCardView(card):
            state.showCardView = card
            return .none
        }
    }
    
}
