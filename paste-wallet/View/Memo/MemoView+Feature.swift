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
    }
    
    enum Action: Equatable {
        case fetchAll
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchAll:
                state.memos = Memo.fetchAll(state.modelContext)
                return .none
            }
        }
    }
}