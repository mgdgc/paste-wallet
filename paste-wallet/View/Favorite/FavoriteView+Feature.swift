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
import ComposableArchitecture

struct FavoriteFeature: Reducer {
    struct State: Equatable {
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
        let key: String
        var tab: WalletView.Tab = .favorite
        
        var cards: [Card] = []
        var banks: [Bank] = []
        
        @PresentationState var cardDetail: CardDetailFeature.State?
        @PresentationState var bankDetail: BankDetailFeature.State?
    }
    
    enum Action: Equatable {
        case fetchCard
        case fetchBank
        case setTab(WalletView.Tab)
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
                
            case let .setTab(tab):
                state.tab = tab
                return .none
                
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
                
            case let .cardDetail(action):
                return .none
                
            case let .bankDetail(action):
                return .none
            }
        }
        .ifLet(\.$cardDetail, action: /Action.cardDetail) {
            CardDetailFeature()
        }
        .ifLet(\.$bankDetail, action: /Action.bankDetail) {
            BankDetailFeature()
        }
    }
}
