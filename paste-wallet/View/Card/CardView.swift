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
                    emptyView(viewStore)
                    
                } else {
                    ScrollView {
                        let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewStore.cards) { card in
                                Button {
                                    viewStore.send(.showCardDetail(card: card))
                                } label: {
                                    SmallCardCell(card: card, key: viewStore.key)
                                        .contextMenu {
                                            contextMenu(viewStore, for: card)
                                        } preview: {
                                            CardPreview(card: card, key: viewStore.key, size: proxy.size)
                                        }
                                }
                                .fullScreenCover(store: store.scope(state: \.$cardDetail, action: CardFeature.Action.cardDetail)) {
                                    viewStore.send(.stopLiveActivity)
                                } content: { store in
                                    NavigationStack {
                                        CardDetailView(store: store)
                                    }
                                }

                            }
                        }
                        .padding()
                    }}
                
            }
            .onAppear {
                viewStore.send(.fetchAll)
            }
            .navigationTitle("tab_card")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.showCardForm)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Colors.textPrimary.color)
                    }
                    .sheet(store: store.scope(state: \.$cardForm, action: CardFeature.Action.cardForm), content: { store in
                        NavigationStack {
                            CardForm(store: store)
                        }
                        .interactiveDismissDisabled()
                    })
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
    
    private func emptyView(_ viewStore: ViewStore<CardFeature.State, CardFeature.Action>) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image("empty_card")
                .renderingMode(.template)
                .resizable()
                .frame(maxWidth: 156, maxHeight: 156)
                .foregroundStyle(Colors.textPrimary.color)
            HStack {
                Spacer()
                Text("card_empty")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            Button("card_empty_add", systemImage: "plus") {
                viewStore.send(.showCardForm)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .sheet(store: store.scope(state: \.$cardForm, action: CardFeature.Action.cardForm), content: { store in
                NavigationStack {
                    CardForm(store: store)
                }
                .interactiveDismissDisabled()
            })
            Spacer()
        }
        .padding()
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
    NavigationStack {
        CardView(store: Store(initialState: CardFeature.State(key: "000000"), reducer: {
            CardFeature()
        }))
    }
}
