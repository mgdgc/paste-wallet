//
//  MainView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import ComposableArchitecture

struct WalletView: View {
    
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        TabView {
            FavoriteView()
                .tabItem { Label("tab_favorite", image: "dashboard") }
            
            NavigationStack {
                CardView(store: Store(initialState: CardFeature.State(modelContext: modelContext, key: ""), reducer: {
                    CardFeature()
                }))
            }
            .tabItem { Label("tab_card", image: "card") }
            
            NavigationStack {
                BankView(store: Store(initialState: BankFeature.State(modelContext: modelContext), reducer: {
                    BankFeature()
                }))
            }
            .tabItem { Label("tab_bank", image: "bank") }
            
            MemoView()
                .tabItem { Label("tab_memo", image: "note") }
        }
        .tint(Colors.textPrimary.color)
    }
}

#Preview {
    WalletView()
        .modelContainer(for: [Card.self, Bank.self, SecurityCard.self, Memo.self], inMemory: true)
}
