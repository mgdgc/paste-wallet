//
//  MemoView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import UIKit
import SwiftUI
import SwiftData
import ComposableArchitecture

struct MemoView: View {
    let store: StoreOf<MemoFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.memos.isEmpty {
                    emptyView
                    
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewStore.memos) { memo in
                                Button {
                                    viewStore.send(.showMemoDetail(memo))
                                } label: {
                                    VStack {
                                        HStack {
                                            Text(memo.title)
                                                .font(.title2.bold())
                                            Spacer()
                                        }
                                        if !memo.desc.isEmpty {
                                            HStack {
                                                Text(memo.desc)
                                                    .font(.subheadline)
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Colors.backgroundPrimary.color)
                                            .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                                    }
                                    .foregroundStyle(Colors.textPrimary.color)
                                }
                            }
                        }
                        .padding()
                        .navigationDestination(store: store.scope(state: \.$memoDetail, action: MemoFeature.Action.memoDetail)) { store in
                            MemoDetailView(store: store)
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.fetchAll)
            }
            .navigationTitle("tab_memo")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.showMemoForm)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Colors.textPrimary.color)
                    }
                    .sheet(store: store.scope(state: \.$memoForm, action: MemoFeature.Action.memoForm)) { store in
                        NavigationStack {
                            MemoForm(store: store)
                        }
                        .interactiveDismissDisabled()
                        .onDisappear {
                            viewStore.send(.fetchAll)
                        }
                    }
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
    
    private var emptyView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Spacer()
                Image("empty_card")
                    .renderingMode(.template)
                    .resizable()
                    .frame(maxWidth: 156, maxHeight: 156)
                    .foregroundStyle(Colors.textPrimary.color)
                HStack {
                    Spacer()
                    Text("memo_empty")
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Button("bank_empty_add", systemImage: "plus") {
                    viewStore.send(.showMemoForm)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .sheet(store: store.scope(state: \.$memoForm, action: MemoFeature.Action.memoForm)) {
                    viewStore.send(.fetchAll)
                } content: { store in
                    NavigationStack {
                        MemoForm(store: store)
                    }
                    .interactiveDismissDisabled()
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    let modelContext = ModelContext(try! ModelContainer(for: Memo.self, MemoField.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
    
    let memo = Memo(title: "Memo 1", desc: "memo")
    modelContext.insert(memo)
    
    return NavigationStack {
        MemoView(store: Store(initialState: MemoFeature.State(modelContext: modelContext, key: "000000"), reducer: {
            MemoFeature()
        }))
    }
}
