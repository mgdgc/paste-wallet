//
//  IntentHandler.swift
//  paste-wallet-intentHandler
//
//  Created by 최명근 on 2/12/24.
//

import Intents
import SwiftData

class IntentHandler: INExtension, PasteWalletWidgetConfigurationIntentHandling {
    
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Card.self,
            Bank.self,
            Memo.self,
            MemoField.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, groupContainer: .automatic, cloudKitDatabase: .private("Wallet"))
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    static var sharedModelContext: ModelContext = ModelContext(sharedModelContainer)
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    func provideCardsOptionsCollection(for intent: PasteWalletWidgetConfigurationIntent) async throws -> INObjectCollection<CardObject> {
        var items: [CardObject] = []
        
        let cards = Card.fetchAll(modelContext: IntentHandler.sharedModelContext)
        for card in cards {
            let item = CardObject.init(identifier: card.id.uuidString, display: card.name)
            item.name = card.name
            item.issuer = card.issuer
            item.color = card.color
            
            items.append(item)
        }
        
        print("SwiftData Card: \(items.count)")
        
        return INObjectCollection(items: items)
    }
    
    func provideBanksOptionsCollection(for intent: PasteWalletWidgetConfigurationIntent) async throws -> INObjectCollection<BankObject> {
        var items: [BankObject] = []
        
        let banks = Bank.fetchAll(modelContext: IntentHandler.sharedModelContext)
        for bank in banks {
            let item = BankObject(identifier: bank.id.uuidString, display: bank.name)
            item.name = bank.name
            item.issuer = bank.bank
            item.color = bank.color
            
            items.append(item)
        }
        
        print("SwiftData Bank: \(items.count)")
        
        return INObjectCollection(items: items)
    }
    
}
