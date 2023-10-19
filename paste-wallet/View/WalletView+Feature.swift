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

struct WalletFeature: Reducer {
    struct State: Equatable {
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
        var key: String? = nil
        var selected: WalletView.Tab = .init(rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.Settings.firstTab) ?? "favorite") ?? .favorite
        var showPasscodeView: Bool = true
        
        var localKey: String? = {
            KeychainWrapper.standard.string(forKey: .password)
        }()
        var tempPassword: String?
        
        @PresentationState var favorite: FavoriteFeature.State?
        @PresentationState var card: CardFeature.State?
        @PresentationState var bank: BankFeature.State?
        @PresentationState var memo: MemoFeature.State?
        @PresentationState var settings: SettingsFeature.State?
    }
    
    enum Action: Equatable {
        case select(_ tab: WalletView.Tab)
        case setKey(_ key: String?)
        case initChildStates(_ key: String)
        case deinitChildStates
        case showPasscodeView(Bool)
        case setTempPassword(String?)
        
        case favorite(PresentationAction<FavoriteFeature.Action>)
        case card(PresentationAction<CardFeature.Action>)
        case bank(PresentationAction<BankFeature.Action>)
        case memo(PresentationAction<MemoFeature.Action>)
        case settings(PresentationAction<SettingsFeature.Action>)
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
                state.memo = .init(key: key)
                state.settings = .init(key: key)
                return .none
                
            case .deinitChildStates:
                state.favorite = nil
                state.card = nil
                state.bank = nil
                state.memo = nil
                state.settings = nil
                return .none
                
            case let .showPasscodeView(show):
                state.showPasscodeView = show
                return .none
                
            case let .setTempPassword(temp):
                state.tempPassword = temp
                return .none
                
            case let .favorite(action):
                return handleFavoriteAction(&state, action)
                
            case .card(_):
                return .none
                
            case .bank(_):
                return .none
                
            case .memo(_):
                return .none
                
            case .settings(.presented(.passwordChanged)):
                return .send(.setKey(nil))
                
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
