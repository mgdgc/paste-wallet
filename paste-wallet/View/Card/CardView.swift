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
                if viewStore.cards.isEmpty {
                    emptyView
                    
                } else {
                    ScrollView {
                        let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
                        
                        LazyVGrid(columns: columns, spacing: 20, content: {
                            ForEach(viewStore.cards) { card in
                                Button {
                                    viewStore.send(.showCardView(card: card))
                                } label: {
                                    SmallCardCell(card: card, key: viewStore.key)
                                        .contextMenu {
                                            contextMenu(viewStore, for: card)
                                        } preview: {
                                            CardPreview(card: card, key: viewStore.key, size: proxy.size)
                                        }
                                }
                                .fullScreenCover(item: viewStore.binding(get: \.showCardView, send: CardFeature.Action.showCardView)) { card in
                                    NavigationStack {
                                        CardDetailView(store: Store(initialState: CardDetailFeature.State(modelContext: viewStore.modelContext, key: viewStore.key, card: card), reducer: {
                                            CardDetailFeature()
                                        }))
                                    }
                                }
                            }
                        })
                        .padding()
                    }}
                
            }
            .onAppear {
                viewStore.send(.fetchAll)
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
                        CardForm(store: Store(initialState: CardFormFeature.State(modelContext: viewStore.modelContext, key: viewStore.key), reducer: {
                            CardFormFeature()
                        }))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Colors.textPrimary.color)
                    }
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
    
    private var emptyView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("card_empty")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func contextMenu(_ store: ViewStore<CardFeature.State, CardFeature.Action>, for card: Card) -> some View {
        Button("card_context_copy_all", systemImage: "doc.on.doc") {
            store.send(.copy(card: card, separator: .dash))
        }
        
        Button("card_context_copy_numbers", systemImage: "textformat.123") {
            store.send(.copy(card: card, separator: .none))
        }
        
        Button("card_context_delete", systemImage: "trash", role: .destructive) {
            store.send(.delete(card: card))
        }
    }
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
//    for c in Card.previewItems() {
//        context.insert(c)
//    }
    
    return NavigationStack {
        CardView(store: Store(initialState: CardFeature.State(modelContext: context, key: "000000"), reducer: {
            CardFeature()
        }))
    }
}
