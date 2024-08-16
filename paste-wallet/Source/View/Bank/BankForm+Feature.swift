//
//  BankForm+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/20/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

@Reducer
struct BankFormFeature {
    @ObservableState
    struct State: Equatable {
        var modelContext: ModelContext
        let key: String
        let bank: Bank?
        
        var bankName: String = ""
        var name: String = ""
        var color: Color = Color.white
        var accountNumber: String = ""
        var memo: String = ""
        
        var confirmButtonDisabled: Bool {
            bankName.isEmpty || name.isEmpty || accountNumber.isEmpty
        }
        
        init(modelContext: ModelContext = PasteWalletApp.sharedModelContext, key: String, bank: Bank? = nil) {
            self.modelContext = modelContext
            self.key = key
            self.bank = bank
            if let bank = bank {
                self.bankName = bank.bank
                self.name = bank.name
                self.color = Color(hexCode: bank.color)
                self.accountNumber = bank.decryptNumber(key)
                self.memo = bank.memo ?? ""
            }
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case setAccountNumber(String)
        case save
        case saveContext
        case dismiss
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .setAccountNumber(let value):
                var value = value
                value.removeAll(where: { !$0.isNumber && $0 != "-" })
                state.accountNumber = value
                return .none
                
            case .save:
                if state.bank != nil {
                    state.bank?.bank = state.bankName
                    state.bank?.name = state.name
                    state.bank?.number = Bank.encryptNumber(state.key, state.accountNumber)
                    state.bank?.color = state.color.hex
                    state.bank?.memo = state.memo
                    
                } else {
                    let bank = Bank(name: state.name, bank: state.bankName, color: state.color.hex, number: Bank.encryptNumber(state.key, state.accountNumber), memo: state.memo)
                    state.modelContext.insert(bank)
                }
                return .send(.saveContext)
                
            case .saveContext:
                do {
                    try state.modelContext.save()
                } catch {
                    print(#function, "save error")
                    print(error)
                }
                return .send(.dismiss)
                
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
                
            default: return .none
            }
        
        }
    }
}
