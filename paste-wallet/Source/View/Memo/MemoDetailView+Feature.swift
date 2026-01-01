//
//  MemoDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/29/23.
//

import ComposableArchitecture
import Foundation
import LocalAuthentication
import SwiftData
import SwiftUI
import UIKit

@Reducer
struct MemoDetailFeature {
  @ObservableState
  struct State: Equatable {
    let key: String
    var memo: Memo

    var locked: Bool = true
    var showDeleteConfirmation: Bool = false

    @Shared(.appStorage(UserDefaultsKey.Settings.useBiometric))
    var biometricEnabled: Bool = true
    var biometricAvailable: Bool {
      let laContext = LAContext()
      return laContext.canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        error: nil
      ) && biometricEnabled
    }

    @Presents var memoForm: MemoFormFeature.State?
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case unlock
    case lock
    case setLock(Bool)
    case showDeleteConfirmation(Bool)
    case showMemoForm
    case delete
    case save

    case memoForm(PresentationAction<MemoFormFeature.Action>)
  }
  
  @Dependency(\.persistence) var persistence

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .unlock:
        return .run {
          [
            biometricAvailable = state.biometricAvailable
          ] send in
          let laContext = LAContext()
          if biometricAvailable {
            var result: Bool = false
            do {
              result = try await laContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "biometric_reason".localized
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

      case .showDeleteConfirmation(let show):
        state.showDeleteConfirmation = show
        return .none

      case .showMemoForm:
        state.memoForm = .init(key: state.key, memo: state.memo)
        return .none

      case .delete:
        let memo = state.memo
        return .run { @MainActor send in
          guard let context = try? await persistence.context() else { return }
          context.delete(memo)
          send(.save)
        }

      case .save:
        return .run { send in
          do {
            try await persistence.context().save()
          } catch {
            print(#function, error)
          }
        }

      default: return .none
      }
    }
    .ifLet(\.$memoForm, action: \.memoForm) {
      MemoFormFeature()
    }
  }
}
