//
//  MemoForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import SwiftUI
import ComposableArchitecture

struct MemoFormField: Equatable {
    var fieldName: String = ""
    var value: String = ""
}

struct MemoForm: View {
    let store: StoreOf<MemoFormFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("new_memo_section_information") {
                    TextField("new_memo_title", text: viewStore.binding(get: \.title, send: MemoFormFeature.Action.setTitle))
                    TextField("new_memo_desc", text: viewStore.binding(get: \.desc, send: MemoFormFeature.Action.setDesc))
                }
                
                ForEach(viewStore.fields.indices, id: \.self) { i in
                    Section(String("\("new_memo_section_fields".localized) \(i + 1)")) {
                        HStack(spacing: 16) {
                            VStack {
                                TextField("new_memo_fieldname", text: viewStore.binding(get: { $0.fields[i].fieldName }, send: { .setField(i, \.fieldName, $0) }))
                                Divider()
                                TextField("new_memo_value", text: viewStore.binding(get: { $0.fields[i].value }, send: { .setField(i, \.value, $0) }))
                            }
                            
                            Button(role: .destructive) {
                                viewStore.send(.deleteField(i))
                            } label: {
                                Label("delete", systemImage: "minus.circle.fill")
                                    .labelStyle(IconOnlyLabelStyle())
                            }
                        }
                    }
                }
                
                Section {
                    Button("add", systemImage: "plus.circle") {
                        viewStore.send(.addField)
                    }
                }
            }
            .navigationTitle("memo_form")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        viewStore.send(.save)
                    }
                    .disabled(viewStore.confirmButtonDisabled)
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        MemoForm(store: Store(initialState: MemoFormFeature.State(key: "000000"), reducer: {
            MemoFormFeature()
        }))
    }
}
