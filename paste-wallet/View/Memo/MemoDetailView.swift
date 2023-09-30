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
                Section("memo_fields") {
                    if let fields = viewStore.memo.fields, !fields.isEmpty {
                        ForEach(fields, id: \.id) { field in
                            HStack {
                                Text(field.title)
                                Spacer()
                                Text(field.value)
                            }
                        }
                    } else {
                        Text("memo_fields_empty")
                            .foregroundStyle(Colors.textTertiary.color)
                    }
                }
                
                Section {
//                    Button("memo_favorite", systemImage: viewStore.bank.favorite ? "star.fill" : "star") {
//                        viewStore.send(.setFavorite)
//                    }
                    
                    Button("delete", systemImage: "trash") {
                        viewStore.send(.delete)
                    }
                    .foregroundStyle(Color.red)
                }
            }
            .navigationTitle(String(viewStore.memo.title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(String(viewStore.memo.title))
                            .font(.headline)
                        Text(String(viewStore.memo.desc))
                            .font(.subheadline)
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
        MemoField(title: "Field 1", value: "12343245"),
        MemoField(title: "Field 2", value: "928472")
    ]
    modelContext.insert(memo)
    
    return NavigationStack {
        MemoDetailView(store: Store(initialState: MemoDetailFeature.State(modelContext: modelContext, memo: memo), reducer: {
            MemoDetailFeature()
        }))
    }
}
