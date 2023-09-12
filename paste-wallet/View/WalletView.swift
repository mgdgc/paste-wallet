//
//  MainView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct WalletView: View {
    
    let store: StoreOf<WalletFeature>
    
    @ObservedObject var viewStore: ViewStore<WalletFeature.State, WalletFeature.Action>
    
    init(store: StoreOf<WalletFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        if let key = viewStore.key {
            TabView(selection: viewStore.binding(get: \.selected, send: WalletFeature.Action.select)) {
                
                NavigationStack {
                    FavoriteView(store: store.scope(state: \.favorite, action: WalletFeature.Action.favorite))
                }
                .tabItem { Label("tab_favorite", image: "dashboard") }
                .tag(Tab.favorite)
                
                NavigationStack {
                    CardView(store: Store(initialState: CardFeature.State(modelContext: viewStore.modelContext, key: key), reducer: {
                        CardFeature()
                    }))
                }
                .tabItem { Label("tab_card", image: "card") }
                .tag(Tab.card)
                
                NavigationStack {
                    BankView(store: Store(initialState: BankFeature.State(modelContext: viewStore.modelContext), reducer: {
                        BankFeature()
                    }))
                }
                .tabItem { Label("tab_bank", image: "bank") }
                .tag(Tab.bank)
                
                MemoView()
                    .tabItem { Label("tab_memo", image: "note") }
                    .tag(Tab.memo)
            }
            .tint(Colors.textPrimary.color)
            
        } else {
            PasswordView(key: viewStore.binding(get: \.key, send: { value in
                    .setKey(value)
            }))
        }
    }
    
    enum Tab: String, Equatable {
        case favorite
        case card
        case bank
        case memo
    }
    
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 2", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 3", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 4", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "435"))
    
    return WalletView(store: Store(initialState: WalletFeature.State(), reducer: {
        WalletFeature()
    }))
    .modelContainer(for: [Card.self, Bank.self, SecurityCard.self, Memo.self], inMemory: true)
}
