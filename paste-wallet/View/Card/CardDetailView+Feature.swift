//
//  CardDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import Foundation
import SwiftUI
import SwiftData
import ActivityKit
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
        case launchActivity
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
            
        case .launchActivity:
            let attributes = PasteWalletWidgetAttributes(name: "card")
            let contentState = PasteWalletWidgetAttributes.ContentState(
                id: state.card.id,
                name: state.card.name,
                issuer: state.card.issuer,
                brand: state.card.wrappedBrand,
                color: state.card.color,
                number: state.card.decryptNumber(key: state.key),
                year: state.card.year,
                month: state.card.month,
                cvc: state.card.getWrappedCVC(state.key))
            let content = ActivityContent(state: contentState, staleDate: .now.advanced(by: 3600))
            
            do {
                let activity = try Activity<PasteWalletWidgetAttributes>.request(
                    attributes: attributes,
                    content: content)
                print(activity)
            } catch {
                print(#function, error)
            }
            return .none
        }
    }
    
}
