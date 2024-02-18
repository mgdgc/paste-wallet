//
//  PasteWalletWidget.swift
//  paste-wallet-widgetExtension
//
//  Created by 최명근 on 2/12/24.
//

import WidgetKit
import SwiftUI

enum WidgetKind: String {
    case shortcut
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let configuration: PasteWalletWidgetConfigurationIntent
}

struct Provider: IntentTimelineProvider {
    
    typealias Entry = WidgetEntry
    typealias Intent = PasteWalletWidgetConfigurationIntent
    
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), configuration: PasteWalletWidgetConfigurationIntent())
    }
    
    func getSnapshot(for configuration: PasteWalletWidgetConfigurationIntent, in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(WidgetEntry(date: Date(), configuration: configuration))
    }
    
    func getTimeline(for configuration: PasteWalletWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        var entries: [WidgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = WidgetEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct PasteWalletWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry
    private let properColumn = [
        WidgetFamily.systemSmall : 1, .systemMedium : 2, .systemLarge : 2, .systemExtraLarge : 4
    ]
    private let properAmount = [
        WidgetFamily.systemSmall : 1, .systemMedium : 2, .systemLarge : 6, .systemExtraLarge : 12
    ]
    
    var body: some View {
        if let cards = entry.configuration.cards, !cards.isEmpty {
                cardsView(cards: cards)
        } else if let banks = entry.configuration.banks, !banks.isEmpty {
            banksView(banks: banks)
        } else {
            emptyView
        }
    }
    
    var emptyView: some View {
        VStack(spacing: 18) {
            LazyVGrid(columns: Array(repeating: GridItem(), count: properColumn[widgetFamily] ?? 1), spacing: 16) {
                ForEach(0..<(properAmount[widgetFamily] ?? 1), id: \.self) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .aspectRatio(1.58, contentMode: .fit)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        .overlay {
                            HStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.black.opacity(0.1))
                                    .frame(width: 16, height: 12)
                                Spacer()
                            }
                            .padding(12)
                        }
                        .frame(maxWidth: 128)
                }
            }
                
            Text("widget_empty")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
        }
    }
    
    @ViewBuilder
    func cardsView(cards: [CardObject]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: properColumn[widgetFamily] ?? 1)) {
            ForEach(cards, id: \.identifier) { card in
                Link(destination: URL(string: "widget://key?type=card&id=\(card.identifier ?? "")")!) {
                    cardCell(card: card)
                }
            }
        }
    }
    
    @ViewBuilder
    func banksView(banks: [BankObject]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: properColumn[widgetFamily] ?? 1)) {
            ForEach(banks, id: \.identifier) { bank in
                Link(destination: URL(string: "widget://key?type=bank&id=\(bank.identifier ?? "")")!) {
                    bankCell(bank: bank)
                }
            }
        }
    }
    
    @ViewBuilder
    func cardCell(card: CardObject) -> some View {
        VStack(spacing: 16) {
            VStack {
                HStack {
                    Text(card.name ?? "")
                        .lineLimit(1)
                        .font(.caption)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(card.issuer ?? "")
                        .font(.caption2)
                }
            }
            .aspectRatio(1.58, contentMode: .fill)
            .foregroundStyle(UIColor(hexCode: card.color ?? "#ffffff").isDark ? Color.white : Color.black)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hexCode: card.color ?? "#ffffff"))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    .overlay {
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.black.opacity(0.1))
                                .frame(width: 16, height: 12)
                            Spacer()
                        }
                        .padding(12)
                    }
            )
            .aspectRatio(1.58, contentMode: .fit)
            .frame(maxWidth: 128)
            
            Text(card.name ?? "")
                .lineLimit(1)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
    }
    
    @ViewBuilder
    func bankCell(bank: BankObject) -> some View {
        VStack(spacing: 16) {
            VStack {
                HStack {
                    Text(bank.name ?? "")
                        .lineLimit(1)
                        .font(.caption)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(bank.issuer ?? "")
                        .font(.caption2)
                }
            }
            .aspectRatio(1.58, contentMode: .fill)
            .foregroundStyle(UIColor(hexCode: bank.color ?? "#ffffff").isDark ? Color.white : Color.black)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hexCode: bank.color ?? "#ffffff"))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            )
            .aspectRatio(1.58, contentMode: .fit)
            .frame(maxWidth: 128)
            
            Text(bank.name ?? "")
                .lineLimit(1)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
    }
}

struct PasteWalletWidget: Widget {
    let kind: String = WidgetKind.shortcut.rawValue
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: PasteWalletWidgetConfigurationIntent.self, provider: Provider()) { entry in
            PasteWalletWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension CardObject {
    fileprivate func setName(_ name: String) -> CardObject {
        self.name = name
        return self
    }
    
    fileprivate func setIssuer(_ issuer: String) -> CardObject {
        self.issuer = issuer
        return self
    }
    
    fileprivate func setColor(_ color: String) -> CardObject {
        self.color = color
        return self
    }
}

extension PasteWalletWidgetConfigurationIntent {
    fileprivate static var cards: PasteWalletWidgetConfigurationIntent {
        let intent = PasteWalletWidgetConfigurationIntent()
        
        let card = CardObject(identifier: UUID().uuidString, display: "M Boost 3")
        card.name = "M Boost 3"
        card.issuer = "현대카드"
        card.color = "#ffffff"
        
//        intent.cards = [
//            CardObject(identifier: UUID().uuidString, display: "M Boost 3")
//                .setName("M Boost 3")
//                .setIssuer("현대카드")
//                .setColor("#ffffff"),
//        ]
        
        return intent
    }
}

#Preview(as: .systemSmall) {
    PasteWalletWidget()
} timeline: {
    WidgetEntry(date: .now, configuration: .cards)
}

#Preview(as: .systemMedium) {
    PasteWalletWidget()
} timeline: {
    WidgetEntry(date: .now, configuration: .cards)
}

#Preview(as: .systemLarge) {
    PasteWalletWidget()
} timeline: {
    WidgetEntry(date: .now, configuration: .cards)
}

#Preview(as: .systemExtraLarge) {
    PasteWalletWidget()
} timeline: {
    WidgetEntry(date: .now, configuration: .cards)
}
