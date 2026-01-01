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

@Reducer
struct CardDetailFeature {
  @ObservableState
  struct State: Equatable {
    let key: String
    let card: Card
    
    var isCardInfoLocked: Bool = true
    var showDeleteConfirmation: Bool = false
    var isAuthenticating: Bool = false
    
    @Shared(.appStorage(UserDefaultsKey.Settings.useBiometric))
    var biometricEnabled: Bool = false
    
    var biometricAvailable: Bool {
      LAContext().canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        error: nil
      ) && biometricEnabled
    }
    
    @Presents var cardForm: CardFormFeature.State?
  }
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case setCardInfoLock(Bool)
    case authenticate
    case setAuthenticating(Bool)
    case toggleFavorite
    case editCard
    case deleteCard
    case launchActivity
    case stopActivity
    case copyToClipboard(Card.SeparatorStyle)
    case dismiss
    
    case cardForm(PresentationAction<CardFormFeature.Action>)
  }
  
  enum CancellableID {
    case authentication
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.persistence) var persistence
  @Dependency(\.authenticationClient) var authenticationClient
  
  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .authenticate:
        guard !state.isAuthenticating else { return .none }
        return .run { [
          biometricAvailable = state.biometricAvailable
        ] send in
          await send(.setAuthenticating(true))
          let authResult = await authenticateWithBiometric()
          if await (try? authenticationClient.authenticateWithBiometric()) ?? false,
             biometricAvailable {
            await send(.setCardInfoLock(!authResult))
          } else {
            await send(.setCardInfoLock(false))
          }
          await send(.setAuthenticating(false))
        }
        .cancellable(id: CancellableID.authentication)
        
      case .setAuthenticating(let isAuthenticating):
        state.isAuthenticating = isAuthenticating
        return .none
        
      case .setCardInfoLock(let lock):
        state.isCardInfoLocked = lock
        return .none
        
      case .copyToClipboard(let separator):
        let number = state.card.getWrappedNumber(state.key, separator)
        UIPasteboard.general.setValue(
          number,
          forPasteboardType: UTType.plainText.identifier
        )
        return .none
        
      case .toggleFavorite:
        state.card.favorite.toggle()
        return .run { send in
          do {
            let context = try await persistence.context()
            try context.save()
          } catch {
            print(#function, "save error")
            print(error)
          }
        }
        
      case .editCard:
        state.cardForm = .init(key: state.key, card: state.card)
        return .none
        
      case .deleteCard:
        let card = state.card
        return .run { @MainActor send in
          do {
            let context = try await persistence.context()
            context.delete(card)
            try context.save()
          } catch {
            print(#function, "save error")
            print(error)
          }
          send(.dismiss)
        }
        
      case .dismiss:
        return .run { _ in
          await dismiss()
        }
        
      case .launchActivity:
        let contentState = CardWidgetAttributes.ContentState(
          id: state.card.id,
          name: state.card.name,
          issuer: state.card.issuer,
          brand: state.card.wrappedBrand,
          color: state.card.color,
          number: state.card.decryptNumber(key: state.key),
          year: state.card.year,
          month: state.card.month,
          cvc: state.card.getWrappedCVC(state.key)
        )
        let cardId = state.card.id
        return .run { send in
          await LiveActivityManager.shared.startCardLiveActivity(
            state: contentState,
            cardId: cardId
          )
        }
        
      case .stopActivity:
        return .run { send in
          await LiveActivityManager.shared.killCardLiveActivities()
        }
        
      default: return .none
      }
    }
    .ifLet(\.$cardForm, action: \.cardForm) {
      CardFormFeature()
    }
  }
}
