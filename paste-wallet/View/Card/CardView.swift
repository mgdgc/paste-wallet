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
            GeometryReader { proxy in
                ScrollView {
                    let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
                    
                    LazyVGrid(columns: columns, spacing: 20, content: {
                        ForEach(viewStore.cards) { card in
                            Button {
                                viewStore.send(.showCardView(card: card))
                            } label: {
                                cardView(card: card)
                                    .contextMenu {
                                        contextMenu(viewStore, for: card)
                                    } preview: {
                                        contextPreview(for: card, frame: proxy.size)
                                    }
                            }
                            .fullScreenCover(item: viewStore.binding(get: \.showCardView, send: CardFeature.Action.showCardView)) { card in
                                NavigationStack {
                                    CardDetailView(store: Store(initialState: CardDetailFeature.State(modelContext: viewStore.modelContext, card: card), reducer: {
                                        CardDetailFeature()
                                    }))
                                }
                            }

                        }
                    })
                    .padding()
                    .onAppear {
                        viewStore.send(.fetchAll)
                    }
                }
                .navigationTitle("tab_card")
                .toolbar {
//                    ToolbarItem(placement: .primaryAction) {
//                        Button {
//                            viewStore.send(.showAddView(show: true))
//                        } label: {
//                            Image(systemName: "plus.circle.fill")
//                                .foregroundStyle(Colors.textPrimary.color)
//                        }
//                        .sheet(isPresented: viewStore.binding(get: \.showAddView, send: CardFeature.Action.showAddView)) {
//                            NavigationStack {
//                                CardForm(store: Store(initialState: CardFormFeature.State(modelContext: viewStore.modelContext), reducer: {
//                                    CardFormFeature()
//                                }))
//                            }
//                            .interactiveDismissDisabled(true)
//                            .onDisappear {
//                                viewStore.send(.fetchAll)
//                            }
//                        }
//                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            CardForm(store: Store(initialState: CardFormFeature.State(modelContext: viewStore.modelContext), reducer: {
                                CardFormFeature()
                            }))
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Colors.textPrimary.color)
                        }
                    }
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
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
        .foregroundStyle(UIColor(hexCode: card.color).isDark ? Color.white : Color.black)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: card.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }
    
    @ViewBuilder
    private func contextMenu(_ store: ViewStore<CardFeature.State, CardFeature.Action>, for card: Card) -> some View {
        Button("card_context_copy_all", systemImage: "doc.on.doc") {
            store.send(.copy(card: card, includeSeparator: true))
        }
        
        Button("card_context_copy_numbers", systemImage: "textformat.123") {
            store.send(.copy(card: card, includeSeparator: false))
        }
        
        Button("card_context_delete", systemImage: "trash", role: .destructive) {
            store.send(.delete(card: card))
        }
    }
    
    @ViewBuilder
    private func contextPreview(for card: Card, frame: CGSize) -> some View {
        VStack {
            HStack {
                Text(card.name)
                    .font(.title2)
                Spacer()
                Text(card.issuer ?? "")
                    .font(.title3)
            }
            
            Spacer()
            
            HStack {
                Text(card.wrappedNumber)
                    .font(.title2)
                    .underline()
                Spacer()
                Text("brand_\(card.brand)".localized)
                    .font(.body.bold())
            }
        }
        .padding(20)
        .foregroundStyle(UIColor(hexCode: card.color).isDark ? Color.white : Color.black)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: card.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
        .frame(idealWidth: frame.width, idealHeight: frame.width * 100 / 158)
    }
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
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
