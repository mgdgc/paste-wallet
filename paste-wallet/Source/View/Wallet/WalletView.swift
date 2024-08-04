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
    @Bindable var store: StoreOf<WalletFeature>
    
    var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                FavoriteView(store: store.scope(state: \.favorite, action: \.favorite))
            }
            .tabItem { Label("tab_favorite", image: "star") }
            .tag(Tab.favorite)
            
            NavigationStack {
                CardView(store: store.scope(state: \.card, action: \.card))
            }
            .tabItem { Label("tab_card", image: "card") }
            .tag(Tab.card)
            
            NavigationStack {
                BankView(store: store.scope(state: \.bank, action: \.bank))
            }
            .tabItem { Label("tab_bank", image: "bank") }
            .tag(Tab.bank)
            
            NavigationStack {
                MemoView(store: store.scope(state: \.memo, action: \.memo))
            }
            .tabItem { Label("tab_memo", image: "note") }
            .tag(Tab.memo)
            
            NavigationStack {
                SettingsView(store: store.scope(state: \.settings, action: \.settings))
            }
            .tabItem { Label("tab_settings", image: "settings") }
            .tag(Tab.settings)
        }
        .tint(Colors.textPrimary.color)
        .sensoryFeedback(.impact, trigger: store.selectedTab) { _, _ in
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.tabHaptic)
        }
        .onAppear {
            store.send(.openByWidget)
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
