//
//  SettingsView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 10/2/23.
//

import CloudKit
import ComposableArchitecture
import Foundation
import LocalAuthentication
import SwiftData
import SwiftKeychainWrapper
import SwiftUI

@Reducer
struct SettingsFeature {
  @ObservableState
  struct State: Equatable {
    let key: String

    // None Changing Value
    let laContext = LAContext()

    // iCloud
    var iCloudAvailable: Bool = false

    // App
    var firstTab: WalletView.Tab =
      .init(
        rawValue: UserDefaults.standard.string(
          forKey: UserDefaultsKey.Settings.firstTab
        ) ?? "favorite"
      ) ?? .favorite

    // Interaction
    @Shared(.appStorage(UserDefaultsKey.Settings.tabHaptic))
    var tabHaptic: Bool = false
    @Shared(.appStorage(UserDefaultsKey.Settings.itemHaptic))
    var itemHaptic: Bool = false

    // Activity
    @Shared(.appStorage(UserDefaultsKey.Settings.useLiveActivity))
    var useLiveActivity: Bool = true
    var cardSealing: [LiveActivityManager.CardSealing] = LiveActivityManager.shared.cardSealing
    var bankSealing: Int = LiveActivityManager.shared.bankSealing

    // Privacy
    @Shared(.appStorage(UserDefaultsKey.Settings.useBiometric))
    var useBiometric: Bool = true

    // App Info
    var appVersion: String = "1.0.0"
    var appBuild: String = "1"

    var canEvaluate: Bool {
      var error: NSError?
      if laContext.canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        error: &error
      ) {
        if let error {
          debugPrint(error)
        } else {
          return true
        }
      }
      return false
    }

    @Presents var passcodeChange: PasscodeChangeFeature.State?
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)

    // ICloud
    case checkICloud
    case setICloudStatus(Bool)

    // App
    case setFirstTab(WalletView.Tab)

    // Activity
    case setCardSealing([LiveActivityManager.CardSealing])
    case setBankSealing(Int)

    // Privacy
    case showPasscodeChangeView

    // App Info
    case fetchAppVersion

    // Change Passcode
    case passcodeChange(PresentationAction<PasscodeChangeFeature.Action>)
  }
  
  @Dependency(\.persistence) var persistence

  var body: some ReducerOf<Self> {
    BindingReducer()

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

      case .setICloudStatus(let status):
        state.iCloudAvailable = status
        return .none

      case .setFirstTab(let tab):
        state.firstTab = tab
        UserDefaults.standard.set(tab.rawValue, forKey: UserDefaultsKey.Settings.firstTab)
        return .none

      case .setCardSealing(let sealing):
        state.cardSealing = sealing
        UserDefaults.standard.set(
          sealing.map { $0.rawValue },
          forKey: UserDefaultsKey.Settings.cardSealProperties
        )
        return .none

      case .setBankSealing(let sealing):
        state.bankSealing = sealing
        UserDefaults.standard.set(sealing, forKey: UserDefaultsKey.Settings.bankSealCount)
        return .none

      case .showPasscodeChangeView:
        state.passcodeChange = .init(key: state.key)
        return .none

      case .fetchAppVersion:
        if let dictionary = Bundle.main.infoDictionary,
          let version = dictionary["CFBundleShortVersionString"] as? String,
          let build = dictionary["CFBundleVersion"] as? String
        {
          state.appVersion = version
          state.appBuild = build
        }
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$passcodeChange, action: \.passcodeChange) {
      PasscodeChangeFeature()
    }
  }
}
