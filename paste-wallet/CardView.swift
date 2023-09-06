//
//  CardView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct CardView: View {
    let store: StoreOf<CardFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
                
                LazyVGrid(columns: columns, spacing: 20, content: {
                    ForEach(viewStore.cards) { card in
                        cardView(card: card)
                    }
                })
                .padding()
                .onAppear {
                    viewStore.send(.fetchAll)
                }
            }
            .navigationTitle("tab_card")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.showAddView(show: true))
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: viewStore.binding(get: \.showAddView, send: CardFeature.Action.showAddView)) {
                        NavigationStack {
                            CardForm(store: Store(initialState: CardFormFeature.State(modelContext: viewStore.modelContext), reducer: {
                                CardFormFeature()
                            }))
                        }
                        .interactiveDismissDisabled(true)
                        .onDisappear {
                            viewStore.send(.fetchAll)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: CardView
    @ViewBuilder
    private func cardView(card: Card) -> some View {
        VStack {
            HStack {
                Text(card.name)
                Spacer()
            }
            Spacer()
            HStack {
                Text(card.number.last!)
                    .underline()
                Spacer()
                Text(card.issuer ?? "")
                    .font(.caption2)
            }
        }
        .padding()
        .aspectRatio(1.58, contentMode: .fill)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: card.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }
}

#Preview {
    let context = try! ModelContainer(for: Card.self, ModelConfiguration(inMemory: true)).mainContext
    
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["2838", "3532", "4521", "2342"], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["2838", "3532", "4521", "2342"], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["2838", "3532", "4521", "2342"], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["2838", "3532", "4521", "2342"], year: 28, month: 05, cvc: "435"))
    
    return NavigationStack {
        CardView(store: Store(initialState: CardFeature.State(modelContext: context), reducer: {
            CardFeature()
        }))
    }
}
