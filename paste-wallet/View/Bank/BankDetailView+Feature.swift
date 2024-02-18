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
    
    struct State: Equatable {
        var modelContext: ModelContext = PasteWalletApp.sharedModelContext
        let key: String
        let bank: Bank
        
        var locked: Bool = true
        var dismiss: Bool = false
        var showDeleteConfirmation: Bool = false
        
        var draggedOffset: CGSize = .zero
        
        var biometricAvailable: Bool {
            let laContext = LAContext()
            var error: NSError?
            return laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) &&
            UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric)
        }
        
        @PresentationState var bankForm: BankFormFeature.State?
    }
    
    enum Action: Equatable {
        case unlock
        case lock
        case setLock(Bool)
        case dragChanged(DragGesture.Value)
        case dragEnded(DragGesture.Value)
        case copy(Bool)
        case dismiss
        case setFavorite
        case showDeleteConfirmation(Bool)
        case showBankForm
        case delete
        case launchActivity
        case stopActivity
        
        case bankForm(PresentationAction<BankFormFeature.Action>)
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
                
            case let .dragChanged(value):
                state.draggedOffset = CGSize(width: .zero, height: value.translation.height)
                return .none
                
            case let .dragEnded(value):
                if value.translation.height > 100 {
                    return .send(.dismiss)
                } else {
                    state.draggedOffset = .zero
                    return .none
                }
                
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
                
            case .dismiss:
                state.dismiss = true
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
                
            case let .showDeleteConfirmation(show):
                state.showDeleteConfirmation = show
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
                let attribute = BankWidgetAttributes(id: state.bank.id)
                let contentState = BankWidgetAttributes.ContentState(
                    name: state.bank.name,
                    bank: state.bank.bank,
                    color: state.bank.color,
                    number: state.bank.decryptNumber(state.key))
                let content = ActivityContent(state: contentState, staleDate: .now.advanced(by: 3600))
                
                do {
                    let _ = try Activity<BankWidgetAttributes>.request(
                        attributes: attribute,
                        content: content)
                } catch {
                    print(#function, error)
                }
                return .none
                
            case .stopActivity:
                return .run { send in
                    for activity in Activity<BankWidgetAttributes>.activities {
                        await activity.end(nil, dismissalPolicy: .immediate)
                    }
                }
                
            case let .bankForm(action):
                return .none
            }
        }
        .ifLet(\.$bankForm, action: /Action.bankForm) {
            BankFormFeature()
        }
    }
}
