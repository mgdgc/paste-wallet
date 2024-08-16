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
    
    @Bindable var store: StoreOf<MemoFeature>
    
    var body: some View {
        VStack {
            if store.memos.isEmpty {
                emptyView()
                
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(store.memos) { memo in
                            Button {
                                store.send(.showMemoDetail(memo))
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
                                .frame(maxWidth: 560)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Colors.backgroundPrimary.color)
                                        .shadow(
                                            color: .black.opacity(0.15),
                                            radius: 8,
                                            y: 2
                                        )
                                }
                                .foregroundStyle(Colors.textPrimary.color)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            store.send(.fetchAll)
        }
        .navigationTitle("tab_memo")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.showMemoForm)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Colors.textPrimary.color)
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
        .navigationDestination(
            item: $store.scope(
                state: \.memoDetail,
                action: \.memoDetail
            )
        ) { store in
            MemoDetailView(store: store)
        }
        .sheet(
            item: $store.scope(
                state: \.memoForm,
                action: \.memoForm
            )
        ) { store in
            NavigationStack {
                MemoForm(store: store)
            }
            .interactiveDismissDisabled()
            .onDisappear {
                self.store.send(.fetchAll)
            }
        }
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
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
            Button("memo_empty_add", systemImage: "plus") {
                store.send(.showMemoForm)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            Spacer()
        }
        .padding()
    }
}
