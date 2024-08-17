//
//  MemoForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import SwiftUI
import ComposableArchitecture

struct MemoFormField: Equatable, Hashable {
    var fieldName: String = ""
    var value: String = ""
}

struct MemoForm: View {
    @Bindable var store: StoreOf<MemoFormFeature>
    
    var body: some View {
        Form {
            Section("new_memo_section_information") {
                TextField(
                    "new_memo_title",
                    text: $store.title
                )
                TextField(
                    "new_memo_desc",
                    text: $store.desc
                )
            }
            
            ForEach(store.fields.indices, id: \.self) { i in
                Section(
                    String("\("new_memo_section_fields".localized) \(i + 1)")
                ) {
                    HStack(spacing: 16) {
                        VStack {
                            TextField(
                                "new_memo_fieldname",
                                text: Binding(
                                    get: { store.fields[safe: i]?.fieldName ?? "" },
                                    set: { store.send(.setMemoFieldTitle(i, $0)) }
                                )
                            )
                            
                            Divider()
                            
                            TextField(
                                "new_memo_value",
                                text: Binding(
                                    get: { store.fields[safe: i]?.value ?? "" },
                                    set: { store.send(.setMemoFieldValue(i, $0)) }
                                )
                            )
                        }
                        
                        Button(role: .destructive) {
                            store.send(.deleteField(i))
                        } label: {
                            Label("delete", systemImage: "minus.circle.fill")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
            
            Section {
                Button("add", systemImage: "plus.circle") {
                    store.send(.addField)
                }
            }
        }
        .navigationTitle(store.memo == nil ? "memo_form" : "memo_edit")
        .toolbar {
            if store.memo == nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        store.send(.dismiss)
                    }
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("save") {
                    store.send(.save)
                }
                .disabled(!store.confirmButtonEnabled)
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
}
