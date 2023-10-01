//
//  BankForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/20/23.
//

import SwiftUI
import ComposableArchitecture

struct BankForm: View {
    let store: StoreOf<BankFormFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("new_bank_section_information") {
                    TextField("new_bank_name", text: viewStore.binding(get: \.name, send: BankFormFeature.Action.setName))
                        .submitLabel(.next)
                    
                    TextField("new_bank_issuer", text: viewStore.binding(get: \.bankName, send: BankFormFeature.Action.setBankName))
                        .submitLabel(.next)
                    
                    ColorPicker("new_bank_color", selection: viewStore.binding(get: \.color, send: BankFormFeature.Action.setColor))
                        .submitLabel(.next)
                }
                
                Section("new_bank_section_number") {
                    TextField("new_bank_number", text: viewStore.binding(get: \.accountNumber, send: { value in
                        if let filtered = Int(value.filter { $0.isNumber || $0 == "-" }) {
                            return .setAccountNumber(String(filtered))
                        } else {
                            return .setAccountNumber("")
                        }
                    }))
                    .keyboardType(.decimalPad)
                    .submitLabel(.done)
                }
                
                Section("new_bank_section_memo") {
                    TextEditor(text: viewStore.binding(get: \.memo, send: BankFormFeature.Action.setMemo))
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(viewStore.bank == nil ? "new_bank" : "bank_edit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        viewStore.send(.save)
                        dismiss()
                    }
                    .disabled(viewStore.confirmButtonDisabled)
                    .opacity(viewStore.confirmButtonDisabled ? 0.7 : 1)
                }
                
                if viewStore.bank == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    
    return NavigationStack {
        BankForm(store: Store(initialState: BankFormFeature.State(key: "000000"), reducer: {
            BankFormFeature()
        }))
    }
}
