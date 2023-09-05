//
//  CardForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/5/23.
//

import SwiftUI
import ComposableArchitecture

struct CardForm: View {
    let store: StoreOf<CardFormFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("new_card_section_information") {
                    TextField("new_card_name", text: viewStore.binding(get: \.name, send: CardFormFeature.Action.nameChanged))
                    
                    TextField("new_card_issuer", text: viewStore.binding(get: \.issuer, send: CardFormFeature.Action.issuerChanged))
                    
                    ColorPicker("new_card_color", selection: viewStore.binding(get: \.color, send: CardFormFeature.Action.colorChanged))
                }
                
                Section("new_card_section_number") {
                    HStack(spacing: 4) {
                        ForEach(0..<4) { i in
                            TextField("*****", text: viewStore.binding(get: { state in
                                return state.number[i]
                            }, send: { value in
                                return .numberChanged(index: i, number: value.filter { $0.isNumber })
                            }))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                            
                            if i < 3 {
                                Text("-")
                            }
                        }
                    }
                    
                    HStack {
                        Text("new_card_date")
                        
                        Spacer()
                        
                        TextField("expire_month", text: viewStore.binding(get: { state in
                            return state.month == nil ? "" : String(format: "%02d", state.month!)
                        }, send: { value in
                            return .monthChanged(month: Int(value.filter { $0.isNumber }))
                        }))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 36)
                        
                        Text("/")
                        
                        TextField("expire_year", text: viewStore.binding(get: { state in
                            return state.year == nil ? "" : String(format: "%02d", state.year!)
                        }, send: { value in
                            return .yearChanged(year: Int(value.filter { $0.isNumber }))
                        }))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 36)
                    }
                    
                    HStack {
                        Text("new_card_cvc")
                        
                        Spacer()
                        
                        TextField("***", text: viewStore.binding(get: { state in
                            return state.cvc ?? ""
                        }, send: { value in
                            return .cvcChanged(cvc: value.filter { $0.isNumber })
                        }))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("new_card_section_optional") {
                    
                }
            }
        }
    }
}

#Preview {
    CardForm(store: Store(initialState: CardFormFeature.State(), reducer: {
        CardFormFeature()
    }))
}
