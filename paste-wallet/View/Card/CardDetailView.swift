//
//  CardDetailView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

fileprivate struct SecretField: View {
    var title: LocalizedStringKey
    var content: String
    var isLongText: Bool = false
    var isCredential: Bool = false
    
    @State private var reveal: Bool = false
    
    var body: some View {
        Button {
            reveal.toggle()
        } label: {
            if isLongText {
                VStack(spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.caption)
                            .foregroundStyle(Colors.textPrimary.color)
                        Spacer()
                    }
                    
                    HStack {
                        if reveal {
                            Text("card_info_lock")
                        } else {
                            Text("card_info_lock")
                        }
                        Spacer()
                    }
                }
            } else {
                HStack {
                    Text(title)
                        .foregroundStyle(Colors.textPrimary.color)
                    Spacer()
                    
                    if reveal {
                        Text(String(content))
                            .foregroundStyle(Colors.textSecondary.color)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(Colors.textSecondary.color)
                        Text("card_info_lock")
                            .foregroundStyle(Colors.textSecondary.color)
                    }
                }
            }
        }
    }
}

fileprivate struct CardDetailSection<Content>: View where Content: View {
    var sectionTitle: LocalizedStringKey? = nil
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            content()
                .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Colors.backgroundPrimary.color)
        }
    }
}

struct CardDetailView: View {
    let store: StoreOf<CardDetailFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                cardView(viewStore: viewStore)
                    .padding([.top, .horizontal])
                    .offset(viewStore.draggedOffset)
                    .gesture(dragGesture(viewStore: viewStore))
                    .zIndex(1)
                
                ScrollView {
                    Spacer().frame(height: 20)
                    
                    CardDetailSection {
                        SecretField(title: "card_cvc", content: viewStore.card.cvc ?? "", isCredential: true)
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
                .offset(y: -16)
            }
            .onChange(of: viewStore.dismiss) { oldValue, newValue in
                dismiss()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done") {
                        viewStore.send(.dismiss)
                    }
                    .foregroundStyle(Colors.textPrimary.color)
                }

                ToolbarItem {
                    Button("edit") {
                        viewStore.send(.dismiss)
                    }
                    .foregroundStyle(Colors.textPrimary.color)
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
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
        .aspectRatio(1.58, contentMode: .fit)
        .foregroundStyle(UIColor(hexCode: viewStore.card.color).isDark ? Color.white : Color.black)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: viewStore.card.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }
    
    private func dragGesture(viewStore: ViewStore<CardDetailFeature.State, CardDetailFeature.Action>) -> some Gesture {
        DragGesture()
            .onChanged { value in
                viewStore.send(.dragChanged(value))
            }
            .onEnded { value in
                viewStore.send(.dragEnded(value))
            }
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
