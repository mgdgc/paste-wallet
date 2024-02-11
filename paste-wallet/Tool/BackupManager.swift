//
//  BackupManager.swift
//  paste-wallet
//
//  Created by 최명근 on 12/8/23.
//

import Foundation
import SwiftData
import CloudKit

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
        guard let localDocumentFolderUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        self.localDocumentFolderUrl = localDocumentFolderUrl
        
        self.localBackupFolderUrl = localDocumentFolderUrl.appending(path: BACKUP_DIRECTORY)
        if !FileManager.default.fileExists(atPath: self.localBackupFolderUrl.path()) {
            do {
                try FileManager.default.createDirectory(at: self.localBackupFolderUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return nil
            }
        }
        
        guard let iCloudDocumnetFolderUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appending(path: "Documents") else {
            return nil
        }
        self.iCloudDocumnetFolderUrl = iCloudDocumnetFolderUrl
        
        self.iCloudBackupFolderUrl = iCloudDocumnetFolderUrl.appending(path: BACKUP_DIRECTORY)
        if !FileManager.default.fileExists(atPath: self.iCloudBackupFolderUrl.path()) {
            do {
                try FileManager.default.createDirectory(at: self.iCloudBackupFolderUrl, withIntermediateDirectories: true, attributes: nil)
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
    
    func backup() {
        let cards = fetchCards()
        let banks = fetchBanks()
        let memos = fetchMemos()
    }
    
    private func fetchCards() -> [Card] {
        let cards = Card.fetchAll(modelContext: PasteWalletApp.sharedModelContext)
        return cards
    }
    
    private func fetchBanks() -> [Bank] {
        let banks = Bank.fetchAll(modelContext: PasteWalletApp.sharedModelContext)
        return banks
    }
    
    private func fetchMemos() -> [Memo] {
        let memos = Memo.fetchAll(PasteWalletApp.sharedModelContext)
        return memos
    }
}
