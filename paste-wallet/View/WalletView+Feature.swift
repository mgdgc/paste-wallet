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
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
        var key: String? = nil
        var selected: WalletView.Tab = .favorite
        
        @PresentationState var favorite: FavoriteFeature.State?
        @PresentationState var card: CardFeature.State?
        @PresentationState var bank: BankFeature.State?
    }
    
    enum Action: Equatable {
        case select(_ tab: WalletView.Tab)
        case setKey(_ key: String?)
        case initChildStates(_ key: String)
        case deinitChildStates
        
        case favorite(PresentationAction<FavoriteFeature.Action>)
        case card(PresentationAction<CardFeature.Action>)
        case bank(PresentationAction<BankFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .select(tab):
                state.selected = tab
                state.favorite?.tab = tab
                return .none
                
            case let .setKey(key):
                state.key = key
                if let key = key {
                    return .send(.initChildStates(key))
                } else {
                    return .send(.deinitChildStates)
                }
                
            case let .initChildStates(key):
                state.favorite = .init(key: key)
                state.card = .init(key: key)
                state.bank = .init(key: key)
                return .none
                
            case .deinitChildStates:
                state.favorite = nil
                state.card = nil
                state.bank = nil
                return .none
                
            case let .favorite(action):
                return .none
                
            case let .card(action):
                return .none
                
            case let .bank(action):
                return .none
            }
        }
        .ifLet(\.$favorite, action: /Action.favorite) {
            FavoriteFeature()
        }
        .ifLet(\.$card, action: /Action.card) {
            CardFeature()
        }
        .ifLet(\.$bank, action: /Action.bank) {
            BankFeature()
        }
    }
}
