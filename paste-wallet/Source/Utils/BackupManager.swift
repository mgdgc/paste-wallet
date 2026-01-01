//
//  BackupManager.swift
//  paste-wallet
//
//  Created by 최명근 on 12/8/23.
//

import CloudKit
import Foundation
import SwiftData
import Dependencies

@MainActor
class BackupManager {
  private let localDocumentFolderUrl: URL
  private let localBackupFolderUrl: URL
  private let iCloudDocumnetFolderUrl: URL
  private let iCloudBackupFolderUrl: URL
  private let BACKUP_DIRECTORY = "backup"

  /*
   * File Tree
   * {DocumentDirectory}
   *   ⌙ backups
   *     ⌙ [backup folder]
   *       backup_{date}
   */

  init?() {
    guard
      let localDocumentFolderUrl = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
      ).first
    else {
      return nil
    }
    self.localDocumentFolderUrl = localDocumentFolderUrl

    self.localBackupFolderUrl = localDocumentFolderUrl.appending(path: BACKUP_DIRECTORY)
    if !FileManager.default.fileExists(atPath: self.localBackupFolderUrl.path()) {
      do {
        try FileManager.default.createDirectory(
          at: self.localBackupFolderUrl,
          withIntermediateDirectories: true,
          attributes: nil
        )
      } catch {
        print(error)
        return nil
      }
    }

    guard
      let iCloudDocumnetFolderUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
        .appending(path: "Documents")
    else {
      return nil
    }
    self.iCloudDocumnetFolderUrl = iCloudDocumnetFolderUrl

    self.iCloudBackupFolderUrl = iCloudDocumnetFolderUrl.appending(path: BACKUP_DIRECTORY)
    if !FileManager.default.fileExists(atPath: self.iCloudBackupFolderUrl.path()) {
      do {
        try FileManager.default.createDirectory(
          at: self.iCloudBackupFolderUrl,
          withIntermediateDirectories: true,
          attributes: nil
        )
      } catch {
        print(error)
        return nil
      }
    }
  }
}

extension BackupManager {
  enum BackupProcedure: Int {
    case fetch
    case pack
    case upload
    case register
    case clean
  }

  func backup() async throws {
    let cards = try await fetchCards()
    let banks = try await fetchBanks()
    let memos = try await fetchMemos()
  }

  private func fetchCards() async throws -> [Card] {
    @Dependency(\.persistence) var persistence
    let context = try await persistence.context()
    let cards = Card.fetchAll(modelContext: context)
    return cards
  }

  private func fetchBanks() async throws -> [Bank] {
    @Dependency(\.persistence) var persistence
    let context = try await persistence.context()
    let banks = Bank.fetchAll(modelContext: context)
    return banks
  }

  private func fetchMemos() async throws -> [Memo] {
    @Dependency(\.persistence) var persistence
    let context = try await persistence.context()
    let memos = Memo.fetchAll(context)
    return memos
  }
}
