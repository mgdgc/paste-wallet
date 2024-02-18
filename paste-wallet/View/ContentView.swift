//
//  ContentView.swift
//  paste-wallet
//
//  Created by 최명근 on 2/16/24.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<Feature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.key != nil {
                    IfLetStore(store.scope(state: \.$wallet, action: \.wallet)) { store in
                        WalletView(store: store)
                    }
                } else {
                    IfLetStore(store.scope(state: \.$password, action: \.password)) { store in
                        PasswordView(store: store)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(store: Store(initialState: Feature.State(), reducer: {
        Feature()
    }))
}
