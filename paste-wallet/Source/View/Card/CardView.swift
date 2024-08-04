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
    @Bindable var store: StoreOf<CardFeature>
    
    var body: some View {
        GeometryReader { proxy in
            if store.cards.isEmpty {
                emptyView
                
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible()),
                            count: Int(proxy.size.width) / 160
                        ),
                        spacing: 20
                    ) {
                        ForEach(store.cards) { card in
                            Button {
                                store.send(.playHaptic)
                                store.send(.showCardDetail(card: card))
                            } label: {
                                SmallCardCell(card: card, key: store.key)
                                    .contextMenu {
                                        contextMenu(card: card)
                                    } preview: {
                                        CardPreview(
                                            card: card,
                                            key: store.key,
                                            size: proxy.size
                                        )
                                    }
                            }
                            .sensoryFeedback(
                                .impact,
                                trigger: store.haptic
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.cardDetail,
                action: \.cardDetail
            )
        ) {
            store.send(.stopLiveActivity)
        } content: { store in
            NavigationStack {
                CardDetailView(store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle("tab_card")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.showCardForm)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Colors.textPrimary.color)
                }
                .sheet(
                    item: $store.scope(
                        state: \.cardForm,
                        action: \.cardForm
                    )
                ) { store in
                    NavigationStack {
                        CardForm(store: store)
                    }
                    .interactiveDismissDisabled()
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
    
    private var emptyView: some View {
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
                store.send(.showCardForm)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func contextMenu(card: Card) -> some View {
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
