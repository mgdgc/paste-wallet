//
//  CardForm+Feature.swift
//  paste-wallet
//
//  Created by 최명근 on 9/5/23.
//

import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture

@Reducer
struct CardFormFeature {
  @ObservableState
  struct State: Equatable {
    var card: Card?
    let key: String
    
    var name: String = ""
    var issuer: String = ""
    var brand: Card.Brand = .visa
    var color: Color = Color.white
    var number: [String] = ["", "", "", ""]
    var year: String = ""
    var month: String = ""
    var cvc: String = ""
    var memo: String = ""
    var dismiss: Bool = false
    
    var confirmButtonDisabled: Bool {
      name.isEmpty &&
      issuer.isEmpty &&
      year.isEmpty &&
      month.isEmpty
    }
    
    init(
      key: String,
      card: Card? = nil
    ) {
      self.card = card
      self.key = key
      if let card = card {
        self.name = card.name
        self.issuer = card.issuer ?? ""
        self.brand = Card.Brand(rawValue: card.brand) ?? .etc
        self.color = Color(hexCode: card.color)
        self.number = card.decryptNumber(key: key)
        self.year = "\(card.year)"
        self.month = "\(card.month)"
        self.cvc = card.getWrappedCVC(key) ?? ""
        self.memo = card.memo ?? ""
      }
    }
  }
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case ui(UI)
    case db(DB)
    
    case brandChanged(brand: Card.Brand)
    
    enum UI {
      case onAppear
      case tapSaveButton
    }
    
    enum DB {
      case fetchCard
      case saveCard
      case saveChanges(Card)
    }
  }
  
  @Dependency(\.persistence) var persistence: PersistenceClient
  
  var body: some ReducerOf<Self> {
    CombineReducers {
      BindingReducer()
      
      Reduce { state, action in
        switch action {
        case .binding:
          return .none
          
        case .ui(_):
          return .none
          
        case .db(_):
          return .none
          
        case let .brandChanged(brand):
          if brand == .amex {
            state.number = ["", "", ""]
          } else {
            state.number = ["", "", "", ""]
          }
          return .none
        }
      }
      
      Reduce<State, Action> { state, action in
        guard case let .ui(action) = action else { return .none }
        switch action {
        case .onAppear:
          return .send(.db(.fetchCard))
          
        case .tapSaveButton:
          if let card = state.card {
            return .send(.db(.saveChanges(card)))
          } else {
            return .send(.db(.saveCard))
          }
        }
      }
      
      Reduce<State, Action> { state, action in
        guard case let .db(action) = action else { return .none }
        switch action {
        case .fetchCard:
          return .none
          
        case .saveCard:
          guard !state.name.isEmpty,
                !state.issuer.isEmpty,
                let year = try? Int(state.year, format: .number),
                let month = try? Int(state.month, format: .number) else {
            return .none
          }
          let card = Card(
            name: state.name,
            issuer: state.issuer,
            brand: state.brand,
            color: state.color.hex,
            number: Card.encryptNumber(state.key, state.number),
            year: year,
            month: month,
            cvc: state.cvc.isEmpty ? nil : Card.encryptCVC(state.key, state.cvc),
            memo: state.memo.isEmpty ? nil : state.memo
          )
          return .run { @MainActor send in
            do {
              let context = try await persistence.context()
              context.insert(card)
              try context.save()
            } catch {
              debugPrint(error)
            }
          }
          
        case .saveChanges(let card):
          guard !state.name.isEmpty,
                !state.issuer.isEmpty,
                let year = try? Int(state.year, format: .number),
                let month = try? Int(state.month, format: .number) else {
            return .none
          }
          card.name = state.name
          card.issuer = state.issuer
          card.brand = state.brand.rawValue
          card.color = state.color.hex
          card.number = Card.encryptNumber(state.key, state.number)
          card.year = year
          card.month = month
          card.cvc = state.cvc.isEmpty ? nil : Card.encryptCVC(state.key, state.cvc)
          card.memo = state.memo.isEmpty ? nil : state.memo
          return .run { @MainActor send in
            do {
              let context = try await persistence.context()
              try context.save()
            } catch {
              debugPrint(error)
            }
          }
        }
      }
    }
  }
}
