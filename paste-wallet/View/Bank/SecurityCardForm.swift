//
//  SecurityCardForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/27/23.
//

import SwiftUI
import ComposableArchitecture

struct SecurityCardForm: View {
    let store: StoreOf<SecurityCardFormFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
        }
    }
}

#Preview {
    SecurityCardForm(store: Store(initialState: SecurityCardFormFeature.State(), reducer: {
        SecurityCardFormFeature()
    }))
}
