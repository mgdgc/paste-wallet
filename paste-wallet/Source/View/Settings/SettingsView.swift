//
//  SettingsView.swift
//  paste-wallet
//
//  Created by 최명근 on 10/2/23.
//

import SwiftUI
import LocalAuthentication
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
    
    private let laContext = LAContext()
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Colors.backgroundSecondary.color.ignoresSafeArea()
                Form {
                    iCloudView
                    appView
                    interactionView
                    activityView
                    privacyView
                    infoView
                }
                .frame(maxWidth: 640)
            }
            .navigationTitle("tab_settings")
            .scrollContentBackground(.hidden)
        }
    }
    
    var iCloudView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                Label {
                    Text(viewStore.iCloudAvailable ? "settings_icloud_available" : "settings_icloud_unavailable")
                } icon: {
                    Image(systemName: viewStore.iCloudAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                }

            } header: {
                Text("settings_section_icloud")
            } footer: {
                Text(viewStore.iCloudAvailable ? "settings_section_icloud_available" : "settings_section_icloud_unavailable")
            }
            .onAppear {
                viewStore.send(.checkICloud)
            }
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
    
    var interactionView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section("settings_interaction") {
                Toggle("settings_interaction_haptic_tab", isOn: viewStore.binding(get: \.tabHaptic, send: SettingsFeature.Action.setTabHaptic))
                
                Toggle("settings_interaction_haptic_item", isOn: viewStore.binding(get: \.itemHaptic, send: SettingsFeature.Action.setItemHaptic))
            }
        }
    }
    
    var activityView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                Toggle("settings_activity_liveactivity", isOn: viewStore.binding(get: \.useLiveActivity, send: SettingsFeature.Action.setUseLiveActivity))
                
                if viewStore.useLiveActivity {
                    NavigationLink("settings_activity_card_sealing") {
                        List(LiveActivityManager.CardSealing.allCases, id: \.self) { property in
                            HStack {
                                Text(property.string)
                                Spacer()
                                if viewStore.cardSealing.contains(property) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                var sealings = viewStore.cardSealing
                                if sealings.contains(property) {
                                    sealings.removeAll(where: { $0 == property })
                                } else {
                                    sealings.append(property)
                                }
                                viewStore.send(.setCardSealing(sealings))
                            }
                        }
                    }
                    
                    Stepper("settings_activity_bank_sealing_\(viewStore.bankSealing)", value: viewStore.binding(get: \.bankSealing, send: SettingsFeature.Action.setBankSealing), in: 0...Int.max)
                }
            } header: {
                Text("settings_section_activity")
            } footer: {
                Text("settings_footer_activity")
            }
        }
    }
    
    var privacyView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                Button("settings_privacy_change_passcode") {
                    viewStore.send(.showPasscodeChangeView)
                }
                .navigationDestination(store: store.scope(state: \.$passwordReset, action: \.passwordReset)) { store in
                    PasswordResetView(store: store)
                }
                
                if viewStore.canEvaluate {
                    Toggle("settings_privacy_biometric", isOn: viewStore.binding(get: \.useBiometric, send: SettingsFeature.Action.setBiometric))
                }
            } header: {
                Text("settings_privacy")
            }
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
