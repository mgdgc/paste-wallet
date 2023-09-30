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
                    
                    // MARK: - Cards
                    GroupBox {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], pinnedViews: .sectionHeaders) {
                            ForEach(viewStore.cards) { card in
                                SmallCardCell(card: card, key: viewStore.key)
                                    .onTapGesture {
                                        viewStore.send(.showCardDetail(card))
                                    }
                                    .fullScreenCover(store: store.scope(state: \.$cardDetail, action: FavoriteFeature.Action.cardDetail)) {
                                        viewStore.send(.stopLiveActivity)
                                    } content: { store in
                                        NavigationStack {
                                            CardDetailView(store: store)
                                        }
                                        .onDisappear {
                                            viewStore.send(.fetchCard)
                                        }
                                    }
                            }
                        }
                    } label: {
                        sectionHeader(title: "favorite_section_card", systemImage: "creditcard", tab: .card)
                    }
                    .backgroundStyle(Color.clear)
                    
                    // MARK: - Banks
                    GroupBox {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], pinnedViews: .sectionHeaders) {
                            ForEach(viewStore.banks) { bank in
                                SmallBankView(bank: bank, key: viewStore.key)
                            }
                        }
                    } label: {
                        sectionHeader(title: "favorite_section_bank", image: "bank", tab: .bank)
                    }
                    .backgroundStyle(Color.clear)
                }
                .onAppear {
                    viewStore.send(.fetchCard)
                }
            }
            .background(Colors.backgroundSecondary.color.ignoresSafeArea())
            .navigationTitle("tab_favorite")
        }
    }
    
    @ViewBuilder
    private func sectionHeader(title: LocalizedStringKey, systemImage: String? = nil, image: String? = nil, tab: WalletView.Tab? = nil) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                } else if let image = image {
                    Image(image)
                }
                Text(title)
                    .font(.title.bold())
                Spacer()
                if let tab = tab {
                    Button {
                        viewStore.send(.setTab(tab))
                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                }
            }
        }
    }
    
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
    for c in Card.previewItems() {
        context.insert(c)
    }
    
    return NavigationStack {
        FavoriteView(store: Store(initialState: FavoriteFeature.State(key: "000000"), reducer: {
            FavoriteFeature()
        }))
    }
}
