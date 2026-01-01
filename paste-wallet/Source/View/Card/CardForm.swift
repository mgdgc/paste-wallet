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
  @Bindable var store: StoreOf<CardFormFeature>
  
  private let brandOptions: [Card.Brand] = Card.Brand.allCases
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    Form {
      Section("new_card_section_information") {
        TextField("new_card_name", text: $store.name)
          .submitLabel(.next)
        
        TextField("new_card_issuer", text: $store.issuer)
          .submitLabel(.next)
        
        Picker(
          "new_card_brand",
          selection: $store.brand
        ) {
          ForEach(brandOptions, id: \.self) { brand in
            Text("brand_\(brand.rawValue)".localized)
              .tag(brand)
          }
        }
        .pickerStyle(.navigationLink)
        .onChange(of: store.brand) { _, newValue in
          store.send(.brandChanged(brand: newValue))
        }
        
        ColorPicker("new_card_color", selection: $store.color)
      }
      
      Section("new_card_section_number") {
        HStack(spacing: 4) {
          ForEach(0..<store.number.count, id: \.self) { i in
            TextField(String("****"), text: $store.number[i])
              .keyboardType(.decimalPad)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .multilineTextAlignment(.center)
              .submitLabel(.next)
            
            if i < store.number.count - 1 {
              Text("-")
            }
          }
        }
        
        HStack {
          Text("new_card_date")
          
          Spacer()
          
          TextField("expire_month", text: $store.month)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 36)
            .submitLabel(.next)
          
          Text(String("/"))
          
          TextField("expire_year", text: $store.year)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 36)
            .submitLabel(.next)
        }
        
        HStack {
          Text("new_card_cvc")
          
          Spacer()
          
          TextField(String("***"), text: $store.cvc)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .submitLabel(.done)
        }
      }
      
      Section("new_card_section_optional") {
        ZStack {
          TextEditor(text: $store.memo)
            .frame(minHeight: 100)
          
          if store.memo.isEmpty {
            VStack {
              HStack {
                Text("new_card_memo_placeholder")
                  .foregroundStyle(
                    Color(uiColor: .secondaryLabel)
                  )
                Spacer()
              }
              .padding(8)
              Spacer()
            }
          }
        }
      }
    }
    .navigationTitle(
      store.card == nil ? "title_card_form" : "card_edit"
    )
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("save") {
          store.send(.ui(.tapSaveButton))
          dismiss()
        }
        .foregroundStyle(
          store.confirmButtonDisabled
          ? Colors.textTertiary.color
          : Colors.textPrimary.color
        )
        .disabled(store.confirmButtonDisabled)
        .onChange(of: store.dismiss) {
          dismiss()
        }
      }
      
      if store.card == nil {
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

#Preview {
  return NavigationStack {
    CardForm(store: Store(initialState: CardFormFeature.State(key: "000000"), reducer: {
      CardFormFeature()
    }))
  }
}
