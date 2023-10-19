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
    let store: StoreOf<BankDetailFeature>
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Colors.backgroundSecondary.color.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    bankView
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
                        Section("bank_section_information") {
                            SecretField(title: "bank_number", content: viewStore.bank.decryptNumber(viewStore.key), locked: viewStore.binding(get: \.locked, send: BankDetailFeature.Action.setLock))
                        }
                        
                        if let memo = viewStore.bank.memo, !memo.isEmpty {
                            Section("bank_memo") {
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
                        
                        Section {
                            Button("bank_set_favorite", systemImage: viewStore.bank.favorite ? "star.fill" : "star") {
                                viewStore.send(.setFavorite)
                            }
                            
                            Button(role: .destructive) {
                                viewStore.send(.showDeleteConfirmation(true))
                            } label: {
                                Label("delete", systemImage: "trash")
                                    .foregroundStyle(Color.red)
                            }
                            .alert("delete_confirmation_title", isPresented: viewStore.binding(get: \.showDeleteConfirmation, send: BankDetailFeature.Action.showDeleteConfirmation)) {
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
                        viewStore.send(.showBankForm)
                    }
                    .foregroundStyle(Colors.textPrimary.color)
                    .navigationDestination(store: store.scope(state: \.$bankForm, action: BankDetailFeature.Action.bankForm)) { store in
                        BankForm(store: store)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var bankView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Text(viewStore.bank.name)
                        .font(.title2)
                    Spacer()
                    Text(viewStore.bank.bank)
                        .font(.title3)
                }
                
                Spacer()
                
                HStack {
                    if viewStore.locked {
                        Text(viewStore.bank.decryptNumber(viewStore.key))
                            .lineLimit(2)
                            .font(.title2)
                            .underline()
                            .overlay {
                                Rectangle()
                                    .fill(.thinMaterial)
                            }
                    } else {
                        Menu {
                            Button("bank_context_copy_all", systemImage: "doc.on.doc") {
                                viewStore.send(.copy(false))
                            }
                            
                            Button("bank_context_copy_numbers_only", systemImage: "textformat.123") {
                                viewStore.send(.copy(true))
                            }
                        } label: {
                            Text(viewStore.bank.decryptNumber(viewStore.key))
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
            .foregroundStyle(UIColor(hexCode: viewStore.bank.color).isDark ? Color.white : Color.black)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor(hexCode: viewStore.bank.color)))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
            )
        }
    }
}

#Preview {
    let modelContext = ModelContext(try! ModelContainer(for: Bank.self, configurations: .init(isStoredInMemoryOnly: true)))
    let bank = Bank(name: "주계좌", bank: "토스뱅크", color: "#eeedff", number: "fRA2PFBGYONOw8ZV73gujA==")
    modelContext.insert(bank)
    
    return NavigationStack {
        BankDetailView(store: Store(initialState: BankDetailFeature.State(modelContext: modelContext, key: "000000", bank: bank), reducer: {
            BankDetailFeature()
        }))
    }
}
