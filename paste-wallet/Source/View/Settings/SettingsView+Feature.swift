//
//  SettingsView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 10/2/23.
//

import Foundation
import SwiftUI
import SwiftData
import LocalAuthentication
import ComposableArchitecture
import SwiftKeychainWrapper
import CloudKit

@Reducer
struct SettingsFeature {
    
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
        let key: String
        
        // None Changing Value
        let laContext = LAContext()
        
        // iCloud
        var iCloudAvailable: Bool = false
        
        // App
        var firstTab: WalletView.Tab = .init(rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.Settings.firstTab) ?? "favorite") ?? .favorite
        
        // Interaction
        var tabHaptic: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.tabHaptic)
        var itemHaptic: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.itemHaptic)
        
        // Activity
        var useLiveActivity: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useLiveActivity)
        var cardSealing: [LiveActivityManager.CardSealing] = LiveActivityManager.shared.cardSealing
        var bankSealing: Int = LiveActivityManager.shared.bankSealing
        
        // Privacy
        var useBiometric: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric)
        
        // App Info
        var appVersion: String = "1.0.0"
        var appBuild: String = "1"
        
        var canEvaluate: Bool {
            var error: NSError?
            if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                if error == nil {
                    return true
                }
            }
            return false
        }
        
        @PresentationState var passwordReset: PasswordResetFeature.State?
    }
    
    enum Action: Equatable {
        // ICloud
        case checkICloud
        case setICloudStatus(Bool)
        
        // App
        case setFirstTab(WalletView.Tab)
        
        // Interaction
        case setTabHaptic(Bool)
        case setItemHaptic(Bool)
        
        // Activity
        case setUseLiveActivity(Bool)
        case setCardSealing([LiveActivityManager.CardSealing])
        case setBankSealing(Int)
        
        // Privacy
        case showPasscodeChangeView
        case setBiometric(Bool)
        case passwordChanged
        
        // App Info
        case fetchAppVersion
        
        case passwordReset(PresentationAction<PasswordResetFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .checkICloud:
                return .run { send in
                    do {
                        let status = try await CKContainer.default().accountStatus()
                        await send(.setICloudStatus(status == .available))
                    } catch {
                        print(#function, error)
                        await send(.setICloudStatus(false))
                    }
                }
                
            case let .setICloudStatus(status):
                state.iCloudAvailable = status
                return .none
                
            case let .setFirstTab(tab):
                state.firstTab = tab
                UserDefaults.standard.set(tab.rawValue, forKey: UserDefaultsKey.Settings.firstTab)
                return .none
                
            case let .setTabHaptic(haptic):
                state.tabHaptic = haptic
                UserDefaults.standard.set(haptic, forKey: UserDefaultsKey.Settings.tabHaptic)
                return .none
                
            case let .setItemHaptic(haptic):
                state.itemHaptic = haptic
                UserDefaults.standard.set(haptic, forKey: UserDefaultsKey.Settings.itemHaptic)
                return .none
                
            case let .setUseLiveActivity(use):
                state.useLiveActivity = use
                UserDefaults.standard.set(use, forKey: UserDefaultsKey.Settings.useLiveActivity)
                return .none
                
            case let .setCardSealing(sealing):
                state.cardSealing = sealing
                UserDefaults.standard.set(sealing.map { $0.rawValue }, forKey: UserDefaultsKey.Settings.cardSealProperties)
                return .none
                
            case let .setBankSealing(sealing):
                state.bankSealing = sealing
                UserDefaults.standard.set(sealing, forKey: UserDefaultsKey.Settings.bankSealCount)
                return .none
                
            case .showPasscodeChangeView:
                state.passwordReset = .init(key: state.key)
                return .none
                
            case let .setBiometric(use):
                state.useBiometric = use
                UserDefaults.standard.set(use, forKey: UserDefaultsKey.Settings.useBiometric)
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
