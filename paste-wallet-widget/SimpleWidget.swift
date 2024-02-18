//
//  paste_wallet_widget.swift
//  paste-wallet-widget
//
//  Created by 최명근 on 9/13/23.
//

import WidgetKit
import SwiftUI

struct SimpleProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: SimpleAppIntent())
    }

    func snapshot(for configuration: SimpleAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: SimpleAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: SimpleAppIntent
}

struct SimpleWidgetEntryView : View {
    var entry: SimpleProvider.Entry

    var body: some View {
        VStack {
            Text(String("Time:"))
            Text(entry.date, style: .time)

            Text(String("Favorite Emoji:"))
            Text(entry.configuration.favoriteEmoji)
        }
    }
}

struct SimpleWidget: Widget {
    let kind: String = "paste_wallet_widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SimpleAppIntent.self, provider: SimpleProvider()) { entry in
            SimpleWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension SimpleAppIntent {
    fileprivate static var smiley: SimpleAppIntent {
        let intent = SimpleAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: SimpleAppIntent {
        let intent = SimpleAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    SimpleWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
