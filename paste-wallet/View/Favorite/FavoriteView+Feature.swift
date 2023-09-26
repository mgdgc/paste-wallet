//
//  FavoriteView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/12/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

struct FavoriteFeature: Reducer {
    struct State: Equatable {
        let modelContext: ModelContext = ModelContext(PasteWalletApp.sharedModelContainer)
        let key: String
        var tab: WalletView.Tab = .favorite
        
        var cards: [Card] = []
        
        @PresentationState var cardDetail: CardDetailFeature.State?
    }
    
    enum Action: Equatable {
        case fetchCard
        case setTab(WalletView.Tab)
        case showCardDetail(Card)
        
        case cardDetail(PresentationAction<CardDetailFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchCard:
                state.cards = Card.fetchFavorite(modelContext: state.modelContext)
                return .none
                
            case let .setTab(tab):
                state.tab = tab
                return .none
                
            case let .showCardDetail(card):
                state.cardDetail = .init(key: state.key, card: card)
                return .none
                
            case let .cardDetail(action):
                return .none
            }
        }
        .ifLet(\.$cardDetail, action: /Action.cardDetail) {
            CardDetailFeature()
        }
    }
}
