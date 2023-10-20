//
//  CardDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import Foundation
import SwiftUI
import SwiftData
import ActivityKit
import UniformTypeIdentifiers
import LocalAuthentication
import ComposableArchitecture

struct CardDetailFeature: Reducer {
    
    struct State: Equatable {
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
        let key: String
        let card: Card
        
        var locked: Bool = true
        var draggedOffset: CGSize = .zero
        var showDeleteConfirmation: Bool = false
        
        var dismiss: Bool = false
        
        var biometricAvailable: Bool {
            let laContext = LAContext()
            var error: NSError?
            return laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) &&
            UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric)
        }
        
        @PresentationState var cardForm: CardFormFeature.State?
    }
    
    enum Action: Equatable {
        case unlock
        case lock
        case setLock(Bool)
        case dragChanged(DragGesture.Value)
        case dragEnded(DragGesture.Value)
        case copy(separator: Card.SeparatorStyle)
        case setFavorite
        case showDeleteConfirmation(Bool)
        case showEdit
        case delete
        case launchActivity
        case stopActivity
        case dismiss
        
        case cardForm(PresentationAction<CardFormFeature.Action>)
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
                
            case let .copy(separator):
                let number = state.card.getWrappedNumber(state.key, separator)
                UIPasteboard.general.setValue(number, forPasteboardType: UTType.plainText.identifier)
                return .none
                
            case .setFavorite:
                state.card.favorite.toggle()
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
                
            case .showEdit:
                state.cardForm = .init(key: state.key, card: state.card)
                return .none
                
            case .delete:
                state.modelContext.delete(state.card)
                do {
                    try state.modelContext.save()
                } catch {
                    print(#function, "save error")
                    print(error)
                }
                return .send(.dismiss)
                
            case .dismiss:
                state.dismiss.toggle()
                return .none
                
            case .launchActivity:
                let attributes = CardWidgetAttributes(id: state.card.id)
                let contentState = CardWidgetAttributes.ContentState(
                    id: state.card.id,
                    name: state.card.name,
                    issuer: state.card.issuer,
                    brand: state.card.wrappedBrand,
                    color: state.card.color,
                    number: state.card.decryptNumber(key: state.key),
                    year: state.card.year,
                    month: state.card.month,
                    cvc: state.card.getWrappedCVC(state.key))
                let content = ActivityContent(state: contentState, staleDate: .now.advanced(by: 3600))
                
                do {
                    let _ = try Activity<CardWidgetAttributes>.request(
                        attributes: attributes,
                        content: content)
                } catch {
                    print(#function, error)
                }
                return .none
                
            case .stopActivity:
                return .run { send in
                    for activity in Activity<CardWidgetAttributes>.activities {
                        await activity.end(nil, dismissalPolicy: .immediate)
                    }
                }
                
            case let .cardForm(action):
                return .none
            }
        }
        .ifLet(\.$cardForm, action: /Action.cardForm) {
            CardFormFeature()
        }
    }
    
}
