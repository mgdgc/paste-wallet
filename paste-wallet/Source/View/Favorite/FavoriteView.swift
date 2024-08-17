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
    @Bindable var store: StoreOf<FavoriteFeature>
    
    var body: some View {
        GeometryReader { proxy in
            if store.cards.isEmpty && store.banks.isEmpty {
                emptyView()
            } else {
                ScrollView {
                    // MARK: - Cards
                    if !store.cards.isEmpty {
                        GroupBox {
                            LazyVGrid(
                                columns: Array(
                                    repeating: GridItem(.flexible()),
                                    count: Int(proxy.size.width) / 160
                                ),
                                pinnedViews: .sectionHeaders
                            ) {
                                ForEach(store.cards) { card in
                                    Button {
                                        store.send(.playHaptic)
                                        store.send(.showCardDetail(card))
                                    } label: {
                                        SmallCardCell(
                                            card: card,
                                            key: store.key
                                        )
                                        .contextMenu {
                                            contextMenu(for: card)
                                        }
                                    }
                                }
                            }
                        } label: {
                            sectionHeader(
                                title: "favorite_section_card",
                                systemImage: "creditcard",
                                tab: .card
                            )
                        }
                        .backgroundStyle(Color.clear)
                    }
                    
                    // MARK: - Banks
                    if !store.banks.isEmpty {
                        GroupBox {
                            LazyVGrid(
                                columns: Array(
                                    repeating: GridItem(.flexible()),
                                    count: Int(proxy.size.width) / 160
                                ),
                                pinnedViews: .sectionHeaders
                            ) {
                                ForEach(store.banks) { bank in
                                    Button {
                                        store.send(.playHaptic)
                                        store.send(.showBankDetail(bank))
                                    } label: {
                                        SmallBankView(
                                            bank: bank,
                                            key: store.key
                                        )
                                        .contextMenu {
                                            contextMenu(for: bank)
                                        }
                                    }
                                    
                                }
                            }
                        } label: {
                            sectionHeader(
                                title: "favorite_section_bank",
                                image: "bank",
                                tab: .bank
                            )
                        }
                        .backgroundStyle(Color.clear)
                    }
                }
            }
        }
        .sensoryFeedback(.impact, trigger: store.haptic)
        .onAppear {
            store.send(.fetchCard)
            store.send(.fetchBank)
        }
        .background(
            Colors.backgroundSecondary.color.ignoresSafeArea()
        )
        .navigationTitle("tab_favorite")
        .fullScreenCover(
            item: $store.scope(
                state: \.cardDetail,
                action: \.cardDetail
            )
        ) { store in
            NavigationStack {
                CardDetailView(store: store)
            }
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.bankDetail,
                action: \.bankDetail
            )
        ) { store in
            NavigationStack {
                BankDetailView(store: store)
            }
        }
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image("empty_favorite")
                .renderingMode(.template)
                .resizable()
                .frame(maxWidth: 156, maxHeight: 156)
                .foregroundStyle(Colors.textPrimary.color)
            
            HStack {
                Spacer()
                Text("favorite_empty")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
            HStack {
                Button {
                    store.send(.setTab(.card))
                } label: {
                    Label("tab_card", systemImage: "creditcard")
                }
                
                Button {
                    store.send(.setTab(.bank))
                } label: {
                    Label("tab_bank", image: "bank")
                }
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func sectionHeader(
        title: LocalizedStringKey,
        systemImage: String? = nil,
        image: String? = nil,
        tab: WalletView.Tab? = nil
    ) -> some View {
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
                    store.send(.setTab(tab))
                } label: {
                    Image(systemName: "chevron.forward")
                }
            }
        }
    }
    
    @ViewBuilder
    private func contextMenu(for card: Card) -> some View {
        Button(
            "card_context_copy_all",
            systemImage: "doc.on.doc"
        ) {
            store.send(.copyCard(card, .dash))
        }
        
        Button(
            "card_context_copy_numbers",
            systemImage: "textformat.123"
        ) {
            store.send(.copyCard(card, .none))
        }
        
        Button(
            "card_context_unfavorite",
            systemImage: "star.fill",
            role: .destructive
        ) {
            store.send(.unfavoriteCard(card))
        }
    }
    
    @ViewBuilder
    private func contextMenu(for bank: Bank) -> some View {
        Button(
            "bank_context_copy_all",
            systemImage: "doc.on.doc"
        ) {
            store.send(.copyBank(bank, false))
        }
        
        Button(
            "bank_context_copy_numbers_only",
            systemImage: "textformat.123"
        ) {
            store.send(.copyBank(bank, true))
        }
        
        Button(
            "bank_context_unfavorite",
            systemImage: "star.fill",
            role: .destructive
        ) {
            store.send(.unfavoriteBank(bank))
        }
    }
    
}
