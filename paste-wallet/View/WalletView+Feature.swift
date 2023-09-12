//
//  WalletView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/12/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

struct WalletFeature: Reducer {
    struct State: Equatable {
        let modelContext: ModelContext = ModelContext(try! ModelContainer(for: Card.self, Bank.self, SecurityCard.self, Memo.self))
        var key: String? = nil
        var selected: WalletView.Tab = .favorite
        
        var favorite: FavoriteFeature.State
        
        init() {
            self.favorite = FavoriteFeature.State(modelContext: modelContext, tab: selected)
        }
    }
    
    enum Action: Equatable {
        case favorite(FavoriteFeature.Action)
        case select(WalletView.Tab)
        case setKey(String?)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .favorite(action: .setTab(let tab)):
                state.selected = tab
                return .none
                
            case let .select(tab):
                state.selected = tab
                state.favorite.tab = tab
                return .none
                
            case let .setKey(key):
                state.key = key
                state.favorite.key = key
                return .none
                
            default: return .none
            }
            
        }
        Scope(state: \.favorite, action: /Action.favorite) {
            FavoriteFeature()
        }
    }
}
