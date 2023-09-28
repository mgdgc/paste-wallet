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
            ScrollView {
                let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewStore.banks, id: \.id) { bank in
                        Button {
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
                        .navigationDestination(store: store.scope(state: \.$bankDetail, action: BankFeature.Action.bankDetail)) { store in
                            BankDetailView(store: store)
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                viewStore.send(.fetchAll)
            }
            .navigationTitle("tab_card")
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
}

#Preview {
    return NavigationStack {
        BankView(store: Store(initialState: BankFeature.State(key: "000000"), reducer: {
            BankFeature()
        }))
    }
}
