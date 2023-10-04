//
//  SettingsView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 10/2/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture
import SwiftKeychainWrapper

struct SettingsFeature: Reducer {
    
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
        let key: String
        // App
        var firstTab: WalletView.Tab = .init(rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.Settings.firstTab) ?? "favorite") ?? .favorite
        // Privacy
        var useBiometric: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric)
        var alwaysRequirePasscode: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.alwaysRequirePasscode)
        // App Info
        var appVersion: String = "1.0.0"
        var appBuild: String = "1"
        
        @PresentationState var passwordReset: PasswordResetFeature.State?
    }
    
    enum Action: Equatable {
        // App
        case setFirstTab(WalletView.Tab)
        // Privacy
        case showPasscodeChangeView
        case setBiometric(Bool)
        case setAlwaysRequirePasscode(Bool)
        case passwordChanged
        // App Info
        case fetchAppVersion
        
        case passwordReset(PresentationAction<PasswordResetFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setFirstTab(tab):
                state.firstTab = tab
                UserDefaults.standard.set(tab.rawValue, forKey: UserDefaultsKey.Settings.firstTab)
                return .none
                
            case .showPasscodeChangeView:
                state.passwordReset = .init(key: state.key)
                return .none
                
            case let .setBiometric(use):
                state.useBiometric = use
                UserDefaults.standard.set(use, forKey: UserDefaultsKey.Settings.useBiometric)
                return .none
                
            case let .setAlwaysRequirePasscode(use):
                state.alwaysRequirePasscode = use
                UserDefaults.standard.set(use, forKey: UserDefaultsKey.Settings.alwaysRequirePasscode)
                return .none
                
            case .fetchAppVersion:
                if let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String, let build = dictionary["CFBundleVersion"] as? String {
                    state.appVersion = version
                    state.appBuild = build
                }
                return .none
                
            case .passwordReset(.presented(.passwordChanged(let success))):
                return success ? .send(.passwordChanged) : .none
                
            case .passwordChanged:
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$passwordReset, action: /Action.passwordReset) {
            PasswordResetFeature()
        }
    }
}
