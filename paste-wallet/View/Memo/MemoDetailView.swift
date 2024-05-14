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
    let store: StoreOf<MemoDetailFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    VStack(spacing: 8) {
                        HStack {
                            Text(viewStore.memo.title)
                                .font(.title)
                            Spacer()
                        }
                        HStack {
                            Text(viewStore.memo.desc)
                                .font(.body)
                            Spacer()
                        }
                    }
                    .padding(4)
                }
                
                if let fields = viewStore.memo.fields, !fields.isEmpty {
                    ForEach(fields, id: \.id) { field in
                        Section(field.title) {
//                            ImmutableTextView(text: .constant(field.decrypt(viewStore.key)))
//                                .overlay {
//                                    if viewStore.locked {
//                                        Rectangle()
//                                            .fill(.thinMaterial)
//                                    }
//                                }
//                                .background {
//                                    Text(field.decrypt(viewStore.key))
//                                        .foregroundStyle(.clear)
//                                }
                            HStack {
                                Text(field.decrypt(viewStore.key))
                                    .textSelection(.enabled)
                                    .overlay {
                                        if viewStore.locked {
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
                        viewStore.send(.showDeleteConfirmation(true))
                    } label: {
                        Label("delete", systemImage: "trash")
                            .foregroundStyle(Color.red)
                    }
                    .alert("delete_confirmation_title", isPresented: viewStore.binding(get: \.showDeleteConfirmation, send: MemoDetailFeature.Action.showDeleteConfirmation)) {
                        Button("cancel", role: .cancel) {
                            viewStore.send(.showDeleteConfirmation(false))
                        }
                        Button("delete", role: .destructive) {
                            viewStore.send(.delete)
                        }
                    } message: {
                        Text("delete_confirmation_message")
                    }
                    .disabled(viewStore.locked)
                }
            }
            .onAppear {
                if viewStore.biometricAvailable {
                    viewStore.send(.unlock)
                }
            }
            .navigationTitle(String(viewStore.memo.title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if viewStore.locked {
                        Button("unlock", systemImage: "lock") {
                            viewStore.send(.unlock)
                        }
                    } else {
                        Button("lock", systemImage: "lock.open") {
                            viewStore.send(.lock)
                        }
                    }
                }
                
                ToolbarItem {
                    if !viewStore.locked {
                        Button("edit") {
                            viewStore.send(.showMemoForm)
                        }
                        .navigationDestination(store: store.scope(state: \.$memoForm, action: \.memoForm)) { store in
                            MemoForm(store: store)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let modelContext = ModelContext(try! ModelContainer(for: Memo.self, MemoField.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
    
    var memo = Memo(title: "Memo 1", desc: "What's your TCA")
    memo.fields = [
        MemoField(title: "Field 1", value: "fRA2PFBGYONOw8ZV73gujA=="),
        MemoField(title: "Field 2", value: "fRA2PFBGYONOw8ZV73gujA==")
    ]
    modelContext.insert(memo)
    
    return NavigationStack {
        MemoDetailView(store: Store(initialState: MemoDetailFeature.State(modelContext: modelContext, key: "000000", memo: memo), reducer: {
            MemoDetailFeature()
        }))
    }
}
