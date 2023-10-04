//
//  SettingsView.swift
//  paste-wallet
//
//  Created by 최명근 on 10/2/23.
//

import SwiftUI
import SwiftKeychainWrapper
import ComposableArchitecture

fileprivate struct InfoCell: View {
    var title: LocalizedStringKey
    var message: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(message)
                .foregroundStyle(Colors.textTertiary.color)
        }
    }
}

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                appView
                privacyView
                infoView
            }
            .navigationTitle("tab_settings")
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
    
    var appView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                Picker("settings_app_first_tab", selection: viewStore.binding(get: \.firstTab, send: SettingsFeature.Action.setFirstTab)) {
                    ForEach([WalletView.Tab.favorite, .card, .bank, .memo], id: \.rawValue) { tab in
                        Text("tab_\(tab.rawValue)".localized)
                            .tag(tab)
                    }
                }
                .pickerStyle(.navigationLink)
                
            } header: {
                Text("settings_app")
                
            } footer: {
                Text("settings_app_footer")
            }
        }
    }
    
    var privacyView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                Button("settings_privacy_change_passcode") {
                    viewStore.send(.showPasscodeChangeView)
                }
                .navigationDestination(store: store.scope(state: \.$passwordReset, action: SettingsFeature.Action.passwordReset)) { store in
                    PasswordResetView(store: store)
                }
                
                Toggle("settings_privacy_biometric", isOn: viewStore.binding(get: \.useBiometric, send: SettingsFeature.Action.setBiometric))
                
                // Toggle("settings_privacy_all_entry", isOn: viewStore.binding(get: \.alwaysRequirePasscode, send: SettingsFeature.Action.setAlwaysRequirePasscode))
            } header: {
                Text("settings_privacy")
            }
            // footer: {
            //    Text("settings_privacy_footer")
            // }
        }
    }
    
    var infoView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section("settings_info") {
                InfoCell(title: "settings_info_app_version", message: viewStore.appVersion)
                InfoCell(title: "settings_info_app_build", message: viewStore.appBuild)
            }
            .onAppear {
                viewStore.send(.fetchAppVersion)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(store: Store(initialState: SettingsFeature.State(key: "000000"), reducer: {
            SettingsFeature()
        }))
    }
}
