//
//  Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 2/16/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var key: String? = nil
        var splashFinished: Bool = false
        var openByWidgetCard: String? = nil
        var openByWidgetBank: String? = nil
        
        var wallet: WalletFeature.State?
        var password: AuthenticationFeature.State? = .init()
    }
    
    enum Action {
        case setKey(String?)
        case splashFinished(Bool)
        case initView
        case openByWidgetCard(String)
        case openByWidgetBank(String)
        
        case wallet(WalletFeature.Action)
        case password(AuthenticationFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setKey(key):
                state.key = key
                return .send(.initView)
                
            case let .splashFinished(finished):
                state.splashFinished = finished
                return .none
                
            case .initView:
                if let key = state.key {
                    state.wallet = .init(key: key)
                    state.password = nil
                } else {
                    state.wallet = nil
                    state.password = .init()
                }
                return .none
                
            case .openByWidgetCard(let id):
                state.openByWidgetBank = nil
                state.openByWidgetCard = id
                return .none
                
            case .openByWidgetBank(let id):
                state.openByWidgetCard = nil
                state.openByWidgetBank = id
                return .none
                
            case let .password(.setKey(key)):
                state.key = key
                return .send(.initView)
                
            default: return .none
            }
        }
        .ifLet(\.wallet, action: \.wallet) {
            WalletFeature()
        }
        .ifLet(\.password, action: \.password) {
            AuthenticationFeature()
        }
    }
}
