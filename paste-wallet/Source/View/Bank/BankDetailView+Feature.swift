//
//  BankDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/27/23.
//

import ActivityKit
import ComposableArchitecture
import Foundation
import LocalAuthentication
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Reducer
struct BankDetailFeature {
  @ObservableState
  struct State: Equatable {
    let key: String
    let bank: Bank

    var locked: Bool = true
    var showDeleteConfirmation: Bool = false

    var biometricAvailable: Bool {
      let laContext = LAContext()
      var error: NSError?
      return laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        && UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric)
    }

    @Presents var bankForm: BankFormFeature.State?
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case unlock
    case lock
    case setLock(Bool)
    case copy(Bool)
    case setFavorite
    case showBankForm
    case delete
    case launchActivity
    case stopActivity
    case dismiss

    case bankForm(PresentationAction<BankFormFeature.Action>)
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.persistence) var persistence

  var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .unlock:
        return .run { send in
          let laContext = LAContext()
          var error: NSError?
          if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            && UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric)
          {
            let reason = "biometric_reason".localized
            var result: Bool = false
            do {
              result = try await laContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
              )
            } catch {
              print(#function, error)
            }
            await send(.setLock(!result))
          } else {
            await send(.setLock(false))
          }
        }

      case .lock:
        return .send(.setLock(true))

      case .setLock(let lock):
        state.locked = lock
        return .none

      case .copy(let numbersOnly):
        if numbersOnly {
          var copyText = ""
          for c in state.bank.decryptNumber(state.key) {
            if c.isNumber {
              copyText.append(c)
            }
          }
          UIPasteboard.general.setValue(copyText, forPasteboardType: UTType.plainText.identifier)
        } else {
          UIPasteboard.general.setValue(
            state.bank.decryptNumber(state.key),
            forPasteboardType: UTType.plainText.identifier
          )
        }
        return .none

      case .setFavorite:
        state.bank.favorite.toggle()
        return .run { send in
          do {
            let context = try await persistence.context()
            try context.save()
          } catch {
            print(#function, "save error")
            print(error)
          }
        }

      case .showBankForm:
        state.bankForm = .init(key: state.key, bank: state.bank)
        return .none

      case .delete:
        return .run { @MainActor send in
          do {
            let context = try await persistence.context()
            context.delete(state.bank)
            try context.save()
          } catch {
            print(#function, "save error")
            print(error)
          }
          send(.dismiss)
        }

      case .launchActivity:
        let contentState = BankWidgetAttributes.ContentState(
          name: state.bank.name,
          bank: state.bank.bank,
          color: state.bank.color,
          number: state.bank.decryptNumber(state.key)
        )
        let bankId = state.bank.id
        return .run { send in
          await LiveActivityManager.shared.startBankLiveActivity(state: contentState, bankId: bankId)
        }

      case .stopActivity:
        return .run { send in
          await LiveActivityManager.shared.killBankLiveActivities()
        }

      case .dismiss:
        return .run { _ in
          await dismiss()
        }

      default: return .none
      }
    }
    .ifLet(\.$bankForm, action: \.bankForm) {
      BankFormFeature()
    }
  }
}
