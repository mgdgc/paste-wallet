//
//  MemoForm+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

struct MemoFormFeature: Reducer {
    
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
        let key: String
        
        var title: String = ""
        var desc: String = ""
        var fields: [MemoFormField] = []
        
        var confirmButtonDisabled: Bool {
            title.isEmpty
        }
    }
    
    enum Action: Equatable {
        case setTitle(String)
        case setDesc(String)
        case addField
        case setField(_ index: Int, _ keyPath: WritableKeyPath<MemoFormField, String>, _ value: String)
        case deleteField(_ index: Int)
        case save
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setTitle(title):
            state.title = title
            return .none
            
        case let .setDesc(desc):
            state.desc = desc
            return .none
            
        case .addField:
            state.fields.append(MemoFormField())
            return .none
            
        case let .setField(index, keyPath, value):
            state.fields[index][keyPath: keyPath] = value
            return .none
            
        case let .deleteField(index):
            state.fields.remove(at: index)
            return .none
            
        case .save:
            var memo = Memo(title: state.title, desc: state.desc)
            var fields: [MemoField] = []
            for f in state.fields {
                fields.append(MemoField(title: f.fieldName, value: f.value))
            }
            memo.fields = fields
            state.modelContext.insert(memo)
            return .none
        }
    }
}
