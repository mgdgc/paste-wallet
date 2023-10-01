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
        let memo: Memo?
        
        var title: String = ""
        var desc: String = ""
        var fields: [MemoFormField] = []
        
        var confirmButtonDisabled: Bool {
            title.isEmpty
        }
        
        init(modelContext: ModelContext = PasteWalletApp.sharedModelContext, key: String, memo: Memo? = nil) {
            self.modelContext = modelContext
            self.key = key
            self.memo = memo
            if let memo = memo {
                self.title = memo.title
                self.desc = memo.desc
                if let fields = memo.fields {
                    for field in fields {
                        self.fields.append(MemoFormField(fieldName: field.title, value: field.decrypt(key)))
                    }
                }
            }
        }
    }
    
    enum Action: Equatable {
        case setTitle(String)
        case setDesc(String)
        case addField
        case setField(_ index: Int, _ keyPath: WritableKeyPath<MemoFormField, String>, _ value: String)
        case deleteField(_ index: Int)
        case save
        case saveContext
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
            var fields: [MemoField] = []
            for f in state.fields {
                fields.append(MemoField(title: f.fieldName, value: MemoField.encrypt(f.value, state.key)))
            }
            
            if state.memo != nil {
                state.memo?.title = state.title
                state.memo?.desc = state.desc
                state.memo?.fields = fields
                
            } else {
                let memo = Memo(title: state.title, desc: state.desc)
                memo.fields = fields
                state.modelContext.insert(memo)
            }
            return .send(.saveContext)
            
        case .saveContext:
            do {
                try state.modelContext.save()
            } catch {
                print(#function, error)
            }
            return .none
        }
    }
}
