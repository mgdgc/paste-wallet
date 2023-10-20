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

struct WalletView: View {
    
    let store: StoreOf<WalletFeature>
    
    @ObservedObject var viewStore: ViewStore<WalletFeature.State, WalletFeature.Action>
    
    init(store: StoreOf<WalletFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
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
        .sensoryFeedback(.impact, trigger: viewStore.selected) { _, _ in
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.tabHaptic)
        }
        .fullScreenCover(isPresented: viewStore.binding(get: \.showPasscodeView, send: WalletFeature.Action.showPasscodeView)) {
            passcodeView
        }
    }
    
    var passcodeView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let localKey = viewStore.localKey {
                if ICloudHelper.shared.iCloudKeyExist {
                    if ICloudHelper.shared.getICloudKey(predictKey: localKey) == localKey {
                        // 비밀번호 확인 모드
                        PinCodeView(initialMessage: "password_type".localized, dismissable: false, enableBiometric: true, authenticateOnLaunch: true) { typed in
                            if typed == localKey {
                                viewStore.send(.setKey(localKey))
                                return .dismiss
                            } else {
                                return .retype("password_wrong".localized)
                            }
                        }
                    } else {
                        // 다른 기기에서 비밀번호 변경함
                        PinCodeView(initialMessage: "password_icloud_wrong".localized, dismissable: false, enableBiometric: false, authenticateOnLaunch: false) { typed in
                            if ICloudHelper.shared.getICloudKey(predictKey: typed) == typed {
                                KeychainWrapper.standard[.password] = typed
                                viewStore.send(.setKey(typed))
                                return .dismiss
                            } else {
                                return .retype("password_wrong".localized)
                            }
                        }
                    }
                }
                
            } else {
                if ICloudHelper.shared.iCloudKeyExist {
                    // 다른 기기에서 사용중일 때
                    PinCodeView(initialMessage: "password_icloud".localized, dismissable: false, enableBiometric: false, authenticateOnLaunch: false) { typed in
                        if ICloudHelper.shared.getICloudKey(predictKey: typed) == typed {
                            KeychainWrapper.standard[.password] = typed
                            viewStore.send(.setKey(typed))
                            return .dismiss
                        } else {
                            return .retype("password_wrong".localized)
                        }
                    }
                    
                } else {
                    // 비밀번호 설정 모드
                    PinCodeView(initialMessage: "password_init".localized, dismissable: false, enableBiometric: false, authenticateOnLaunch: false) { typed in
                        if let temp = viewStore.tempPassword {
                            if temp == typed {
                                KeychainWrapper.standard[.password] = typed
                                ICloudHelper.shared.initICloudKey(keyToSet: typed)
                                viewStore.send(.setKey(typed))
                                return .dismiss
                            } else {
                                viewStore.send(.setTempPassword(nil))
                                return .retype("password_check_fail".localized)
                            }
                            
                        } else {
                            viewStore.send(.setTempPassword(typed))
                            return .retype("password_check".localized)
                        }
                    }
                }
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
    
    return WalletView(store: Store(initialState: WalletFeature.State(), reducer: {
        WalletFeature()
    }))
}
