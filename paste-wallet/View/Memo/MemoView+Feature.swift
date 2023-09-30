//
//  MemoView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import ComposableArchitecture

struct MemoFeature: Reducer {
    
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
        let key: String
        
        var memos: [Memo] = []
        
        @PresentationState var memoForm: MemoFormFeature.State?
        @PresentationState var memoDetail: MemoDetailFeature.State?
    }
    
    enum Action: Equatable {
        case fetchAll
        case showMemoForm
        case showMemoDetail(Memo)
        
        case memoForm(PresentationAction<MemoFormFeature.Action>)
        case memoDetail(PresentationAction<MemoDetailFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchAll:
                state.memos = Memo.fetchAll(state.modelContext)
                return .none
                
            case .showMemoForm:
                state.memoForm = .init(key: state.key)
                return .none
                
            case let .showMemoDetail(memo):
                state.memoDetail = .init(key: state.key, memo: memo)
                return .none
                
            case let .memoForm(action):
                return .none
                
            case let .memoDetail(action):
                return .none
            }
        }
        .ifLet(\.$memoForm, action: /Action.memoForm) {
            MemoFormFeature()
        }
        .ifLet(\.$memoDetail, action: /Action.memoDetail) {
            MemoDetailFeature()
        }
    }
}
