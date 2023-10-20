//
//  CardDetailView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct SecretField: View {
    var title: LocalizedStringKey
    var content: String
    
    @Binding var locked: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Colors.textPrimary.color)
            Spacer()
            if locked {
                Text(String(content))
                    .textSelection(.enabled)
                    .foregroundStyle(Colors.textSecondary.color)
                    .overlay {
                        if locked {
                            Rectangle()
                                .fill(.thinMaterial)
                        }
                    }
            } else {
                Text(String(content))
                    .textSelection(.enabled)
                    .foregroundStyle(Colors.textSecondary.color)
                    .textSelection(.enabled)
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
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Colors.backgroundSecondary.color.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    cardView
                        .padding([.top, .horizontal])
                        .offset(viewStore.draggedOffset)
                        .zIndex(1)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    viewStore.send(.dragChanged(value))
                                }
                                .onEnded { value in
                                    viewStore.send(.dragEnded(value))
                                }
                        )
                    
                    List {
                        Section("card_section_info") {
                            SecretField(title: "card_expire", content: viewStore.card.wrappedExpirationDate, locked: viewStore.binding(get: \.locked, send: CardDetailFeature.Action.setLock))
                            if let cvc = viewStore.card.getWrappedCVC(viewStore.key) {
                                SecretField(title: "card_cvc", content: cvc, locked: viewStore.binding(get: \.locked, send: CardDetailFeature.Action.setLock))
                            }
                        }
                        
                        if let memo = viewStore.card.memo {
                            Section("card_section_memo") {
                                HStack {
                                    if viewStore.locked {
                                        ImmutableTextView(text: .constant(memo))
                                            .overlay {
                                                Rectangle()
                                                    .fill(.thinMaterial)
                                            }
                                    } else {
                                        ImmutableTextView(text: .constant(memo))
                                    }
                                }
                            }
                        }
                        
                        Section {
                            Button("card_set_favorite", systemImage: viewStore.card.favorite ? "star.fill" : "star") {
                                viewStore.send(.setFavorite)
                            }
                            
                            Button(role: .destructive) {
                                viewStore.send(.showDeleteConfirmation(true))
                            } label: {
                                Label("delete", systemImage: "trash")
                                    .foregroundStyle(Color.red)
                            }
                            .alert("delete_confirmation_title", isPresented: viewStore.binding(get: \.showDeleteConfirmation, send: CardDetailFeature.Action.showDeleteConfirmation)) {
                                Button("cancel", role: .cancel) {
                                    viewStore.send(.showDeleteConfirmation(false))
                                }
                                Button("delete", role: .destructive) {
                                    viewStore.send(.delete)
                                }
                            } message: {
                                Text("delete_confirmation_message")
                            }
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
                if viewStore.biometricAvailable {
                    viewStore.send(.unlock)
                }
            }
            .onChange(of: viewStore.dismiss) { oldValue, newValue in
                dismiss()
            }
            .onChange(of: scenePhase) { oldValue, newValue in
                if oldValue == .background && newValue == .inactive {
                    viewStore.send(.lock)
                }
            }
            .onChange(of: viewStore.locked) { old, new in
                if !new {
                    viewStore.send(.launchActivity)
                } else {
                    viewStore.send(.stopActivity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done") {
                        viewStore.send(.dismiss)
                    }
                    .foregroundStyle(Colors.textPrimary.color)
                }
                
                ToolbarItem(placement: .principal) {
                    if viewStore.locked {
                        Button("unlock", systemImage: "lock") {
                            viewStore.send(.unlock)
                        }
                    } else {
                        Button("lock", systemImage: "lock.open") {
                            viewStore.send(.lock)
                        }
                    }
                }
                
                ToolbarItem {
                    Button("edit") {
                        viewStore.send(.showEdit)
                    }
                    .foregroundStyle(Colors.textPrimary.color)
                    .navigationDestination(store: store.scope(state: \.$cardForm, action: CardDetailFeature.Action.cardForm)) { store in
                        CardForm(store: store)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var cardView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                    if viewStore.locked {
                        Text(viewStore.card.getWrappedNumber(viewStore.key, .space))
                            .font(.title2)
                            .underline()
                            .overlay {
                                Rectangle()
                                    .fill(.thinMaterial)
                            }
                    } else {
                        Menu {
                            Button("card_context_copy_all", systemImage: "doc.on.doc") {
                                store.send(.copy(separator: .dash))
                            }
                            Button("card_context_copy_numbers", systemImage: "textformat.123") {
                                store.send(.copy(separator: .none))
                            }
                        } label: {
                            Text(viewStore.card.getWrappedNumber(viewStore.key, .space))
                                .font(.title2)
                                .underline()
                        }
                    }
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
