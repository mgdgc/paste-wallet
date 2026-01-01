//
//  FavoriteView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/12/23.
//

import ActivityKit
import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Reducer
struct FavoriteFeature {
  @ObservableState
  struct State: Equatable {
    let key: String
    var tab: WalletView.Tab = .favorite

    var cards: [Card] = []
    var banks: [Bank] = []
    var haptic: UUID = UUID()

    @Shared(.appStorage(UserDefaultsKey.Settings.itemHaptic))
    var useItemHapic: Bool = false

    @Presents var cardDetail: CardDetailFeature.State?
    @Presents var bankDetail: BankDetailFeature.State?
  }

  enum Action {
    case fetchCard
    case fetchCardResult([Card])
    case fetchBank
    case fetchBankResult([Bank])
    case playHaptic
    case setTab(WalletView.Tab)
    case copyCard(Card, Card.SeparatorStyle)
    case copyBank(Bank, Bool)
    case unfavoriteCard(Card)
    case unfavoriteBank(Bank)
    case showCardDetail(Card)
    case showBankDetail(Bank)
    case stopLiveActivity

    case cardDetail(PresentationAction<CardDetailFeature.Action>)
    case bankDetail(PresentationAction<BankDetailFeature.Action>)
  }
  
  @Dependency(\.persistence) var persistence

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .fetchCard:
        return .run { send in
          guard let context = try? await persistence.context() else { return }
          let cards = Card.fetchFavorite(modelContext: context)
          await send(.fetchCardResult(cards))
        }
        
      case .fetchCardResult(let cards):
        state.cards = cards
        return .none

      case .fetchBank:
        return .run { send in
          guard let context = try? await persistence.context() else { return }
          let banks = Bank.fetchFavorite(modelContext: context)
          await send(.fetchBankResult(banks))
        }
        
      case .fetchBankResult(let banks):
        state.banks = banks
        return .none

      case .playHaptic:
        if state.useItemHapic {
          state.haptic = UUID()
        }
        return .none

      case .setTab(let tab):
        state.tab = tab
        return .none

      case .copyCard(let card, let separator):
        let number = card.getWrappedNumber(state.key, separator)
        UIPasteboard.general.setValue(
          number,
          forPasteboardType: UTType.plainText.identifier
        )
        return .none

      case .copyBank(let bank, let numbersOnly):
        if numbersOnly {
          var copyText = ""
          for c in bank.decryptNumber(state.key) {
            if c.isNumber {
              copyText.append(c)
            }
          }
          UIPasteboard.general.setValue(
            copyText,
            forPasteboardType: UTType.plainText.identifier
          )
        } else {
          UIPasteboard.general.setValue(
            bank.decryptNumber(state.key),
            forPasteboardType: UTType.plainText.identifier
          )
        }
        return .none

      case .unfavoriteCard(let card):
        card.favorite = false
        return .send(.fetchCard)

      case .unfavoriteBank(let bank):
        bank.favorite = false
        return .send(.fetchBank)

      case .showCardDetail(let card):
        state.cardDetail = .init(key: state.key, card: card)
        return .none

      case .showBankDetail(let bank):
        state.bankDetail = .init(key: state.key, bank: bank)
        return .none

      case .stopLiveActivity:
        return .run { send in
          for activity in Activity<CardWidgetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
          }
          for activity in Activity<BankWidgetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
          }
        }

      case .cardDetail(.dismiss):
        return .send(.fetchCard)

      case .bankDetail(.dismiss):
        return .send(.fetchBank)

      default: return .none
      }
    }
    .ifLet(\.$cardDetail, action: \.cardDetail) {
      CardDetailFeature()
    }
    .ifLet(\.$bankDetail, action: \.bankDetail) {
      BankDetailFeature()
    }
  }
}
