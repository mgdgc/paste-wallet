//
//  AppIntent.swift
//  paste-wallet-widget
//
//  Created by 최명근 on 9/13/23.
//

import WidgetKit
import AppIntents

struct SimpleAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
