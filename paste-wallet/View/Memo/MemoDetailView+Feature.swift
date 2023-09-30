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
        var memo: Memo
    }
    
    enum Action: Equatable {
        case addField
        case deleteField(_ index: Int)
        case setField(_ index: Int, _ keyPath: WritableKeyPath<MemoField, String>, _ value: String)
        case rearrange(_ from: Int, _ to: Int)
        case delete
        case save
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
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
        }
    }
}
