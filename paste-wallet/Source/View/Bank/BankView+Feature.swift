//
//  BankView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/10/23.
//

import Foundation
import UIKit
import SwiftData
import UniformTypeIdentifiers
import ComposableArchitecture
import ActivityKit

@Reducer
struct BankFeature {
    @ObservableState
    struct State: Equatable {
        let modelContext: ModelContext = PasteWalletApp.sharedModelContext
        let key: String
        
        var openByWidget: String?
        
        var haptic: UUID = UUID()
        var banks: [Bank] = []
        
        @Shared(.appStorage(UserDefaultsKey.Settings.itemHaptic))
        var useHaptic: Bool = false
        
        @Presents var bankForm: BankFormFeature.State?
        @Presents var bankDetail: BankDetailFeature.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchAll
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
                state.banks = Bank.fetchAll(modelContext: state.modelContext)
                return .none
                
            case .playHaptic:
                if state.useHaptic {
                    state.haptic = UUID()
                }
                return .none
                
            case .showBankForm:
                state.bankForm = .init(key: state.key)
                return .none
                
            case let .showBankDetail(bank):
                state.bankDetail = .init(key: state.key, bank: bank)
                return .none
                
            case let .deleteBank(bank):
                state.modelContext.delete(bank)
                do {
                    try state.modelContext.save()
                } catch {
                    print(#function, "save error")
                    print(error)
                }
                return .send(.fetchAll)
                
            case let .copy(bank, numbersOnly):
                if numbersOnly {
                    var copyText = ""
                    for c in bank.decryptNumber(state.key) {
                        if c.isNumber {
                            copyText.append(c)
                        }
                    }
                    UIPasteboard.general.setValue(copyText, forPasteboardType: UTType.plainText.identifier)
                } else {
                    UIPasteboard.general.setValue(bank.decryptNumber(state.key), forPasteboardType: UTType.plainText.identifier)
                }
                return .none
                
            case .stopLiveActivity:
                return .run { send in
                    for activity in Activity<BankWidgetAttributes>.activities {
                        await activity.end(nil, dismissalPolicy: .immediate)
                    }
                }
                
            case let .showTargetBank(id):
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
