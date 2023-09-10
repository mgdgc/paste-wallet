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
        var modelContext: ModelContext
    }
    
    enum Action: Equatable {
        case fetchAll
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchAll:
            return .none
        }
    }
}
