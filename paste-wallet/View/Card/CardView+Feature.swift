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
        let modelContext: ModelContext = ModelContext(PasteWalletApp.sharedModelContainer)
        let key: String
        
        // Fetch Data
        var cards: [Card] = []
        // 카드 Drag and drop
        var draggingItem: Card?
        
        var showCardView: Card?
        
        @PresentationState var cardForm: CardFormFeature.State?
        @PresentationState var cardDetail: CardDetailFeature.State?
    }
    
    enum Action: Equatable {
        case fetchAll
        case copy(card: Card, separator: Card.SeparatorStyle)
        case delete(card: Card)
        case showCardForm
        case showCardDetail(card: Card)
        
        case cardForm(PresentationAction<CardFormFeature.Action>)
        case cardDetail(PresentationAction<CardDetailFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchAll:
                state.cards = Card.fetchAll(modelContext: state.modelContext)
                print("cards \(state.cards.count)")
                return .none
                
            case .showCardForm:
                state.cardForm = .init(key: state.key)
                return .none
                
            case let .copy(card, separator):
                let number = card.getWrappedNumber(state.key, separator)
                UIPasteboard.general.setValue(number, forPasteboardType: UTType.plainText.identifier)
                return .none
                
            case let .delete(card):
                state.modelContext.delete(card)
                return .send(.fetchAll)
                
            case let .showCardDetail(card):
                state.cardDetail = .init(key: state.key, card: card)
                return .none
                
            case let .cardForm(action):
                return .none
                
            case let .cardDetail(action):
                return .none
            }
        }
        .ifLet(\.$cardForm, action: /Action.cardForm) {
            CardFormFeature()
        }
        .ifLet(\.$cardDetail, action: /Action.cardDetail) {
            CardDetailFeature()
        }
    }
    
}
