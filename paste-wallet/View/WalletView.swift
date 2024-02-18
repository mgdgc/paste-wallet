//
//  MainView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
import SwiftKeychainWrapper
import NotificationCenter

struct WalletView: View {
    let store: StoreOf<WalletFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(get: \.selected, send: WalletFeature.Action.select)) {
                IfLetStore(store.scope(state: \.$favorite, action: \.favorite)) { store in
                    NavigationStack {
                        FavoriteView(store: store)
                    }
                    .tabItem { Label("tab_favorite", image: "star") }
                    .tag(Tab.favorite)
                }
                
                IfLetStore(store.scope(state: \.$card, action: \.card)) { store in
                    NavigationStack {
                        CardView(store: store)
                    }
                    .tabItem { Label("tab_card", image: "card") }
                    .tag(Tab.card)
                }
                
                IfLetStore(store.scope(state: \.$bank, action: \.bank)) { store in
                    NavigationStack {
                        BankView(store: store)
                    }
                    .tabItem { Label("tab_bank", image: "bank") }
                    .tag(Tab.bank)
                }
                
                IfLetStore(store.scope(state: \.$memo, action: \.memo)) { store in
                    NavigationStack {
                        MemoView(store: store)
                    }
                    .tabItem { Label("tab_memo", image: "note") }
                    .tag(Tab.memo)
                }
                
                IfLetStore(store.scope(state: \.$settings, action: \.settings)) { store in
                    NavigationStack {
                        SettingsView(store: store)
                    }
                    .tabItem { Label("tab_settings", image: "settings") }
                    .tag(Tab.settings)
                }
            }
            .tint(Colors.textPrimary.color)
            .sensoryFeedback(.impact, trigger: viewStore.selected) { _, _ in
                return UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.tabHaptic)
            }
            .onAppear {
                viewStore.send(.onAppear)
                print("onAppear")
            }
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
    
    return WalletView(store: Store(initialState: WalletFeature.State(key: ""), reducer: {
        WalletFeature()
    }))
}
