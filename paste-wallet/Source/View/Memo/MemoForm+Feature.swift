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

@Reducer
struct MemoFormFeature {
    @ObservableState
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
        let key: String
        let memo: Memo?
        
        var title: String = ""
        var desc: String = ""
        var fields: [MemoFormField] = [.init()]
        
        var confirmButtonEnabled: Bool {
            !title.isEmpty &&
            fields.allSatisfy { !$0.fieldName.isEmpty && !$0.value.isEmpty}
        }
        
        init(
            modelContext: ModelContext = PasteWalletApp.sharedModelContext,
            key: String,
            memo: Memo? = nil
        ) {
            self.modelContext = modelContext
            self.key = key
            self.memo = memo
            if let memo = memo {
                self.title = memo.title
                self.desc = memo.desc
                if let fields = memo.fields {
                    for field in fields {
                        self.fields.append(
                            MemoFormField(
                                fieldName: field.title,
                                value: field.decrypt(key)
                            )
                        )
                    }
                }
            }
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addField
        case setMemoFieldTitle(Int, String)
        case setMemoFieldValue(Int, String)
        case deleteField(Int)
        case save
        case saveContext
        case dismiss
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .addField:
                guard let lastField = state.fields.last,
                      !lastField.fieldName.isEmpty,
                      !lastField.value.isEmpty else {
                    return .none
                }
                state.fields.append(MemoFormField())
                return .none
                
            case let .setMemoFieldTitle(index, title):
                guard index < state.fields.count else { return .none }
                state.fields[index].fieldName = title
                return .none
                
            case let .setMemoFieldValue(index, value):
                guard index < state.fields.count else { return .none }
                state.fields[index].value = value
                return .none
                
            case let .deleteField(index):
                if index == 0 {
                    state.fields[index] = .init()
                    return .none
                }
                state.fields.remove(at: index)
                return .none
                
            case .save:
                var fields: [MemoField] = []
                for f in state.fields {
                    guard !f.fieldName.isEmpty, !f.value.isEmpty else { continue }
                    fields.append(
                        MemoField(
                            title: f.fieldName,
                            value: MemoField.encrypt(f.value, state.key)
                        )
                    )
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
                return .send(.dismiss)
                
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
                
            default: return .none
            }
        }
    }
}
