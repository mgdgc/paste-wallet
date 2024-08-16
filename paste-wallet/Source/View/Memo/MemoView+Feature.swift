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

@Reducer
struct MemoFeature {
    @ObservableState
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
        let key: String
        
        var memos: [Memo] = []
        
        @Presents var memoForm: MemoFormFeature.State?
        @Presents var memoDetail: MemoDetailFeature.State?
    }
    
    enum Action {
        case fetchAll
        case showMemoForm
        case showMemoDetail(Memo)
        
        case memoForm(PresentationAction<MemoFormFeature.Action>)
        case memoDetail(PresentationAction<MemoDetailFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
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
                
            default: return .none
            }
        }
        .ifLet(\.$memoForm, action: \.memoForm) {
            MemoFormFeature()
        }
        .ifLet(\.$memoDetail, action: \.memoDetail) {
            MemoDetailFeature()
        }
    }
}
