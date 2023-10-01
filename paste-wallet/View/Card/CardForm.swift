//
//  CardForm.swift
//  paste-wallet
//
//  Created by 최명근 on 9/5/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct CardForm: View {
    let store: StoreOf<CardFormFeature>
    
    private let brandOptions: [Card.Brand] = [.visa, .master, .amex, .klsc, .unionPay, .jcb, .discover, .europay, .local, .etc]
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("new_card_section_information") {
                    TextField("new_card_name", text: viewStore.binding(get: { state in
                        state.name ?? ""
                    }, send: { value in
                        CardFormFeature.Action.nameChanged(text: value)
                    }))
                    
                    TextField("new_card_issuer", text: viewStore.binding(get: { state in
                        state.issuer ?? ""
                    }, send: { value in
                        CardFormFeature.Action.issuerChanged(text: value)
                    }))
                    
                    Picker("new_card_brand", selection: viewStore.binding(get: \.brand, send: CardFormFeature.Action.brandChanged)) {
                        ForEach(brandOptions, id: \.self) { brand in
                            Text("brand_\(brand.rawValue)".localized)
                                .tag(brand)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    ColorPicker("new_card_color", selection: viewStore.binding(get: \.color, send: CardFormFeature.Action.colorChanged))
                }
                
                Section("new_card_section_number") {
                    HStack(spacing: 4) {
                        if viewStore.brand == .amex {
                            ForEach(0..<3) { i in
                                TextField(String("*****"), text: viewStore.binding(get: { state in
                                    return state.number[i]
                                }, send: { value in
                                    return .numberChanged(index: i, number: value.filter { $0.isNumber })
                                }))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .multilineTextAlignment(.center)
                                
                                if i < 2 {
                                    Text("-")
                                }
                            }
                        } else {
                            ForEach(0..<4) { i in
                                TextField(String("****"), text: viewStore.binding(get: { state in
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
                        
                        Text(String("/"))
                        
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
                        
                        TextField(String("***"), text: viewStore.binding(get: { state in
                            return state.cvc ?? ""
                        }, send: { value in
                            return .cvcChanged(cvc: value.filter { $0.isNumber })
                        }))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("new_card_section_optional") {
                    ZStack {
                        TextEditor(text: viewStore.binding(get: { state in
                            return state.memo ?? ""
                        }, send: { value in
                            return .memoChanged(memo: value.isEmpty ? nil : value)
                        }))
                        .frame(minHeight: 100)
                        
                        if viewStore.memo == nil || viewStore.memo!.isEmpty {
                            VStack {
                                HStack {
                                    Text("new_card_memo_placeholder")
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    Spacer()
                                }
                                .padding(8)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewStore.card == nil ? "title_card_form" : "card_edit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        viewStore.send(.save)
                        dismiss()
                    }
                    .foregroundStyle(viewStore.confirmButtonDisabled ? Colors.textTertiary.color : Colors.textPrimary.color)
                    .disabled(viewStore.confirmButtonDisabled)
                    .onChange(of: viewStore.dismiss) {
                        dismiss()
                    }
                }
                
                if viewStore.card == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("cancel") {
                            dismiss()
                        }
                        .foregroundStyle(Colors.textPrimary.color)
                    }
                }
            }
        }
    }
}

#Preview {
    return NavigationStack {
        CardForm(store: Store(initialState: CardFormFeature.State(key: "000000"), reducer: {
            CardFormFeature()
        }))
    }
}
