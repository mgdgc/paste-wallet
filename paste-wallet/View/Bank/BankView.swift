//
//  BankView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct BankView: View {
    let store: StoreOf<BankFeature>
    
    var body: some View {
        Text(String("Hello, World!"))
    }
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
    return BankView(store: Store(initialState: BankFeature.State(modelContext: context), reducer: {
        BankFeature()
    }))
}
