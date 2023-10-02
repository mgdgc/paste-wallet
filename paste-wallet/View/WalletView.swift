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
        if viewStore.key != nil {
            TabView(selection: viewStore.binding(get: \.selected, send: WalletFeature.Action.select)) {
                
                IfLetStore(store.scope(state: \.$favorite, action: WalletFeature.Action.favorite)) { store in
                    NavigationStack {
                        FavoriteView(store: store)
                    }
                    .tabItem { Label("tab_favorite", image: "star") }
                    .tag(Tab.favorite)
                }
                
                
                IfLetStore(store.scope(state: \.$card, action: WalletFeature.Action.card)) { store in
                    NavigationStack {
                        CardView(store: store)
                    }
                    .tabItem { Label("tab_card", image: "card") }
                    .tag(Tab.card)
                }
                
                IfLetStore(store.scope(state: \.$bank, action: WalletFeature.Action.bank)) { store in
                    NavigationStack {
                        BankView(store: store)
                    }
                    .tabItem { Label("tab_bank", image: "bank") }
                    .tag(Tab.bank)
                }
                
                IfLetStore(store.scope(state: \.$memo, action: WalletFeature.Action.memo)) { store in
                    NavigationStack {
                        MemoView(store: store)
                    }
                    .tabItem { Label("tab_memo", image: "note") }
                    .tag(Tab.memo)
                }
                
                IfLetStore(store.scope(state: \.$settings, action: WalletFeature.Action.settings)) { store in
                    NavigationStack {
                        SettingsView(store: store)
                    }
                    .tabItem { Label("tab_settings", image: "settings") }
                    .tag(Tab.settings)
                }
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
        case settings
    }
    
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
    for c in Card.previewItems() {
        context.insert(c)
    }
    
    return WalletView(store: Store(initialState: WalletFeature.State(), reducer: {
        WalletFeature()
    }))
}
