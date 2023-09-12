//
//  CardDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

struct CardDetailFeature: Reducer {
    
    struct State: Equatable {
        let modelContext: ModelContext
        let key: String
        
        let card: Card
        
        var draggedOffset: CGSize = .zero
        
        var dismiss: Bool = false
    }
    
    enum Action: Equatable {
        case dragChanged(DragGesture.Value)
        case dragEnded(DragGesture.Value)
        case setFavorite
        case delete
        case dismiss
    }
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action> {
        switch action {
        case let .dragChanged(value):
            state.draggedOffset = CGSize(width: .zero, height: value.translation.height)
            return .none
            
        case let .dragEnded(value):
            if value.translation.height > 100 {
                return .send(.dismiss)
            } else {
                state.draggedOffset = .zero
                return .none
            }
            
        case .setFavorite:
            state.card.favorite.toggle()
            do {
                try state.modelContext.save()
            } catch {
                print(#function, error)
            }
            return .none
            
        case .delete:
            return .send(.dismiss)
            
        case .dismiss:
            state.dismiss.toggle()
            return .none
        }
    }
    
}
