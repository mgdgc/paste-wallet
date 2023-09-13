//
//  FavoriteView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct FavoriteView: View {
    let store: StoreOf<FavoriteFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { proxy in
                ScrollView {
                    GroupBox {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], pinnedViews: .sectionHeaders) {
                            
                            // MARK: - Cards
                            ForEach(viewStore.cards) { card in
                                if let key = viewStore.key {
                                    SmallCardCell(card: card, key: key)
                                        .onTapGesture {
                                            viewStore.send(.showCardDetail(card))
                                        }
                                        .fullScreenCover(item: viewStore.binding(get: \.showCard, send: FavoriteFeature.Action.showCardDetail)) { card in
                                            NavigationStack {
                                                CardDetailView(store: Store(initialState: CardDetailFeature.State(modelContext: viewStore.modelContext, key: key, card: card), reducer: {
                                                    CardDetailFeature()
                                                }))
                                            }
                                        }
                                        .onDisappear {
                                            viewStore.send(.fetchCard)
                                        }
                                }
                            }
                        }
                    } label: {
                        sectionHeader(title: "favorite_section_card", systemImage: "creditcard")
                    }
                    .onAppear {
                        viewStore.send(.fetchCard)
                    }
                }
            }
            .background(Colors.backgroundSecondary.color.ignoresSafeArea())
            .navigationTitle("tab_favorite")
        }
    }
    
    @ViewBuilder
    private func sectionHeader(title: LocalizedStringKey, systemImage: String? = nil) -> some View {
        HStack {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
                .font(.title.bold())
            Spacer()
        }
    }
    
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
    for c in Card.previewItems() {
        context.insert(c)
    }
    
    return NavigationStack {
        FavoriteView(store: Store(initialState: FavoriteFeature.State(modelContext: context, key: "000000", tab: .favorite), reducer: {
            FavoriteFeature()
        }))
    }
}
