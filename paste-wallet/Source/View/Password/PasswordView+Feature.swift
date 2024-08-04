//
//  PasscodeView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 2/16/24.
//

import Foundation
import SwiftKeychainWrapper
import ComposableArchitecture

@Reducer
struct PasswordFeature {
    @ObservableState
    struct State: Equatable {
        var key: String?
        var tempPassword: String?
        
        var localKey: String? = KeychainWrapper.standard.string(forKey: .password)
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
    }
}
