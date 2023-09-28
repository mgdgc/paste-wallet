//
//  MemoForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import SwiftUI
import ComposableArchitecture

struct MemoForm: View {
    let store: StoreOf<MemoFormFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                
            }
            .navigationTitle("memo_form")
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        MemoForm(store: Store(initialState: MemoFormFeature.State(), reducer: {
            MemoFormFeature()
        }))
    }
}
