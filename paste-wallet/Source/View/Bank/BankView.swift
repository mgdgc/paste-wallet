//
//  BankView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct BankView: View {
    @Bindable var store: StoreOf<BankFeature>
    
    var body: some View {
        GeometryReader { proxy in
            if store.banks.isEmpty {
                emptyView()
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible()),
                            count: Int(proxy.size.width) / 160
                        ),
                        spacing: 20
                    ) {
                        ForEach(store.banks, id: \.id) { bank in
                            Button {
                                store.send(.playHaptic)
                                store.send(.showBankDetail(bank))
                            } label: {
                                SmallBankView(bank: bank, key: store.key)
                                    .contextMenu {
                                        Button(
                                            "bank_context_copy_all",
                                            systemImage: "doc.on.doc"
                                        ) {
                                            store.send(.copy(bank, false))
                                        }
                                        
                                        Button(
                                            "bank_context_copy_numbers_only",
                                            systemImage: "textformat.123"
                                        ) {
                                            store.send(.copy(bank, true))
                                        }
                                        
                                        Button(
                                            "delete",
                                            systemImage: "trash",
                                            role: .destructive
                                        ) {
                                            store.send(.deleteBank(bank))
                                        }
                                    }
                            }
                            .sensoryFeedback(
                                .impact,
                                trigger: store.haptic
                            )
                            .fullScreenCover(
                                store: store.scope(
                                    state: \.$bankDetail,
                                    action: \.bankDetail
                                )
                            ) {
                                store.send(.stopLiveActivity)
                            } content: { store in
                                NavigationStack {
                                    BankDetailView(store: store)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle("tab_bank")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.showBankForm)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Colors.textPrimary.color)
                }
                .sheet(
                    item: $store.scope(
                        state: \.bankForm,
                        action: \.bankForm
                    )
                ) {
                    store.send(.fetchAll)
                } content: { store in
                    NavigationStack {
                        BankForm(store: store)
                    }
                    .interactiveDismissDisabled()
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
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
                Text("bank_empty")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
            Button("bank_empty_add", systemImage: "plus") {
                store.send(.showBankForm)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            
            Spacer()
        }
        .padding()
    }
}
