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
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                cardView(viewStore: viewStore)
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
                        HStack {
                            Text("bank_number")
                            Spacer()
                            Text(viewStore.bank.decryptNumber(viewStore.key))
                        }
                    }
                    
                    if let memo = viewStore.bank.memo, !memo.isEmpty {
                        Section("bank_memo") {
                            ImmutableTextView(text: .constant(memo))
                        }
                    }
                    
                    Section {
                        Button("bank_set_favorite", systemImage: viewStore.bank.favorite ? "star.fill" : "star") {
                            viewStore.send(.setFavorite)
                        }
                        
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
    func cardView(viewStore: ViewStore<BankDetailFeature.State, BankDetailFeature.Action>) -> some View {
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
                Text(viewStore.bank.decryptNumber(viewStore.key))
                    .lineLimit(2)
                    .font(.title2)
                    .underline()
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

#Preview {
    let modelContext = ModelContext(try! ModelContainer(for: Bank.self, configurations: .init(isStoredInMemoryOnly: true)))
    let bank = Bank(name: "주계좌", bank: "토스뱅크", color: "#eeedff", number: "1231-12314-234123")
    modelContext.insert(bank)
    
    return NavigationStack {
        BankDetailView(store: Store(initialState: BankDetailFeature.State(modelContext: modelContext, key: "000000", bank: bank), reducer: {
            BankDetailFeature()
        }))
    }
}
