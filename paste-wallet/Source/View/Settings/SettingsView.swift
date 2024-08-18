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

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    private let laContext = LAContext()
    
    var body: some View {
        Form {
            iCloudView()
            appView()
            interactionView()
            activityView()
            privacyView()
            infoView()
        }
        .frame(maxWidth: 640)
        .navigationTitle("tab_settings")
        .scrollContentBackground(.hidden)
        .background(
            Colors.backgroundSecondary.color.ignoresSafeArea()
        )
//        .navigationDestination(
//            item: $store.scope(
//                state: \.passwordReset,
//                action: \.passwordReset
//            )
//        ) { store in
//            PasswordResetView(store: store)
//        }
        .sheet(
            item: $store .scope(
                state: \.passcodeChange,
                action: \.passcodeChange
            )
        ) { store in
            PasscodeChangeView(store: store)
        }
    }
    
    func iCloudView() -> some View {
        Section {
            Label {
                Text(
                    store.iCloudAvailable ?
                    "settings_icloud_available" :
                        "settings_icloud_unavailable"
                )
            } icon: {
                Image(
                    systemName: store.iCloudAvailable ?
                    "checkmark.circle.fill" :
                        "xmark.circle.fill"
                )
            }
            
        } header: {
            Text("settings_section_icloud")
        } footer: {
            Text(
                store.iCloudAvailable ?
                "settings_section_icloud_available" :
                    "settings_section_icloud_unavailable"
            )
        }
        .onAppear {
            store.send(.checkICloud)
        }
    }
    
    func appView() -> some View {
        Section {
            Picker(
                "settings_app_first_tab",
                selection: Binding(
                    get: { store.firstTab },
                    set: { store.send(.setFirstTab($0)) }
                )
            ) {
                ForEach(
                    [WalletView.Tab.favorite, .card, .bank, .memo],
                    id: \.rawValue
                ) { tab in
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
    
    func interactionView() -> some View {
        Section("settings_interaction") {
            Toggle(
                "settings_interaction_haptic_tab",
                isOn: $store.tabHaptic
            )
            
            Toggle(
                "settings_interaction_haptic_item",
                isOn: $store.itemHaptic
            )
        }
    }
    
    func activityView() -> some View {
        Section {
            Toggle(
                "settings_activity_liveactivity",
                isOn: $store.useLiveActivity
            )
            
            if store.useLiveActivity {
                NavigationLink("settings_activity_card_sealing") {
                    List(
                        LiveActivityManager.CardSealing.allCases,
                        id: \.self
                    ) { property in
                        HStack {
                            Text(property.string)
                            Spacer()
                            if store.cardSealing.contains(property) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            var sealings = store.cardSealing
                            if sealings.contains(property) {
                                sealings.removeAll(where: { $0 == property })
                            } else {
                                sealings.append(property)
                            }
                            store.send(.setCardSealing(sealings))
                        }
                    }
                }
                
                Stepper(
                    "settings_activity_bank_sealing_\(store.bankSealing)",
                    value: $store.bankSealing,
                    in: 0...Int.max
                )
            }
        } header: {
            Text("settings_section_activity")
        } footer: {
            Text("settings_footer_activity")
        }
    }
    
    func privacyView() -> some View {
        Section {
            Button("settings_privacy_change_passcode") {
                store.send(.showPasscodeChangeView)
            }
            
            if store.canEvaluate {
                Toggle(
                    "settings_privacy_biometric",
                    isOn: $store.useBiometric
                )
            }
        } header: {
            Text("settings_privacy")
        }
    }
    
    func infoView() -> some View {
        Section("settings_info") {
            InfoCell(
                title: "settings_info_app_version",
                message: store.appVersion
            )
            InfoCell(
                title: "settings_info_app_build",
                message: store.appBuild
            )
        }
        .onAppear {
            store.send(.fetchAppVersion)
        }
    }
}
