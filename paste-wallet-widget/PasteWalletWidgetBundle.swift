//
//  paste_wallet_widgetBundle.swift
//  paste-wallet-widget
//
//  Created by 최명근 on 9/13/23.
//

import WidgetKit
import SwiftUI

@main
struct PasteWalletWidgetBundle: WidgetBundle {
    var body: some Widget {
        PasteWalletWidget()
        CardLiveActivity()
    }
}
