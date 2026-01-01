//
//  MemoDetailView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/29/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct MemoDetailView: View {
    @Bindable var store: StoreOf<MemoDetailFeature>
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 8) {
                    HStack {
                        Text(store.memo.title)
                            .font(.title)
                        Spacer()
                    }
                    HStack {
                        Text(store.memo.desc)
                            .font(.body)
                        Spacer()
                    }
                }
                .padding(4)
            }
            
            if let fields = store.memo.fields, !fields.isEmpty {
                ForEach(fields, id: \.id) { field in
                    Section(field.title) {
                        HStack {
                            Text(field.decrypt(store.key))
                                .textSelection(.enabled)
                                .overlay {
                                    if store.locked {
                                        Rectangle()
                                            .fill(.thinMaterial)
                                    }
                                }
                            Spacer()
                        }
                    }
                }
            } else {
                Section {
                    Text("memo_fields_empty")
                        .foregroundStyle(Colors.textTertiary.color)
                }
            }
            
            Section {
                Button(role: .destructive) {
                    store.send(.showDeleteConfirmation(true))
                } label: {
                    Label("delete", systemImage: "trash")
                        .foregroundStyle(Color.red)
                }
                .alert(
                    "delete_confirmation_title",
                    isPresented: $store.showDeleteConfirmation
                ) {
                    Button("cancel", role: .cancel) {
                        store.send(.showDeleteConfirmation(false))
                    }
                    Button("delete", role: .destructive) {
                        store.send(.delete)
                    }
                } message: {
                    Text("delete_confirmation_message")
                }
                .disabled(store.locked)
            }
        }
        .onAppear {
            if store.biometricAvailable {
                store.send(.unlock)
            }
        }
        .onDisappear {
            store.send(.setLock(true))
        }
        .navigationTitle(store.memo.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if store.locked {
                    Button("unlock", systemImage: "lock") {
                        store.send(.unlock)
                    }
                } else {
                    Button("lock", systemImage: "lock.open") {
                        store.send(.lock)
                    }
                }
            }
            
            ToolbarItem {
                if !store.locked {
                    Button("edit") {
                        store.send(.showMemoForm)
                    }
                }
            }
        }
        .navigationDestination(
            item: $store.scope(
                state: \.memoForm,
                action: \.memoForm
            )
        ) { store in
            MemoForm(store: store)
        }
    }
}
