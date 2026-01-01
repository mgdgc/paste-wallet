//
//  MemoForm+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI

@Reducer
struct MemoFormFeature {
  @ObservableState
  struct State: Equatable {
    let key: String
    let memo: Memo?

    var title: String = ""
    var desc: String = ""
    var fields: [MemoFormField] = [.init()]

    var confirmButtonEnabled: Bool {
      !title.isEmpty && fields.allSatisfy { !$0.fieldName.isEmpty && !$0.value.isEmpty }
    }

    init(
      key: String,
      memo: Memo? = nil
    ) {
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
  @Dependency(\.persistence) var persistence

  var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .addField:
        guard let lastField = state.fields.last,
          !lastField.fieldName.isEmpty,
          !lastField.value.isEmpty
        else {
          return .none
        }
        state.fields.append(MemoFormField())
        return .none

      case .setMemoFieldTitle(let index, let title):
        guard index < state.fields.count else { return .none }
        state.fields[index].fieldName = title
        return .none

      case .setMemoFieldValue(let index, let value):
        guard index < state.fields.count else { return .none }
        state.fields[index].value = value
        return .none

      case .deleteField(let index):
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
          return .run { @MainActor send in
            guard let context = try? await persistence.context() else { return }
            context.insert(memo)
            send(.saveContext)
          }
        }
        return .send(.saveContext)

      case .saveContext:
        return .run { send in
          guard let context = try? await persistence.context() else { return }
          do {
            try context.save()
          } catch {
            print(#function, error)
          }
          await send(.dismiss)
        }

      case .dismiss:
        return .run { _ in
          await dismiss()
        }

      default: return .none
      }
    }
  }
}
