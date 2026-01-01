//
//  PersistenceProvider.swift
//  paste-wallet
//
//  Created by 최명근 on 10/8/25.
//

import Foundation
@preconcurrency import SwiftData
import ComposableArchitecture

@MainActor
final class PersistenceProvider {
#if targetEnvironment(simulator)
  static let shared = PersistenceProvider(isStoredInMemoryOnly: true, autosaveEnabled: true)
#else
  static let shared = PersistenceProvider(isStoredInMemoryOnly: false, autosaveEnabled: true)
#endif
  
  var isStoredInMemoryOnly: Bool
  var autosaveEnabled: Bool
  
  private init(isStoredInMemoryOnly: Bool, autosaveEnabled: Bool) {
    self.isStoredInMemoryOnly = isStoredInMemoryOnly
    self.autosaveEnabled = autosaveEnabled
  }
  
  lazy var container: ModelContainer = {
    let schema = Schema([
      Card.self,
      Bank.self,
      Memo.self,
      MemoField.self
    ])
    let configuration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false,
      groupContainer: .automatic,
      cloudKitDatabase: .private("Wallet")
    )
    
    do {
      let container = try ModelContainer(
        for: schema,
        configurations: [configuration]
      )
      container.mainContext.autosaveEnabled = autosaveEnabled
      return container
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
}

@MainActor
let _appContext: ModelContext = {
  let container = PersistenceProvider.shared.container
  let context = ModelContext(container)
  return context
}()

nonisolated var appContext: ModelContext {
  get async {
    await _appContext
  }
}
