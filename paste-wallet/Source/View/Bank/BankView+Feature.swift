//
//  BankView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/10/23.
//

import ActivityKit
import ComposableArchitecture
import Foundation
import SwiftData
import UIKit
import UniformTypeIdentifiers

@Reducer
struct BankFeature {
  @ObservableState
  struct State: Equatable {
    let key: String

    var openByWidget: String?

    var haptic: UUID = UUID()
    var banks: [Bank] = []

    @Shared(.appStorage(UserDefaultsKey.Settings.itemHaptic))
    var useHaptic: Bool = false

    @Presents var bankForm: BankFormFeature.State?
    @Presents var bankDetail: BankDetailFeature.State?
  }

  enum Action {
    case onAppear
    case fetchAll
    case fetchAllResult([Bank])
    case playHaptic
    case showBankForm
    case showBankDetail(Bank)
    case deleteBank(Bank)
    case copy(_ bank: Bank, _ numbersOnly: Bool)
    case stopLiveActivity
    case showTargetBank(String)

    case bankForm(PresentationAction<BankFormFeature.Action>)
    case bankDetail(PresentationAction<BankDetailFeature.Action>)
  }
  
  @Dependency(\.persistence) var persistence

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        let openByWidget = state.openByWidget
        return .run { send in
          await send(.fetchAll)
          if let openByWidgetBank = openByWidget {
            await send(.showTargetBank(openByWidgetBank))
          }
        }

      case .fetchAll:
        return .run { send in
          guard let context = try? await persistence.context() else { return }
          let banks = Bank.fetchAll(modelContext: context)
          await send(.fetchAllResult(banks))
        }
        
      case .fetchAllResult(let banks):
        state.banks = banks
        return .none

      case .playHaptic:
        if state.useHaptic {
          state.haptic = UUID()
        }
        return .none

      case .showBankForm:
        state.bankForm = .init(key: state.key)
        return .none

      case .showBankDetail(let bank):
        state.bankDetail = .init(key: state.key, bank: bank)
        return .none

      case .deleteBank(let bank):
        return .run { @MainActor send in
          do {
            let context = try await persistence.context()
            context.delete(bank)
            try context.save()
          } catch {
            print(#function, "save error")
            print(error)
          }
          send(.fetchAll)
        }

      case .copy(let bank, let numbersOnly):
        if numbersOnly {
          var copyText = ""
          for c in bank.decryptNumber(state.key) {
            if c.isNumber {
              copyText.append(c)
            }
          }
          UIPasteboard.general.setValue(copyText, forPasteboardType: UTType.plainText.identifier)
        } else {
          UIPasteboard.general.setValue(
            bank.decryptNumber(state.key),
            forPasteboardType: UTType.plainText.identifier
          )
        }
        return .none

      case .stopLiveActivity:
        return .run { send in
          for activity in Activity<BankWidgetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
          }
        }

      case .showTargetBank(let id):
        if let bank = state.banks.first(where: { $0.id.uuidString == id }) {
          return .send(.showBankDetail(bank))
        } else {
          return .none
        }

      case .bankForm(.dismiss):
        return .send(.fetchAll)

      case .bankDetail(.dismiss):
        return .send(.fetchAll)

      default:
        return .none
      }
    }
    .ifLet(\.$bankForm, action: \.bankForm) {
      BankFormFeature()
    }
    .ifLet(\.$bankDetail, action: \.bankDetail) {
      BankDetailFeature()
    }
  }
}
