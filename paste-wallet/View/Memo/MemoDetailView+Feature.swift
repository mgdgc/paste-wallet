//
//  MemoDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/29/23.
//

import Foundation
import UIKit
import SwiftUI
import SwiftData
import LocalAuthentication
import ComposableArchitecture

struct MemoDetailFeature: Reducer {
    
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
        let key: String
        var memo: Memo
        
        var locked: Bool = true
        var showDeleteConfirmation: Bool = false
        
        var biometricAvailable: Bool {
            let laContext = LAContext()
            var error: NSError?
            return laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) &&
            UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric)
        }
        
        @PresentationState var memoForm: MemoFormFeature.State?
    }
    
    enum Action: Equatable {
        case unlock
        case lock
        case setLock(Bool)
        case showDeleteConfirmation(Bool)
        case showMemoForm
        case delete
        case save
        
        case memoForm(PresentationAction<MemoFormFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .unlock:
                return .run { send in
                    let laContext = LAContext()
                    var error: NSError?
                    if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) &&
                        UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric) {
                        let reason = "biometric_reason".localized
                        var result: Bool = false
                        do {
                            result = try await laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
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
                           
            case let .setLock(lock):
                state.locked = lock
                return .none
                
            case let .showDeleteConfirmation(show):
                state.showDeleteConfirmation = show
                return .none
                
            case .showMemoForm:
                state.memoForm = .init(key: state.key, memo: state.memo)
                return .none
                
            case .delete:
                state.modelContext.delete(state.memo)
                return .send(.save)
                
            case .save:
                do {
                    try state.modelContext.save()
                } catch {
                    print(#function, error)
                }
                return .none
                
            case let .memoForm(action):
                return .none
            }
        }
        .ifLet(\.$memoForm, action: /Action.memoForm) {
            MemoFormFeature()
        }
    }
}
