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
    
    @State private var key: String?
    
    var body: some View {
        if let key = key {
            TabView {
                FavoriteView()
                    .tabItem { Label("tab_favorite", image: "dashboard") }
                
                NavigationStack {
                    CardView(store: Store(initialState: CardFeature.State(modelContext: modelContext, key: key), reducer: {
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
        } else {
            PasswordView(key: $key)
        }
    }
    
}

#Preview {
    WalletView()
        .modelContainer(for: [Card.self, Bank.self, SecurityCard.self, Memo.self], inMemory: true)
}
