//
//  BankDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/27/23.
//

import Foundation
import SwiftUI
import SwiftData
import ActivityKit
import ComposableArchitecture

struct BankDetailFeature: Reducer {
    
    struct State: Equatable {
        var modelContext: ModelContext = PasteWalletApp.sharedModelContext
        let key: String
        let bank: Bank
        var dismiss: Bool = false
        var showDeleteConfirmation: Bool = false
        
        var draggedOffset: CGSize = .zero
    }
    
    enum Action: Equatable {
        case dragChanged(DragGesture.Value)
        case dragEnded(DragGesture.Value)
        case dismiss
        case setFavorite
        case showDeleteConfirmation(Bool)
        case delete
        case launchActivity
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
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
            
        case .dismiss:
            state.dismiss = true
            return .none
            
        case .setFavorite:
            state.bank.favorite.toggle()
            do {
                try state.modelContext.save()
            } catch {
                print(#function, "save error")
                print(error)
            }
            return .none
            
        case let .showDeleteConfirmation(show):
            state.showDeleteConfirmation = show
            return .none
            
        case .delete:
            state.modelContext.delete(state.bank)
            do {
                try state.modelContext.save()
            } catch {
                print(#function, "save error")
                print(error)
            }
            return .send(.dismiss)
            
        case .launchActivity:
            let attribute = BankWidgetAttributes(id: state.bank.id)
            let contentState = BankWidgetAttributes.ContentState(
                name: state.bank.name,
                bank: state.bank.bank, 
                color: state.bank.color,
                number: state.bank.decryptNumber(state.key))
            let content = ActivityContent(state: contentState, staleDate: .now.advanced(by: 3600))
            
            do {
                let activity = try Activity<BankWidgetAttributes>.request(
                    attributes: attribute,
                    content: content)
                print(activity)
            } catch {
                print(#function, error)
            }
            return .none
        }
    }
}
