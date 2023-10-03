//
//  PasswordResetView.swift
//  paste-wallet
//
//  Created by 최명근 on 10/3/23.
//

import SwiftUI
import ComposableArchitecture

struct PasswordResetView: View {
    let store: StoreOf<PasswordResetFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField("settings_privacy_new_passcode", text: viewStore.binding(get: \.newPasscode, send: { value in
                        var text = value.filter { $0.isNumber }
                        text = String(text[text.startIndex..<text.index(text.startIndex, offsetBy: text.count < 6 ? text.count : 6)])
                        return .setNewPasscode(text)
                    }))
                    .keyboardType(.numberPad)
                    .submitLabel(.next)
                    
                    TextField("settings_privacy_new_passcode_check", text: viewStore.binding(get: \.newPasscodeCheck, send: { value in
                        var text = value.filter { $0.isNumber }
                        text = String(text[text.startIndex..<text.index(text.startIndex, offsetBy: text.count < 6 ? text.count : 6)])
                        return .setNewPasscodeCheck(text)
                    }))
                    .keyboardType(.numberPad)
                    .submitLabel(.done)
                    
                } header: {
                    Text("settings_privacy_change_passcode")
                    
                } footer: {
                    Text("settings_privacy_new_passcode_message")
                }
                
                Button {
                    viewStore.send(.changePasscode)
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("confirm")
                        Spacer()
                    }
                }
                .disabled(!viewStore.passcodeValid)
                .alert("settings_privacy_change_passcode", isPresented: viewStore.binding(get: \.showPasscodeChangeResult, send: PasswordResetFeature.Action.showPasscodeChangeResult)) {
                    Button("confirm") {
                        viewStore.send(.passwordChanged(viewStore.passwordChangedSuccessfully))
                    }
                } message: {
                    Text(viewStore.passwordChangedSuccessfully ? "settings_privacy_change_passcode_success" : "settings_privacy_change_passcode_fail")
                }
            }
        }
    }
}

#Preview {
    PasswordResetView(store: Store(initialState: PasswordResetFeature.State(key: "000000"), reducer: {
        PasswordResetFeature()
    }))
}
