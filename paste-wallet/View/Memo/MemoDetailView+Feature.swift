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
import UniformTypeIdentifiers
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
        case addField
        case deleteField(_ index: Int)
        case setField(_ index: Int, _ keyPath: WritableKeyPath<MemoField, String>, _ value: String)
        case rearrange(_ from: Int, _ to: Int)
        case showDeleteConfirmation(Bool)
        case showMemoForm
        case delete
        case save
        
        case memoForm(PresentationAction<MemoFormFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addField:
                if state.memo.fields == nil {
                    state.memo.fields = []
                }
                state.memo.fields?.append(MemoField(title: "", value: ""))
                return .send(.save)
                
            case let .deleteField(index):
                state.memo.fields?.remove(at: index)
                return .send(.save)
                
            case let .setField(index, keyPath, value):
                state.memo.fields?[index][keyPath: keyPath] = value
                return .send(.save)
                
            case let .rearrange(from, to):
                state.memo.fields?.move(fromOffsets: [from], toOffset: to)
                return .send(.save)
                
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
                    print(#function, "save error")
                    print(error)
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
