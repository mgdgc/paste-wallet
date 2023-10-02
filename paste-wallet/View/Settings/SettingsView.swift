//
//  SettingsView.swift
//  paste-wallet
//
//  Created by 최명근 on 10/2/23.
//

import SwiftUI
import ComposableArchitecture

fileprivate struct InfoCell: View {
    var title: LocalizedStringKey
    var message: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(message)
        }
    }
}

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("settings_info") {
                    InfoCell(title: "settings_info_app_version", message: "")
                    InfoCell(title: "settings_info_app_build", message: "")
                }
            }
            .navigationTitle("tab_settings")
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
}

#Preview {
    SettingsView(store: Store(initialState: SettingsFeature.State(), reducer: {
        SettingsFeature()
    }))
}
