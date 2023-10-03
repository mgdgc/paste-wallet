//
//  PasswordResetView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 10/3/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture
import SwiftKeychainWrapper

struct PasswordResetFeature: Reducer {
    
    struct State: Equatable {
        let modelContext = PasteWalletApp.sharedModelContext
        let key: String
        // Passcode
        var newPasscode: String = ""
        var newPasscodeCheck: String = ""
        var passcodeValid: Bool {
            (newPasscode.count == 6 && newPasscodeCheck.count == 6) && (newPasscode == newPasscodeCheck) && (newPasscode.allSatisfy({ $0.isNumber }))
        }
        var passwordChangedSuccessfully: Bool = false
        var showPasscodeChangeResult: Bool = false
    }
    
    enum Action: Equatable {
        // Passcode
        case setNewPasscode(String)
        case setNewPasscodeCheck(String)
        case changePasscode
        case showPasscodeChangeResult(Bool)
        case passwordChanged(Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setNewPasscode(passcode):
            state.newPasscode = passcode
            return .none
            
        case let .setNewPasscodeCheck(passcode):
            state.newPasscodeCheck = passcode
            return .none
            
        case .changePasscode:
            if state.newPasscode.count == 6 && state.newPasscode.allSatisfy({ $0.isNumber }) {
                Card.changePasscode(modelContext: state.modelContext, oldKey: state.key, newKey: state.newPasscode)
                Bank.changePasscode(modelContext: state.modelContext, oldKey: state.key, newKey: state.newPasscode)
                
                KeychainWrapper.standard[.password] = state.newPasscode
                state.passwordChangedSuccessfully = true
            } else {
                state.passwordChangedSuccessfully = false
            }
            state.newPasscode = ""
            state.newPasscodeCheck = ""
            return .send(.showPasscodeChangeResult(true))
            
        case let .showPasscodeChangeResult(show):
            state.showPasscodeChangeResult = show
            return .none
            
        case let .passwordChanged(success):
            return .none
        }
    }
}

