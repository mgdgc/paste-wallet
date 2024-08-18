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
        var modelContext: ModelContext = PasteWalletApp.sharedModelContext
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
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setNewPasscode(let passcode):
                state.newPasscode = passcode
                return .none
                
            case .changePasscode(let passcode):
                Card.changePasscode(
                    modelContext: state.modelContext,
                    oldKey: state.key,
                    newKey: passcode
                )
                Bank.changePasscode(
                    modelContext: state.modelContext,
                    oldKey: state.key,
                    newKey: passcode
                )
                Memo.changePasscode(
                    modelContext: state.modelContext,
                    oldKey: state.key,
                    newKey: passcode
                )
                KeychainWrapper.standard[.password] = passcode
                ICloudHelper.shared.setICloudKey(passcode)
                return .send(.showResultAlert)
                
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
                PasteWalletApp.appStore.send(.setKey(nil))
                return .run { _ in
                    await dismiss()
                }
                
            default: return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
