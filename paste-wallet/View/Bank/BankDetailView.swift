//
//  BankDetailView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/27/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct BankDetailView: View {
    let store: StoreOf<BankDetailFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
        }
    }
}

#Preview {
    let modelContext = ModelContext(try! ModelContainer(for: Bank.self, configurations: .init(isStoredInMemoryOnly: true)))
    let bank = Bank(name: "주계좌", bank: "토스뱅크", color: "#eeedff", number: "1231-12314-234123")
    modelContext.insert(bank)
    
    return NavigationStack {
        BankDetailView(store: Store(initialState: BankDetailFeature.State(modelContext: modelContext, key: "000000", bank: bank), reducer: {
            BankDetailFeature()
        }))
    }
}
