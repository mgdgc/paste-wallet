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

struct BankFormFeature: Reducer {
    
    struct State: Equatable {
        let modelContext: ModelContext = ModelContext(PasteWalletApp.sharedModelContainer)
        let key: String
        
        var bankName: String = ""
        var name: String = ""
        var color: Color = Color.white
        var accountNumber: String = ""
        var memo: String = ""
        
        var confirmButtonDisabled: Bool {
            bankName.isEmpty || name.isEmpty || accountNumber.isEmpty
        }
    }
    
    enum Action: Equatable {
        case setBankName(String)
        case setName(String)
        case setColor(Color)
        case setAccountNumber(String)
        case setMemo(String)
        case save
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
            return .none
        }
    }
    
}
