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
                                            viewStore.send(.setTab(.card))
                                        }
                                }
                            }
                        }
                    } label: {
                        sectionHeader(title: "favorite_section_card")
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
    private func sectionHeader(title: LocalizedStringKey) -> some View {
        HStack {
            Text(title)
                .font(.title.bold())
            Spacer()
        }
    }
    
}

#Preview {
    let context = try! ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    
    context.insert(Card(name: "ZERO Edition 2 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "435", favorite: true))
    context.insert(Card(name: "ZERO Edition 2 2", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "435"))
    context.insert(Card(name: "ZERO Edition 2 3", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "435", favorite: true))
    context.insert(Card(name: "ZERO Edition 2 4", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA==", "fRA2PFBGYONOw8ZV73gujA=="], year: 28, month: 05, cvc: "435"))
    
    return NavigationStack {
        FavoriteView(store: Store(initialState: FavoriteFeature.State(modelContext: context, key: "000000", tab: .favorite), reducer: {
            FavoriteFeature()
        }))
    }
}
