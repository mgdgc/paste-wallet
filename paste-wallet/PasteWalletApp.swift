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
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Card.self,
            Bank.self,
            Memo.self,
            MemoField.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    static var sharedModelContext: ModelContext = ModelContext(sharedModelContainer)
    
    init() {
        UserDefaults.standard.register(defaults: [
            UserDefaultsKey.Settings.firstTab : WalletView.Tab.favorite.rawValue,
            UserDefaultsKey.Settings.useBiometric : true
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            WalletView(store: Store(initialState: WalletFeature.State(), reducer: {
                WalletFeature()
            }))
        }
    }
}
