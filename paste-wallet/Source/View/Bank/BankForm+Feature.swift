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
    
    enum Action: Equatable {
        case setBankName(String)
        case setName(String)
        case setColor(Color)
        case setAccountNumber(String)
        case setMemo(String)
        case save
        case saveContext
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setBankName(name):
            state.bankName = name
            return .none
            
        case let .setName(name):
            state.name = name
            return .none
            
        case let .setColor(color):
            state.color = color
            return .none
            
        case let .setAccountNumber(number):
            state.accountNumber = number
            return .none
            
        case let .setMemo(memo):
            state.memo = memo
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
            return .none
        }
    }
    
}
