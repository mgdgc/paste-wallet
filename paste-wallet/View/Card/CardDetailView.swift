//
//  CardDetailView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct CardDetailView: View {
    let store: StoreOf<CardDetailFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                cardView(viewStore: viewStore)
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    func cardView(viewStore: ViewStore<CardDetailFeature.State, CardDetailFeature.Action>) -> some View {
        VStack {
            HStack {
                Text(viewStore.card.name)
                    .font(.title2)
                Spacer()
                Text(viewStore.card.issuer ?? "")
                    .font(.title3)
            }
            
            Spacer()
            
            HStack {
                Text(viewStore.card.wrappedNumber)
                    .font(.title2)
                    .underline()
                Spacer()
                Text("brand_\(viewStore.card.brand)".localized)
                    .font(.body.bold())
            }
        }
        .padding(20)
        .aspectRatio(1.58, contentMode: .fill)
        .foregroundStyle(UIColor(hexCode: viewStore.card.color).isDark ? Color.white : Color.black)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: viewStore.card.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
    let card = Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["2838", "3532", "4521", "2342"], year: 28, month: 05, cvc: "435")
    
    context.insert(card)
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["2838", "3532", "4521", "2342"], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["2838", "3532", "4521", "2342"], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["2838", "3532", "4521", "2342"], year: 28, month: 05, cvc: "435"))
    
    return NavigationStack {
        CardDetailView(store: Store(initialState: CardDetailFeature.State(modelContext: context, card: card), reducer: {
            CardDetailFeature()
        }))
    }
}
