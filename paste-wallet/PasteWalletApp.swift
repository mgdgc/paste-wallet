//
//  paste_walletApp.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct PasteWalletApp: App {

    var body: some Scene {
        WindowGroup {
            WalletView(store: Store(initialState: WalletFeature.State(), reducer: {
                WalletFeature()
            }))
//            .modelContainer(for: [Card.self, Bank.self, SecurityCard.self, Memo.self])
        }
    }
}
