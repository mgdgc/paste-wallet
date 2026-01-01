//
//  Memo.swift
//  paste-wallet
//
//  Created by 최명근 on 9/4/23.
//

import Foundation
import SwiftData

@Model
final class Memo: Identifiable, @unchecked Sendable {
    var id: UUID = UUID()
    var title: String = ""
    var desc: String = ""
    var touch: Date = Date()
    
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
    
    static func changePasscode(modelContext: ModelContext, oldKey: String, newKey: String) {
        let allMemos = Memo.fetchAll(modelContext)
        for memo in allMemos {
            if let fields = memo.fields {
                for field in fields {
                    field.value = MemoField.encrypt(field.decrypt(oldKey), newKey)
                }
            }
        }
        do {
            try modelContext.save()
        } catch {
            print(#function, error)
        }
    }
}
