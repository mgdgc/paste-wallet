//
//  BankDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/27/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

struct BankDetailFeature: Reducer {
    
    struct State: Equatable {
        var modelContext: ModelContext = ModelContext(PasteWalletApp.sharedModelContainer)
        let key: String
        let bank: Bank
    }
    
    enum Action: Equatable {
        
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        
    }
}
