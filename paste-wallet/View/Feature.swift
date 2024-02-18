//
//  Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 2/16/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Feature {
    struct State: Equatable {
        var key: String? = nil
        var splashFinished: Bool = false
        var openByWidgetCard: String? = nil
        var openByWidgetBank: String? = nil
        
        @PresentationState var wallet: WalletFeature.State?
        @PresentationState var password: PasswordFeature.State? = .init()
    }
    
    enum Action: Equatable {
        case setKey(String?)
        case splashFinished(Bool)
        case initView
        
        case wallet(PresentationAction<WalletFeature.Action>)
        case password(PresentationAction<PasswordFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setKey(key):
                state.key = key
                return .none
                
            case .initView:
                if let key = state.key {
                    state.wallet = .init(key: key, openByWidgetCard: state.openByWidgetCard, openByWidgetBank: state.openByWidgetBank)
                    state.password = nil
                } else {
                    state.wallet = nil
                    state.password = .init()
                }
                return .none
                
            case let .splashFinished(finished):
                state.splashFinished = finished
                return .none
                
            case let .wallet(walletAction):
                return handleWallet(state: &state, action: walletAction)
                
            case let .password(passwordAction):
                return handlePassword(state: &state, action: passwordAction)
                
            default: return .none
            }
        }
        .ifLet(\.$wallet, action: /Action.wallet) {
            WalletFeature()
        }
        .ifLet(\.$password, action: /Action.password) {
            PasswordFeature()
        }
    }
    
    private func handlePassword(state: inout State, action: PresentationAction<PasswordFeature.Action>) -> Effect<Action> {
        switch action {
        case let .presented(.setKey(key)):
            state.key = key
            return .send(.initView)
            
        default: return .none
        }
    }
    
    private func handleWallet(state: inout State, action: PresentationAction<WalletFeature.Action>) -> Effect<Action> {
        switch action {
        default: return .none
        }
    }
}
