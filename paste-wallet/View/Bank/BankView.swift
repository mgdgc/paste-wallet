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
    let store: StoreOf<BankFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { proxy in
                if viewStore.banks.isEmpty {
                    emptyView(viewStore)
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: Int(proxy.size.width) / 160), spacing: 20) {
                            ForEach(viewStore.banks, id: \.id) { bank in
                                Button {
                                    viewStore.send(.playHaptic)
                                    viewStore.send(.showBankDetail(bank))
                                } label: {
                                    SmallBankView(bank: bank, key: viewStore.key)
                                        .contextMenu {
                                            Button("bank_context_copy_all", systemImage: "doc.on.doc") {
                                                store.send(.copy(bank, false))
                                            }
                                            
                                            Button("bank_context_copy_numbers_only", systemImage: "textformat.123") {
                                                store.send(.copy(bank, true))
                                            }
                                            
                                            Button("delete", systemImage: "trash", role: .destructive) {
                                                store.send(.deleteBank(bank))
                                            }
                                        }
                                }
                                .sensoryFeedback(.impact, trigger: viewStore.haptic)
                                .fullScreenCover(store: store.scope(state: \.$bankDetail, action: \.bankDetail)) {
                                    viewStore.send(.stopLiveActivity)
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
                viewStore.send(.onAppear)
            }
            .navigationTitle("tab_bank")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.showBankForm)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Colors.textPrimary.color)
                    }
                    .sheet(store: store.scope(state: \.$bankForm, action: BankFeature.Action.bankForm)) {
                        viewStore.send(.fetchAll)
                    } content: { store in
                        NavigationStack {
                            BankForm(store: store)
                        }
                        .interactiveDismissDisabled()
                    }
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
    
    private func emptyView(_ viewStore: ViewStore<BankFeature.State, BankFeature.Action>) -> some View {
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
                viewStore.send(.showBankForm)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    return NavigationStack {
        BankView(store: Store(initialState: BankFeature.State(key: "000000"), reducer: {
            BankFeature()
        }))
    }
}
