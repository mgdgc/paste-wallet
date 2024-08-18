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
    @ObservableState
    struct State: Equatable {
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
        var key: String
        var selectedTab: WalletView.Tab = .init(
            rawValue: UserDefaults.standard.string(
                forKey: UserDefaultsKey.Settings.firstTab
            ) ?? "favorite") ?? .favorite
        var showPasscodeView: Bool = true
        
        var openByWidgetCard: String?
        var openByWidgetBank: String?
        
        var favorite: FavoriteFeature.State
        var card: CardFeature.State
        var bank: BankFeature.State
        var memo: MemoFeature.State
        var settings: SettingsFeature.State
        
        init(key: String) {
            self.key = key
            favorite = .init(key: key)
            card = .init(key: key)
            bank = .init(key: key)
            memo = .init(key: key)
            settings = .init(key: key)
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case setKey(String)
        case openByWidget
        case setOpenByWidgetCard(String)
        case setOpenByWidgetBank(String)
        
        case favorite(FavoriteFeature.Action)
        case card(CardFeature.Action)
        case bank(BankFeature.Action)
        case memo(MemoFeature.Action)
        case settings(SettingsFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.favorite, action: \.favorite) {
            FavoriteFeature()
        }
        Scope(state: \.card, action: \.card) {
            CardFeature()
        }
        Scope(state: \.bank, action: \.bank) {
            BankFeature()
        }
        Scope(state: \.memo, action: \.memo) {
            MemoFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
        Reduce { state, action in
            switch action {
            case let .setKey(key):
                state.key = key
                return .none
                
            case .openByWidget:
                if state.openByWidgetCard != nil {
                    state.selectedTab = .card
                    return .none
                } else if state.openByWidgetBank != nil {
                    state.selectedTab = .bank
                    return .none
                } 
                return .none
                
            case let .setOpenByWidgetCard(id):
                state.openByWidgetCard = id
                return .none
                
            case let .setOpenByWidgetBank(id):
                state.openByWidgetBank = id
                return .none
                
            case let .favorite(.setTab(tab)):
                state.selectedTab = tab
                return .none
                
//            case .settings(.passwordChanged):
//                return .none
                
            default:
                return .none
            }
        }
    }
}
