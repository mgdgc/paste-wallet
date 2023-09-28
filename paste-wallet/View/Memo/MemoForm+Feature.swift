//
//  MemoForm+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

struct MemoFormFeature: Reducer {
    
    struct State: Equatable {
        var modelContext = PasteWalletApp.sharedModelContext
    }
    
    enum Action: Equatable {
        
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        }
    }
}
