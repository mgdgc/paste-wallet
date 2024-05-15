//
//  paste_walletApp.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ActivityKit
import ComposableArchitecture
import SwiftKeychainWrapper
import WidgetKit
import NotificationCenter
import BackgroundTasks

@main
struct PasteWalletApp: App {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Card.self,
            Bank.self,
            Memo.self,
            MemoField.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, groupContainer: .automatic, cloudKitDatabase: .private("Wallet"))
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    static var sharedModelContext: ModelContext = ModelContext(sharedModelContainer)
    
    init() {
        // Set default value for UserDefaults
        UserDefaults.standard.register(defaults: [
            UserDefaultsKey.Settings.firstTab : WalletView.Tab.favorite.rawValue,
            UserDefaultsKey.Settings.useBiometric : true,
            UserDefaultsKey.Settings.tabHaptic : false,
            UserDefaultsKey.Settings.itemHaptic : false,
            UserDefaultsKey.Settings.useLiveActivity : true,
            UserDefaultsKey.Settings.cardSealProperties : [
                LiveActivityManager.CardSealing.fourth.rawValue,
                LiveActivityManager.CardSealing.cvc.rawValue
            ],
            UserDefaultsKey.Settings.bankSealCount : 4
        ])
        
        // Erase Keychain value if the app has reinstalled
        let freshInstall = !UserDefaults.standard.bool(forKey: UserDefaultsKey.AppEnvironment.alreadyInstalled)
        if freshInstall {
            KeychainWrapper.standard.removeAllKeys()
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.AppEnvironment.alreadyInstalled)
        }
        
        // Reload Widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    @State private var key: String? = nil
    @State private var splashFinished: Bool = false
    @State private var openByWidgetCard: String? = nil
    @State private var openByWidgetBank: String? = nil
    
    var body: some Scene {
        WindowGroup {
            Group {
                if splashFinished {
                    ContentView(store: Store(initialState: Feature.State(openByWidgetCard: openByWidgetCard, openByWidgetBank: openByWidgetBank), reducer: {
                        Feature()
                    }))
                } else {
                    SplashView {
                        splashFinished = true
                    }
                }
            }
            .onOpenURL { url in
                splashFinished = false
                openByWidgetCard = nil
                openByWidgetBank = nil
                
                if url.absoluteString.starts(with: "widget://key") {
                    guard let urlComponents = URLComponents(string: url.absoluteString) else { return }
                    guard let type = urlComponents.queryItems?.first(where: { $0.name == "type" })?.value else { return }
                    guard let id = urlComponents.queryItems?.first(where: { $0.name == "id" })?.value else { return }
                    
                    if type == "card" {
                        openByWidgetCard = id
                        
                    } else if type == "bank" {
                        openByWidgetBank = id
                    }
                }
            }
        }
        .backgroundTask(.appRefresh(LiveActivityManager.BGTaskName.cardKill.identifier)) {
            await LiveActivityManager.shared.killCardLiveActivities()
        }
        .backgroundTask(.appRefresh(LiveActivityManager.BGTaskName.bankKill.identifier)) {
            await LiveActivityManager.shared.killBankLiveActivities()
        }
    }
}
