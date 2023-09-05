//
//  Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct CardFeature: Reducer {
    
    struct State: Equatable {
        var modelContext: ModelContext
        var cards: [Card] = []
        
        // 새로운 카드 추가 View
        var showAddView: Bool = false
        
        // 카드 Drag and drop
        var draggingItem: Card?
    }
    
    enum Action: Equatable {
        case fetchAll
        case showAddView(show: Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchAll:
            state.cards = Card.fetchAll(modelContext: state.modelContext)
            return .none
            
        case let .showAddView(show):
            state.showAddView = show
            return .none
        }
    }
    
}
