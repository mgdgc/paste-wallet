//
//  MemoView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Reducer
struct MemoFeature {
  @ObservableState
  struct State: Equatable {
    let key: String

    var memos: [Memo] = []

    @Presents var memoForm: MemoFormFeature.State?
    @Presents var memoDetail: MemoDetailFeature.State?
  }

  enum Action {
    case fetchAll
    case fetchAllResult([Memo])
    case showMemoForm
    case showMemoDetail(Memo)

    case memoForm(PresentationAction<MemoFormFeature.Action>)
    case memoDetail(PresentationAction<MemoDetailFeature.Action>)
  }

  @Dependency(\.persistence) var persistence

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchAll:
        return .run { send in
          guard let context = try? await persistence.context() else { return }
          let memos = Memo.fetchAll(context)
          await send(.fetchAllResult(memos))
        }

      case .fetchAllResult(let memos):
        state.memos = memos
        return .none

      case .showMemoForm:
        state.memoForm = .init(key: state.key)
        return .none

      case .showMemoDetail(let memo):
        state.memoDetail = .init(key: state.key, memo: memo)
        return .none

      case .memoForm(.dismiss):
        return .send(.fetchAll)

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
