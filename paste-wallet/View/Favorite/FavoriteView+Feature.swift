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
        let modelContext: ModelContext
        var key: String?
        var tab: WalletView.Tab
        
        var cards: [Card] = []
    }
    
    enum Action: Equatable {
        case fetchCard
        case setTab(WalletView.Tab)
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
            }
        }
    }
}
