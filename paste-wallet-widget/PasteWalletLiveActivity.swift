//
//  paste_wallet_widgetLiveActivity.swift
//  paste-wallet-widget
//
//  Created by 최명근 on 9/13/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PasteWalletWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var id: UUID
        var name: String
        var issuer: String?
        var brand: Card.Brand
        var color: String
        var number: [String]
        var year: Int
        var month: Int
        var cvc: String?
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PasteWalletLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PasteWalletWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                VStack {
                    HStack {
                        Text("\(context.state.name)")
                            .font(.system(size: 6))
                        Spacer()
                        if let issuer = context.state.issuer {
                            Text("\(issuer)")
                                .font(.system(size: 6))
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(context.state.number, id: \.self) { n in
                            Text("\(n)")
                                .font(.system(size: 4))
                        }
                        Spacer()
                        Text("brand_\(context.state.brand.rawValue)".localized)
                            .font(.system(size: 4))
                    }
                }
                .padding(6)
                .aspectRatio(1.58, contentMode: .fit)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hexCode: context.state.color))
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                }
                
                Spacer()
            }
            .padding(6)
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(String("Leading"))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(String("Trailing"))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(String("Bottom"))
                    // more content
                }
            } compactLeading: {
                Image("paste_wallet_di")
            } compactTrailing: {
                Text("\(context.state.number.last ?? "")")
            } minimal: {
                Image("paste_wallet_di")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PasteWalletWidgetAttributes {
    fileprivate static var preview: PasteWalletWidgetAttributes {
        PasteWalletWidgetAttributes(name: "World")
    }
}

extension PasteWalletWidgetAttributes.ContentState {
    fileprivate static var card: PasteWalletWidgetAttributes.ContentState {
        PasteWalletWidgetAttributes.ContentState(id: UUID(), name: "Zero Edition 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["1234", "5678", "9012", "3456"], year: 25, month: 02, cvc: "555")
     }
}

#Preview("Notification", as: .content, using: PasteWalletWidgetAttributes.preview) {
   PasteWalletLiveActivity()
} contentStates: {
    PasteWalletWidgetAttributes.ContentState.card
}
