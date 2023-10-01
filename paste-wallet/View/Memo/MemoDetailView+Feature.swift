//
//  MemoDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/29/23.
//

import Foundation
import UIKit
import SwiftUI
import SwiftData
import ComposableArchitecture

struct MemoDetailFeature: Reducer {
    
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
        let key: String
        var memo: Memo
        
        var showDeleteConfirmation: Bool = false
        
        @PresentationState var memoForm: MemoFormFeature.State?
    }
    
    enum Action: Equatable {
        case showDeleteConfirmation(Bool)
        case showMemoForm
        case delete
        case save
        
        case memoForm(PresentationAction<MemoFormFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .showDeleteConfirmation(show):
                state.showDeleteConfirmation = show
                return .none
                
            case .showMemoForm:
                state.memoForm = .init(key: state.key, memo: state.memo)
                return .none
                
            case .delete:
                state.modelContext.delete(state.memo)
                return .send(.save)
                
            case .save:
                do {
                    try state.modelContext.save()
                } catch {
                    print(#function, error)
                }
                return .none
                
            case let .memoForm(action):
                return .none
            }
        }
        .ifLet(\.$memoForm, action: /Action.memoForm) {
            MemoFormFeature()
        }
    }
}
