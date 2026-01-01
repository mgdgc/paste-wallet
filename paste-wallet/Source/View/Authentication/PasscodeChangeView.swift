//
//  PasscodeChangeView.swift
//  paste-wallet
//
//  Created by 최명근 on 8/18/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct PasscodeChangeView: View {
    
    @Bindable var store: StoreOf<PasscodeChangeFeature>
    
    var body: some View {
        PasscodeView(
            initialMessage: String(localized: "password_init"),
            dismissable: true,
            enableBiometric: false,
            authenticateOnLaunch: false) { typed in
                if let newPasscode = store.newPasscode {
                    if newPasscode == typed {
                        store.send(.changePasscode(typed))
                        return .none
                    } else {
                        store.send(.setNewPasscode(nil))
                        return .retype(String(localized: "password_check_fail"))
                    }
                } else {
                    store.send(.setNewPasscode(typed))
                    return .retype(String(localized: "password_check"))
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
    }
}
