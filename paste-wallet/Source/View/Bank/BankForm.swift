//
//  BankForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/20/23.
//

import SwiftUI
import ComposableArchitecture

struct BankForm: View {
    @Bindable var store: StoreOf<BankFormFeature>
    
    var body: some View {
        Form {
            Section("new_bank_section_information") {
                TextField(
                    "new_bank_name",
                    text: $store.name
                )
                .submitLabel(.next)
                
                TextField(
                    "new_bank_issuer",
                    text: $store.bankName
                )
                .submitLabel(.next)
                
                ColorPicker(
                    "new_bank_color",
                    selection: $store.color
                )
                .submitLabel(.next)
            }
            
            Section("new_bank_section_number") {
                TextField(
                    "new_bank_number",
                    text: $store.accountNumber.sending(\.setAccountNumber)
                )
                .keyboardType(.numbersAndPunctuation)
                .submitLabel(.done)
            }
            
            Section("new_bank_section_memo") {
                TextEditor(text: $store.memo)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle(store.bank == nil ? "new_bank" : "bank_edit")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("save") {
                    store.send(.save)
                }
                .disabled(store.confirmButtonDisabled)
                .opacity(store.confirmButtonDisabled ? 0.7 : 1)
            }
            
            if store.bank == nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        store.send(.dismiss)
                    }
                }
            }
        }
    }
}
