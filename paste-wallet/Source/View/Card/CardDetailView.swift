//
//  CardDetailView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

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
    @Bindable var store: StoreOf<CardDetailFeature>
    
    @State private var dragOffset: CGSize = .zero
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            Colors.backgroundSecondary.color.ignoresSafeArea()
            
            VStack(spacing: 0) {
                cardView
                    .padding([.top, .horizontal])
                    .offset(dragOffset)
                    .zIndex(1)
                    .gesture(dragGesture)
                
                List {
                    Section("card_section_info") {
                        SecretField(
                            title: "card_expire",
                            content: store.card.wrappedExpirationDate,
                            locked: $store.isCardInfoLocked
                        )
                        if let cvc = store.card.getWrappedCVC(store.key) {
                            SecretField(
                                title: "card_cvc",
                                content: cvc,
                                locked: $store.isCardInfoLocked
                            )
                        }
                    }
                    
                    if let memo = store.card.memo, !memo.isEmpty {
                        Section("card_section_memo") {
                            HStack {
                                Text(memo)
                                    .textSelection(.enabled)
                                    .overlay {
                                        if store.isCardInfoLocked {
                                            Rectangle()
                                                .fill(.thinMaterial)
                                        }
                                    }
                                Spacer()
                            }
                        }
                    }
                    
                    Section {
                        Button(
                            "card_set_favorite",
                            systemImage: store.card.favorite ? "star.fill" : "star"
                        ) {
                            store.send(.toggleFavorite)
                        }
                        
                        Button(role: .destructive) {
                            store.send(.binding(.set(\.showDeleteConfirmation, true)))
                        } label: {
                            Label("delete", systemImage: "trash")
                                .foregroundStyle(Color.red)
                        }
                        .alert(
                            "delete_confirmation_title",
                            isPresented: $store.showDeleteConfirmation) {
                            Button("cancel", role: .cancel) { }
                            Button("delete", role: .destructive) {
                                store.send(.deleteCard)
                            }
                        } message: {
                            Text("delete_confirmation_message")
                        }
                        .disabled(store.isCardInfoLocked)
                    }
                }
                .scrollContentBackground(.hidden)
                .safeAreaInset(edge: .top, content: {
                    Spacer().frame(height: 20)
                })
                .offset(y: -8)
                .ignoresSafeArea()
            }
            .frame(maxWidth: 480)
        }
        .onAppear {
            if store.biometricAvailable {
                store.send(.authenticate)
            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if oldValue == .background && newValue == .inactive {
                store.send(.setCardInfoLock(true))
            }
        }
        .onChange(of: store.isCardInfoLocked) { old, new in
            if !new {
                store.send(.launchActivity)
            } else {
                store.send(.stopActivity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("done") {
                    store.send(.dismiss)
                }
                .foregroundStyle(Colors.textPrimary.color)
            }
            
            ToolbarItem(placement: .principal) {
                if store.isCardInfoLocked {
                    Button("unlock", systemImage: "lock") {
                        store.send(.authenticate)
                    }
                } else {
                    Button("lock", systemImage: "lock.open") {
                        store.send(.setCardInfoLock(true))
                    }
                }
            }
            
            if !store.isCardInfoLocked {
                ToolbarItem {
                    Button("edit") {
                        store.send(.editCard)
                    }
                    .foregroundStyle(Colors.textPrimary.color)
                }
            }
        }
        .navigationDestination(
            item: $store.scope(state: \.cardForm, action: \.cardForm)
        ) { store in
            CardForm(store: store)
        }
    }
    
    private var cardView: some View {
        VStack {
            HStack {
                Text(store.card.name)
                    .font(.title2)
                Spacer()
                Text(store.card.issuer ?? "")
                    .font(.title3)
            }
            
            Spacer()
            
            HStack {
                if store.isCardInfoLocked {
                    Text(store.card.getWrappedNumber(store.key, .space))
                        .font(.title2)
                        .underline()
                        .overlay {
                            Rectangle()
                                .fill(.thinMaterial)
                        }
                } else {
                    Menu {
                        Button(
                            "card_context_copy_all",
                            systemImage: "doc.on.doc"
                        ) {
                            store.send(.copyToClipboard(.dash))
                        }
                        
                        Button(
                            "card_context_copy_numbers",
                            systemImage: "textformat.123"
                        ) {
                            store.send(.copyToClipboard(.none))
                        }
                    } label: {
                        Text(store.card.getWrappedNumber(store.key, .space))
                            .font(.title2)
                            .underline()
                    }
                }
                Spacer()
                Text("brand_\(store.card.brand)".localized)
                    .font(.body.bold())
            }
        }
        .padding(20)
        .aspectRatio(1.58, contentMode: .fit)
        .foregroundStyle(
            UIColor(hexCode: store.card.color).isDark ? Color.white : Color.black
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: store.card.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = CGSize(width: .zero, height: value.translation.height)
            }
            .onEnded { value in
                if value.translation.height > 100 {
                    store.send(.dismiss)
                } else {
                    withAnimation {
                        dragOffset = .zero
                    }
                }
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
        CardDetailView(store: Store(initialState: CardDetailFeature.State(key: "000000", card: card), reducer: {
            CardDetailFeature()
        }))
    }
}
