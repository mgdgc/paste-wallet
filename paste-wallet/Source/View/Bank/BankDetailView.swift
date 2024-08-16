//
//  BankDetailView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/27/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct BankDetailView: View {
    
    @Bindable var store: StoreOf<BankDetailFeature>
    
    @State private var dragOffset: CGSize = .zero
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            Colors.backgroundSecondary.color.ignoresSafeArea()
            
            VStack(spacing: 0) {
                bankView()
                    .padding([.top, .horizontal])
                    .offset(dragOffset)
                    .zIndex(1)
                    .gesture(dragGesture)
                
                List {
                    Section("bank_section_information") {
                        SecretField(
                            title: "bank_number",
                            content: store.bank.decryptNumber(store.key),
                            locked: $store.locked
                        )
                    }
                    
                    if let memo = store.bank.memo, !memo.isEmpty {
                        Section("bank_memo") {
                            HStack {
                                Text(memo)
                                    .textSelection(.enabled)
                                    .overlay {
                                        if store.locked {
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
                            "bank_set_favorite",
                            systemImage: store.bank.favorite ? "star.fill" : "star"
                        ) {
                            store.send(.setFavorite)
                        }
                        
                        Button(role: .destructive) {
                            store.send(.binding(.set(\.showDeleteConfirmation, true)))
                        } label: {
                            Label("delete", systemImage: "trash")
                                .foregroundStyle(Color.red)
                        }
                        .alert(
                            "delete_confirmation_title",
                            isPresented: $store.showDeleteConfirmation
                        ) {
                                Button("cancel", role: .cancel) {
                                    store.send(.binding(.set(\.showDeleteConfirmation, false)))
                                }
                                Button("delete", role: .destructive) {
                                    store.send(.delete)
                                }
                            } message: {
                                Text("delete_confirmation_message")
                            }
                            .disabled(store.locked)
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
                store.send(.unlock)
            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if oldValue == .background && newValue == .inactive {
                store.send(.lock)
            }
        }
        .onChange(of: store.locked) { old, new in
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
                if store.locked {
                    Button("unlock", systemImage: "lock") {
                        store.send(.unlock)
                    }
                } else {
                    Button("lock", systemImage: "lock.open") {
                        store.send(.lock)
                    }
                }
            }
            
            if !store.locked {
                ToolbarItem {
                    Button("edit") {
                        store.send(.showBankForm)
                    }
                    .foregroundStyle(Colors.textPrimary.color)
                }
            }
        }
        .navigationDestination(
            item: $store.scope(
                state: \.bankForm,
                action: \.bankForm
            )
        ) { store in
            BankForm(store: store)
        }
    }
    
    @ViewBuilder
    private func bankView() -> some View {
        VStack {
            HStack {
                Text(store.bank.name)
                    .font(.title2)
                Spacer()
                Text(store.bank.bank)
                    .font(.title3)
            }
            
            Spacer()
            
            HStack {
                if store.locked {
                    Text(store.bank.decryptNumber(store.key))
                        .lineLimit(2)
                        .font(.title2)
                        .underline()
                        .overlay {
                            Rectangle()
                                .fill(.thinMaterial)
                        }
                } else {
                    Menu {
                        Button(
                            "bank_context_copy_all",
                            systemImage: "doc.on.doc"
                        ) {
                            store.send(.copy(false))
                        }
                        
                        Button(
                            "bank_context_copy_numbers_only",
                            systemImage: "textformat.123"
                        ) {
                            store.send(.copy(true))
                        }
                    } label: {
                        Text(store.bank.decryptNumber(store.key))
                            .lineLimit(2)
                            .font(.title2)
                            .underline()
                    }
                }
                Spacer()
            }
        }
        .padding(20)
        .aspectRatio(1.58, contentMode: .fit)
        .foregroundStyle(
            (UIColor(hexCode: store.bank.color).isDark ?
             Color.white : Color.black))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: store.bank.color)))
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
