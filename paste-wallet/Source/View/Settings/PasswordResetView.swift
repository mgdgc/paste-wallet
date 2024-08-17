//
//  PasswordResetView.swift
//  paste-wallet
//
//  Created by 최명근 on 10/3/23.
//

import SwiftUI
import ComposableArchitecture

struct PasswordResetView: View {
    @Bindable var store: StoreOf<PasswordResetFeature>
    
    var body: some View {
        Form {
            Section {
                TextField(
                    "settings_privacy_new_passcode",
                    text: Binding(
                        get: { store.newPasscode },
                        set: { value in
                            var text = value.filter { $0.isNumber }
                            text = String(
                                text[text.startIndex..<text.index(
                                    text.startIndex,
                                    offsetBy: text.count < 6 ? text.count : 6
                                )]
                            )
                            store.send(.setNewPasscode(text))
                        }
                    )
                )
                .keyboardType(.numberPad)
                .submitLabel(.next)
                
                TextField(
                    "settings_privacy_new_passcode_check",
                    text: Binding(
                        get: { store.newPasscodeCheck },
                        set: { value in
                            var text = value.filter { $0.isNumber }
                            text = String(
                                text[text.startIndex..<text.index(
                                    text.startIndex,
                                    offsetBy: text.count < 6 ? text.count : 6
                                )]
                            )
                            store.send(.setNewPasscodeCheck(text))
                        }
                    )
                )
                .keyboardType(.numberPad)
                .submitLabel(.done)
            } header: {
                Text("settings_privacy_change_passcode")
            } footer: {
                Text("settings_privacy_new_passcode_message")
            }
            
            Button {
                store.send(.changePasscode)
            } label: {
                HStack {
                    Spacer()
                    Text("confirm")
                    Spacer()
                }
            }
            .disabled(!store.passcodeValid)
        }
        .alert(
            "settings_privacy_change_passcode",
            isPresented: $store.showPasscodeChangeResult
        ) {
            Button("confirm") {
                store.send(
                    .passwordChanged(
                        store.passwordChangedSuccessfully
                    )
                )
            }
        } message: {
            Text(
                store.passwordChangedSuccessfully ?
                "settings_privacy_change_passcode_success" :
                    "settings_privacy_change_passcode_fail"
            )
        }
    }
}
