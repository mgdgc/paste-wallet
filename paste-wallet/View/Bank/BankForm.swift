//
//  BankForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/20/23.
//

import SwiftUI
import ComposableArchitecture

struct BankForm: View {
    let store: StoreOf<BankFormFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
        }
    }
}

#Preview {
    
    return NavigationStack {
        BankForm(store: Store(initialState: BankFormFeature.State(), reducer: {
            BankFormFeature()
        }))
    }
}
