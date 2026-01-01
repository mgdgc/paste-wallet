//
//  BankForm+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/20/23.
//

import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI

@Reducer
struct BankFormFeature {
  @ObservableState
  struct State: Equatable {
    let key: String
    let bank: Bank?

    var bankName: String = ""
    var name: String = ""
    var color: Color = Color.white
    var accountNumber: String = ""
    var memo: String = ""

    var confirmButtonDisabled: Bool {
      bankName.isEmpty || name.isEmpty || accountNumber.isEmpty
    }

    init(key: String, bank: Bank? = nil) {
      self.key = key
      self.bank = bank
      if let bank = bank {
        self.bankName = bank.bank
        self.name = bank.name
        self.color = Color(hexCode: bank.color)
        self.accountNumber = bank.decryptNumber(key)
        self.memo = bank.memo ?? ""
      }
    }
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case setAccountNumber(String)
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
      case .setAccountNumber(let value):
        var value = value
        value.removeAll(where: { !$0.isNumber && $0 != "-" })
        state.accountNumber = value
        return .none

      case .save:
        if state.bank != nil {
          state.bank?.bank = state.bankName
          state.bank?.name = state.name
          state.bank?.number = Bank.encryptNumber(state.key, state.accountNumber)
          state.bank?.color = state.color.hex
          state.bank?.memo = state.memo

        } else {
          let bank = Bank(
            name: state.name,
            bank: state.bankName,
            color: state.color.hex,
            number: Bank.encryptNumber(state.key, state.accountNumber),
            memo: state.memo
          )
          return .run { @MainActor send in
            guard let context = try? await persistence.context() else { return }
            context.insert(bank)
            await send(.saveContext)
          }
        }
        return .send(.saveContext)

      case .saveContext:
        return .run { send in
          do {
            let context = try await persistence.context()
            try context.save()
          } catch {
            print(#function, "save error")
            print(error)
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
