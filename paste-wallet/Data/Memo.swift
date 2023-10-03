//
//  Memo.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import Foundation
import SwiftData

@Model
final class Memo: Identifiable {
    var id: UUID
    var title: String
    var desc: String
    var touch: Date
    
    @Relationship(inverse: \MemoField.memo) var fields: [MemoField]?
    
    init(id: UUID = UUID(), title: String, desc: String) {
        self.id = id
        self.title = title
        self.desc = desc
        self.touch = Date()
    }
}

extension Memo {
    static func fetchAll(_ modelContext: ModelContext) -> [Memo] {
        let descriptor = FetchDescriptor<Memo>(sortBy: [SortDescriptor(\.touch, order: .forward)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(#function, error)
            return []
        }
    }
}
