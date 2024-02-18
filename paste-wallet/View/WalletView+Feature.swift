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
import SwiftKeychainWrapper

@Reducer
struct WalletFeature {
    struct State: Equatable {
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
        var key: String
        var selected: WalletView.Tab = .init(rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.Settings.firstTab) ?? "favorite") ?? .favorite
        var showPasscodeView: Bool = true
        
        var openByWidgetCard: String?
        var openByWidgetBank: String?
        
        @PresentationState var favorite: FavoriteFeature.State?
        @PresentationState var card: CardFeature.State?
        @PresentationState var bank: BankFeature.State?
        @PresentationState var memo: MemoFeature.State?
        @PresentationState var settings: SettingsFeature.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case select(_ tab: WalletView.Tab)
        case setKey(String)
        case openByWidget
        case initChildStates
        case deinitChildStates
        case setOpenByWidgetCard(String)
        case setOpenByWidgetBank(String)
        
        case favorite(PresentationAction<FavoriteFeature.Action>)
        case card(PresentationAction<CardFeature.Action>)
        case bank(PresentationAction<BankFeature.Action>)
        case memo(PresentationAction<MemoFeature.Action>)
        case settings(PresentationAction<SettingsFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.initChildStates)
                    await send(.openByWidget)
                }
                
            case let .select(tab):
                state.selected = tab
                state.favorite?.tab = tab
                return .none
                
            case let .setKey(key):
                state.key = key
                return .none
                
            case .openByWidget:
                if state.openByWidgetCard != nil {
                    return .send(.select(.card))
                } else if state.openByWidgetBank != nil {
                    return .send(.select(.bank))
                } else {
                    return .none
                }
                
            case .initChildStates:
                state.favorite = .init(key: state.key)
                state.card = .init(key: state.key, openByWidget: state.openByWidgetCard)
                state.bank = .init(key: state.key, openByWidget: state.openByWidgetBank)
                state.memo = .init(key: state.key)
                state.settings = .init(key: state.key)
                return .none
                
            case .deinitChildStates:
                state.favorite = nil
                state.card = nil
                state.bank = nil
                state.memo = nil
                state.settings = nil
                return .none
                
            case let .setOpenByWidgetCard(id):
                state.openByWidgetCard = id
                return .send(.initChildStates)
                
            case let .setOpenByWidgetBank(id):
                state.openByWidgetBank = id
                return .send(.initChildStates)
                
            case let .favorite(action):
                return handleFavoriteAction(&state, action)
                
            case .settings(.presented(.passwordChanged)):
                return .none
                
            default:
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
        .ifLet(\.$memo, action: /Action.memo) {
            MemoFeature()
        }
        .ifLet(\.$settings, action: /Action.settings) {
            SettingsFeature()
        }
    }
    
    private func handleFavoriteAction(_ state: inout State, _ action: PresentationAction<FavoriteFeature.Action>) -> Effect<Action> {
        switch action {
        case .presented(.setTab(let tab)):
            state.selected = tab
            return .none
            
        default:
            return .none
        }
    }
}
