//
//  PersistenceClient.swift
//  paste-wallet
//
//  Created by 최명근 on 10/8/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import SwiftData

@DependencyClient
struct PersistenceClient: Sendable {
  var context: @Sendable () async throws -> ModelContext
}

extension PersistenceClient: DependencyKey {
  static let liveValue: PersistenceClient = PersistenceClient(
    context: { await appContext }
  )
}

extension DependencyValues {
  var persistence: PersistenceClient {
    get { self[PersistenceClient.self] }
    set { self[PersistenceClient.self] = newValue }
  }
}
