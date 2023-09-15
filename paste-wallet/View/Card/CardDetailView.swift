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
    var isCredential: Bool = false
    
    @State private var reveal: Bool = false
    
    var body: some View {
        Button {
            reveal.toggle()
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(Colors.textPrimary.color)
                Spacer()
                
                if reveal || !isCredential {
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

fileprivate struct CardDetailSection<Content>: View where Content: View {
    var sectionTitle: LocalizedStringKey? = nil
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            if let sectionTitle = sectionTitle {
                HStack {
                    Text(sectionTitle)
                        .padding(.top, 8)
                        .padding(.horizontal, 4)
                    Spacer()
                }
            }
            VStack {
                content()
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Colors.backgroundPrimary.color)
            }
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
                
                List {
                    Section("card_section_info") {
                        SecretField(title: "card_expire", content: viewStore.card.wrappedExpirationDate, isCredential: false)
                        SecretField(title: "card_cvc", content: viewStore.card.getWrappedCVC(viewStore.key) ?? "", isCredential: true)
                    }
                    
                    if let memo = viewStore.card.memo {
                        Section("card_section_memo") {
                            TextEditor(text: .constant(memo))
                                .scrollDisabled(true)
                        }
                    }
                    
                    Section {
                        Button("card_set_favorite", systemImage: viewStore.card.favorite ? "star.fill" : "star") {
                            viewStore.send(.setFavorite)
                        }
                        .foregroundStyle(Colors.textPrimary.color)
                        
                        Button("delete", systemImage: "trash") {
                            viewStore.send(.delete)
                        }
                        .foregroundStyle(Color.red)
                    }
                }
                .scrollContentBackground(.hidden)
                .safeAreaInset(edge: .top, content: {
                    Spacer().frame(height: 20)
                })
                .offset(y: -8)
                .ignoresSafeArea()
            }
            .onChange(of: viewStore.dismiss) { oldValue, newValue in
                dismiss()
            }
            .onAppear {
                viewStore.send(.launchActivity)
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
                Text(viewStore.card.getWrappedNumber(viewStore.key, .space))
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
    
    let card = Card.previewItems().first!
    
    for c in Card.previewItems() {
        context.insert(c)
    }
    
    return NavigationStack {
        CardDetailView(store: Store(initialState: CardDetailFeature.State(modelContext: context, key: "000000", card: card), reducer: {
            CardDetailFeature()
        }))
    }
}
