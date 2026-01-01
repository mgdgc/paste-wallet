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
    let freshInstall = !UserDefaults.standard.bool(
      forKey: UserDefaultsKey.AppEnvironment.alreadyInstalled
    )
    if freshInstall {
      KeychainWrapper.standard.removeAllKeys()
      UserDefaults.standard.set(
        true,
        forKey: UserDefaultsKey.AppEnvironment.alreadyInstalled
      )
    }
    
    // Reload Widgets
    WidgetCenter.shared.reloadAllTimelines()
  }
  
  static let appStore: StoreOf<AppFeature> = .init(initialState: AppFeature.State()) {
    AppFeature()
  }
  
  @State private var splashFinished: Bool = false
  
  var body: some Scene {
    WindowGroup {
      Group {
        if splashFinished {
          AppView(store: PasteWalletApp.appStore)
        } else {
          SplashView {
            splashFinished = true
          }
        }
      }
      .onOpenURL { url in
        splashFinished = false
        
        if url.absoluteString.starts(with: "widget://key") {
          guard let urlComponents = URLComponents(string: url.absoluteString),
                let type = urlComponents.queryItems?.first(where: { $0.name == "type" })?.value,
                let id = urlComponents.queryItems?.first(where: { $0.name == "id" })?.value else {
            return
          }
          
          if type == "card" {
            PasteWalletApp.appStore.send(.openByWidgetCard(id))
            
          } else if type == "bank" {
            PasteWalletApp.appStore.send(.openByWidgetBank(id))
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
