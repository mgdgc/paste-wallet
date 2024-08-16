//
//  BankDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/27/23.
//

import Foundation
import SwiftUI
import SwiftData
import ActivityKit
import UniformTypeIdentifiers
import LocalAuthentication
import ComposableArchitecture

@Reducer
struct BankDetailFeature {
    @ObservableState
    struct State: Equatable {
        var modelContext: ModelContext = PasteWalletApp.sharedModelContext
        let key: String
        let bank: Bank
        
        var locked: Bool = true
        var showDeleteConfirmation: Bool = false
        
        var biometricAvailable: Bool {
            let laContext = LAContext()
            var error: NSError?
            return laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) &&
            UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric)
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
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
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
                
            case let .copy(numbersOnly):
                if numbersOnly {
                    var copyText = ""
                    for c in state.bank.decryptNumber(state.key) {
                        if c.isNumber {
                            copyText.append(c)
                        }
                    }
                    UIPasteboard.general.setValue(copyText, forPasteboardType: UTType.plainText.identifier)
                } else {
                    UIPasteboard.general.setValue(state.bank.decryptNumber(state.key), forPasteboardType: UTType.plainText.identifier)
                }
                return .none
                
            case .setFavorite:
                state.bank.favorite.toggle()
                do {
                    try state.modelContext.save()
                } catch {
                    print(#function, "save error")
                    print(error)
                }
                return .none
                
            case .showBankForm:
                state.bankForm = .init(key: state.key, bank: state.bank)
                return .none
                
            case .delete:
                state.modelContext.delete(state.bank)
                do {
                    try state.modelContext.save()
                } catch {
                    print(#function, "save error")
                    print(error)
                }
                return .send(.dismiss)
                
            case .launchActivity:
                
                let contentState = BankWidgetAttributes.ContentState(
                    name: state.bank.name,
                    bank: state.bank.bank,
                    color: state.bank.color,
                    number: state.bank.decryptNumber(state.key))
                
                LiveActivityManager.shared.startBankLiveActivity(state: contentState, bankId: state.bank.id)
                return .none
                
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
