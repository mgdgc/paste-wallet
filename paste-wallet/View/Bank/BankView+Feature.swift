//
//  BankView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/10/23.
//

import Foundation
import UIKit
import SwiftData
import UniformTypeIdentifiers
import ComposableArchitecture

struct BankFeature: Reducer {
    struct State: Equatable {
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
        let key: String
        
        var banks: [Bank] = []
        
        @PresentationState var bankForm: BankFormFeature.State?
        @PresentationState var bankDetail: BankDetailFeature.State?
    }
    
    enum Action: Equatable {
        case fetchAll
        case showBankForm
        case showBankDetail(Bank)
        case deleteBank(Bank)
        case copy(_ bank: Bank, _ numbersOnly: Bool)
        
        case bankForm(PresentationAction<BankFormFeature.Action>)
        case bankDetail(PresentationAction<BankDetailFeature.Action>)
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
                
            case let .showBankDetail(bank):
                state.bankDetail = .init(key: state.key, bank: bank)
                return .none
                
            case let .deleteBank(bank):
                state.modelContext.delete(bank)
                do {
                    try state.modelContext.save()
                } catch {
                    print(#function, "save error")
                    print(error)
                }
                return .send(.fetchAll)
                
            case let .copy(bank, numbersOnly):
                if numbersOnly {
                    var copyText = ""
                    for c in bank.decryptNumber(state.key) {
                        if c.isNumber {
                            copyText.append(c)
                        }
                    }
                    UIPasteboard.general.setValue(copyText, forPasteboardType: UTType.plainText.identifier)
                } else {
                    UIPasteboard.general.setValue(bank.decryptNumber(state.key), forPasteboardType: UTType.plainText.identifier)
                }
                return .none
                
            case .bankForm(_):
                return .none
                
            case .bankDetail(_):
                return .none
            }
        }
        .ifLet(\.$bankForm, action: /Action.bankForm) {
            BankFormFeature()
        }
        .ifLet(\.$bankDetail, action: /Action.bankDetail) {
            BankDetailFeature()
        }
    }
}
