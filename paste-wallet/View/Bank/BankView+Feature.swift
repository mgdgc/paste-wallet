//
//  BankView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/10/23.
//

import Foundation
import SwiftData
import ComposableArchitecture

struct BankFeature: Reducer {
    struct State: Equatable {
        let modelContext: ModelContext = ModelContext(PasteWalletApp.sharedModelContainer)
        let key: String
        
        var banks: [Bank] = []
        
        @PresentationState var bankForm: BankFormFeature.State?
    }
    
    enum Action: Equatable {
        case fetchAll
        case showBankForm
        
        case bankForm(PresentationAction<BankFormFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchAll:
                state.banks = Bank.fetchAll(modelContext: state.modelContext)
                return .none
                
            case .showBankForm:
                state.bankForm = .init(key: state.key)
                return .none
                
            case .bankForm(_):
                return .none
            }
        }
        .ifLet(\.$bankForm, action: /Action.bankForm) {
            BankFormFeature()
        }
    }
}
