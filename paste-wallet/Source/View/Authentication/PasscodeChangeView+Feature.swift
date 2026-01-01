//
//  PasscodeChangeView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 8/18/24.
//

import Foundation
import ComposableArchitecture
import SwiftKeychainWrapper
import SwiftData

@Reducer
struct PasscodeChangeFeature {
  @ObservableState
  struct State: Equatable {
    var key: String
    var newPasscode: String?
    
    @Presents var alert: AlertState<Action.Alert>?
  }
  
  enum Action {
    case setNewPasscode(String?)
    case changePasscode(String)
    case showResultAlert
    case alert(PresentationAction<Alert>)
    
    enum Alert: Equatable {
      case passwordChanged
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.persistence) var persistence: PersistenceClient
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .setNewPasscode(let passcode):
        state.newPasscode = passcode
        return .none
        
      case .changePasscode(let passcode):
        let key = state.key
        return .run { send in
          guard let context = try? await persistence.context() else { return }
          Card.changePasscode(
            modelContext: context,
            oldKey: key,
            newKey: passcode
          )
          Bank.changePasscode(
            modelContext: context,
            oldKey: key,
            newKey: passcode
          )
          Memo.changePasscode(
            modelContext: context,
            oldKey: key,
            newKey: passcode
          )
          KeychainWrapper.standard[.password] = passcode
          await ICloudHelper.shared.setICloudKey(passcode)
          await send(.showResultAlert)
        }
        
      case .showResultAlert:
        state.alert = .init(
          title: {
            TextState("passcode_change_result_title")
          },
          actions: {
            ButtonState(
              role: .none,
              action: .send(.passwordChanged),
              label: { TextState("confirm") }
            )
          },
          message: {
            TextState("passcode_change_result_message")
          }
        )
        return .none
        
      case .alert(.presented(.passwordChanged)):
        return .run { _ in
          await PasteWalletApp.appStore.send(.setKey(nil))
          await dismiss()
        }
        
      default: return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}
