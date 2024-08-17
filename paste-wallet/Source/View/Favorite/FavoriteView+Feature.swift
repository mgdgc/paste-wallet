//
//  FavoriteView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/12/23.
//

import Foundation
import SwiftUI
import SwiftData
import ActivityKit
import UniformTypeIdentifiers
import ComposableArchitecture

@Reducer
struct FavoriteFeature {
    @ObservableState
    struct State: Equatable {
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
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
        case fetchBank
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
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchCard:
                state.cards = Card.fetchFavorite(modelContext: state.modelContext)
                return .none
                
            case .fetchBank:
                state.banks = Bank.fetchFavorite(modelContext: state.modelContext)
                return .none
                
            case .playHaptic:
                if state.useItemHapic {
                    state.haptic = UUID()
                }
                return .none
                
            case let .setTab(tab):
                state.tab = tab
                return .none
                
            case let .copyCard(card, separator):
                let number = card.getWrappedNumber(state.key, separator)
                UIPasteboard.general.setValue(
                    number,
                    forPasteboardType: UTType.plainText.identifier
                )
                return .none
                
            case let .copyBank(bank, numbersOnly):
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
                
            case let .unfavoriteCard(card):
                card.favorite = false
                return .send(.fetchCard)
                
            case let .unfavoriteBank(bank):
                bank.favorite = false
                return .send(.fetchBank)
                
            case let .showCardDetail(card):
                state.cardDetail = .init(key: state.key, card: card)
                return .none
                
            case let .showBankDetail(bank):
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
