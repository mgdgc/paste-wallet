//
//  ContentView.swift
//  paste-wallet
//
//  Created by 최명근 on 2/16/24.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        Group {
            if let store = store.scope(state: \.wallet, action: \.wallet) {
                WalletView(store: store)
            } else if let store = store.scope(state: \.password, action: \.password) {
                PasswordView(store: store)
            }
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State(), reducer: {
        AppFeature()
    }))
}
