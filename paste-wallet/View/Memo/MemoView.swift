//
//  MemoView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import UIKit
import SwiftUI
import SwiftData
import ComposableArchitecture

struct MemoView: View {
    let store: StoreOf<MemoFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.memos) { memo in
                    NavigationLink {
                        
                    } label: {
                        VStack {
                            HStack {
                                Text(memo.title)
                                    .font(.headline)
                                Spacer()
                            }
                            HStack {
                                Text(memo.desc)
                                    .font(.footnote)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.fetchAll)
            }
            .navigationTitle("tab_memo")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Colors.textPrimary.color)
                    }
                }
            }
        }
        .background {
            Colors.backgroundSecondary.color.ignoresSafeArea()
        }
    }
}

#Preview {
    let modelContext = ModelContext(try! ModelContainer(for: Memo.self, MemoField.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
    
    let memo = Memo(title: "Memo 1", desc: "memo")
    modelContext.insert(memo)
    
    return NavigationStack {
        MemoView(store: Store(initialState: MemoFeature.State(modelContext: modelContext, key: "000000"), reducer: {
            MemoFeature()
        }))
    }
}
