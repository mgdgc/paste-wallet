//
//  Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ActivityKit
import UniformTypeIdentifiers
import ComposableArchitecture

@Reducer
struct CardFeature {
  @ObservableState
  struct State: Equatable {
    let key: String
    
    var openByWidget: String?
    
    // Fetch Data
    var cards: [Card] = []
    // 카드 Drag and drop
    var draggingItem: Card?
    // Haptic
    var haptic: UUID = UUID()
    
    @Presents var cardForm: CardFormFeature.State?
    @Presents var cardDetail: CardDetailFeature.State?
  }
  
  enum Action {
    case onAppear
    case fetchAll
    case fetchAllResult([Card])
    case playHaptic
    case copy(card: Card, separator: Card.SeparatorStyle)
    case delete(card: Card)
    case showCardForm
    case showCardDetail(card: Card)
    case stopLiveActivity
    case showTargetCard(String)
    
    case cardForm(PresentationAction<CardFormFeature.Action>)
    case cardDetail(PresentationAction<CardDetailFeature.Action>)
  }
  
  @Dependency(\.persistence) var persistence: PersistenceClient
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        let openByWidget = state.openByWidget
        if let openByWidgetCard = openByWidget {
          return .concatenate(
            .send(.fetchAll),
            .send(.showTargetCard(openByWidgetCard))
          )
        } else {
          return .send(.fetchAll)
        }
        
      case .fetchAll:
        return .run { send in
          guard let context = try? await persistence.context() else { return }
          let cards = Card.fetchAll(modelContext: context)
          await send(.fetchAllResult(cards))
        }
        
      case .fetchAllResult(let cards):
        state.cards = cards
        return .none
        
      case .playHaptic:
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.itemHaptic) {
          state.haptic = UUID()
        }
        return .none
        
      case .showCardForm:
        state.cardForm = .init(key: state.key)
        return .none
        
      case let .copy(card, separator):
        let number = card.getWrappedNumber(state.key, separator)
        UIPasteboard.general.setValue(number, forPasteboardType: UTType.plainText.identifier)
        return .none
        
      case let .delete(card):
        return .run { @MainActor send in
          guard let context = try? await persistence.context() else { return }
          context.delete(card)
          await send(.fetchAll)
        }
        
      case let .showCardDetail(card):
        state.cardDetail = .init(key: state.key, card: card)
        return .none
        
      case .stopLiveActivity:
        return .run { send in
          for activity in Activity<CardWidgetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
          }
        }
        
      case let .showTargetCard(id):
        if let card = state.cards.first(where: { $0.id.uuidString == id }) {
          return .send(.showCardDetail(card: card))
        } else {
          return .none
        }
        
      case .cardForm(.dismiss):
        return .send(.fetchAll)
        
      case .cardDetail(.dismiss):
        return .send(.fetchAll)
        
      default:
        return .none
      }
    }
    .ifLet(\.$cardForm, action: \.cardForm) {
      CardFormFeature()
    }
    .ifLet(\.$cardDetail, action: \.cardDetail) {
      CardDetailFeature()
    }
  }
  
}
