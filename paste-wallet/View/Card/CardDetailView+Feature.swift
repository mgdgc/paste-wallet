//
//  CardDetailView+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

struct CardDetailFeature: Reducer {
    
    struct State: Equatable {
        let modelContext: ModelContext
        let card: Card
    }
    
    enum Action: Equatable {
        
    }
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action> {
        switch action {
            
        }
    }
    
}
