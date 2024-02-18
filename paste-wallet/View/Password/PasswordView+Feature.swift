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
    struct State: Equatable {
        var key: String?
        
        var tempPassword: String?
        
        var localKey: String? = {
            KeychainWrapper.standard.string(forKey: .password)
        }()
    }
    
    enum Action: Equatable {
        case setKey(String?)
        case setTempPassword(String?)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setKey(key):
                state.key = key
                return .none
                
            case let .setTempPassword(temp):
                state.tempPassword = temp
                return .none
                
            default: return .none
            }
        }
    }
}
