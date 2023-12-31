////
////  CardEditView.swift
////  paste-wallet
////
////  Created by 최명근 on 10/1/23.
////
//
//import SwiftUI
//import SwiftData
//import ComposableArchitecture
//
//struct CardEditView: View {
//    let store: StoreOf<CardEditFeature>
//    
//    private let brandOptions: [Card.Brand] = [.visa, .master, .amex, .klsc, .unionPay, .jcb, .discover, .europay, .local, .etc]
//    
//    var body: some View {
//        WithViewStore(store, observe: { $0 }) { viewStore in
//            Form {
//                Section("new_card_section_information") {
//                    TextField("new_card_name", text: viewStore.binding(get: \.card.name, send: CardEditFeature.Action.setName))
//                    
//                    TextField("new_card_issuer", text: viewStore.binding(get: { $0.card.issuer ?? "" }, send: CardEditFeature.Action.setIssuer))
//                    
//                    Picker("new_card_brand", selection: viewStore.binding(get: { Card.Brand(rawValue: $0.card.brand) ?? .etc }, send: CardEditFeature.Action.setBrand)) {
//                        ForEach(brandOptions, id: \.self) { brand in
//                            Text("brand_\(brand.rawValue)".localized)
//                                .tag(brand)
//                        }
//                    }
//                    .pickerStyle(.navigationLink)
//                    
//                    ColorPicker("new_card_color", selection: viewStore.binding(get: { Color(hexCode: $0.card.color) }, send: CardEditFeature.Action.setColor))
//                }
//                
//                Section("new_card_section_number") {
//                    HStack(spacing: 4) {
//                        if viewStore.card.brand == .amex {
//                            ForEach(0..<3) { i in
//                                TextField(String(i == 1 ? "*****" : "****"), text: viewStore.binding(get: { $0.wrappedNumber[i] }, send: { .setNumber(i, $0) }))
//                                .keyboardType(.decimalPad)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .multilineTextAlignment(.center)
//                                
//                                if i < 2 {
//                                    Text(String("-"))
//                                }
//                            }
//                        } else {
//                            ForEach(0..<4) { i in
//                                TextField(String("****"), text: viewStore.binding(get: { $0.wrappedNumber[i] }, send: { .setNumber(i, $0) }))
//                                .keyboardType(.decimalPad)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .multilineTextAlignment(.center)
//                                
//                                if i < 3 {
//                                    Text(String("-"))
//                                }
//                            }
//                        }
//                    }
//                    
////                    HStack {
////                        Text("new_card_date")
////                        
////                        Spacer()
////                        
////                        TextField("expire_month", text: viewStore.binding(get: { state in
////                            return state.month == nil ? "" : String(format: "%02d", state.month!)
////                        }, send: { value in
////                            return .monthChanged(month: Int(value.filter { $0.isNumber }))
////                        }))
////                        .keyboardType(.decimalPad)
////                        .multilineTextAlignment(.center)
////                        .frame(maxWidth: 36)
////                        
////                        Text(String("/"))
////                        
////                        TextField("expire_year", text: viewStore.binding(get: { state in
////                            return state.year == nil ? "" : String(format: "%02d", state.year!)
////                        }, send: { value in
////                            return .yearChanged(year: Int(value.filter { $0.isNumber }))
////                        }))
////                        .keyboardType(.decimalPad)
////                        .multilineTextAlignment(.center)
////                        .frame(maxWidth: 36)
////                    }
////                    
////                    HStack {
////                        Text("new_card_cvc")
////                        
////                        Spacer()
////                        
////                        TextField(String("***"), text: viewStore.binding(get: { state in
////                            return state.cvc ?? ""
////                        }, send: { value in
////                            return .cvcChanged(cvc: value.filter { $0.isNumber })
////                        }))
////                        .keyboardType(.decimalPad)
////                        .multilineTextAlignment(.trailing)
////                    }
//                }
////                
////                Section("new_card_section_optional") {
////                    ZStack {
////                        TextEditor(text: viewStore.binding(get: { state in
////                            return state.memo ?? ""
////                        }, send: { value in
////                            return .memoChanged(memo: value.isEmpty ? nil : value)
////                        }))
////                        .frame(minHeight: 100)
////                        
////                        if viewStore.memo == nil || viewStore.memo!.isEmpty {
////                            VStack {
////                                HStack {
////                                    Text("new_card_memo_placeholder")
////                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
////                                    Spacer()
////                                }
////                                .padding(8)
////                                Spacer()
////                            }
////                        }
////                    }
////                }
//            }
//        }
//    }
//}
//
//#Preview {
//    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
//    let card = Card.previewItems().first!
//    context.insert(card)
//    return NavigationStack {
//        CardEditView(store: Store(initialState: CardEditFeature.State(modelContext: context, key: "000000", card: card), reducer: {
//            CardEditFeature()
//        }))
//    }
//}
