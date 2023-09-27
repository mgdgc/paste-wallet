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
                LazyVStack {
                    ForEach(viewStore.banks, id: \.id) { bank in
                        HStack {
                            VStack {
                                HStack {
                                    Text(bank.bank)
                                        .font(.headline)
                                    Spacer()
                                }
                                HStack {
                                    Text(bank.name)
                                        .font(.title.bold())
                                    Spacer()
                                }
                                HStack {
                                    Text(bank.number)
                                        .underline()
                                    Spacer()
                                }
                            }
                            Spacer()
                            HStack {
                                Image(systemName: "chevron.forward")
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hexCode: bank.color))
                        }
                        .foregroundStyle(Color(hexCode: bank.color).isDark ? Color.white : Color.black)
                    }
                }
                .padding()
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
                    .sheet(store: store.scope(state: \.$bankForm, action: BankFeature.Action.bankForm)) { store in
                        BankForm(store: store)
                            .interactiveDismissDisabled()
                    }
                }
            }
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
