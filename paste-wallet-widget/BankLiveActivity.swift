//
//  BankLiveActivity.swift
//  paste-wallet
//
//  Created by 최명근 on 9/30/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BankWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var name: String
        var bank: String
        var color: String
        var number: String
    }

    // Fixed non-changing properties about your activity go here!
    var id: UUID
}

struct BankLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BankWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            Text(String("Hello"))
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image("paste_wallet_di")
                            .renderingMode(.template)
                            .resizable()
                            .tint(Color.white)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36)
                        Text("di_bank_leading")
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(String(context.state.name))
                        .lineLimit(1)
                        .font(.caption)
                        .padding(8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(String(Locale.current.currencySymbol ?? "$"))
                            .foregroundStyle(Color(hexCode: context.state.color).isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.3))
                            .padding()
                            .background {
                                Circle()
                                    .fill(Color(hexCode: context.state.color))
                                    .frame(maxWidth: 36, maxHeight: 36)
                            }
                            .padding(8)
                        
                        Grid {
                            GridRow {
                                Text("di_bank_bank")
                                HStack {
                                    Text(String("\(context.state.bank)"))
                                        .padding(4)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Colors.backgroundTertiary.color)
                                        }
                                    Spacer()
                                }
                            }
                            GridRow {
                                Text("di_bank_number")
                                HStack {
                                    Text(String("\(context.state.number)"))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(2)
                                        .padding(4)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Colors.backgroundTertiary.color)
                                        }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
            } compactLeading: {
                Image("paste_wallet_di")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tint(Color.white)
                
            } compactTrailing: {
                Text(String(Locale.current.currencySymbol ?? "$"))
                    .foregroundStyle(Color(hexCode: context.state.color).isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.3))
                    .padding(4)
                    .background {
                        Circle()
                            .fill(Color(hexCode: context.state.color))
                    }
                
            } minimal: {
                Image("paste_wallet_di")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tint(Color.white)
            }
            
        }
    }
}

extension BankWidgetAttributes {
    fileprivate static var preview: BankWidgetAttributes {
        BankWidgetAttributes(id: UUID())
    }
}

extension BankWidgetAttributes.ContentState {
    fileprivate static var bank: BankWidgetAttributes.ContentState {
        BankWidgetAttributes.ContentState(name: "주계좌", bank: "토스뱅크", color: "#ffefff", number: "123-4352-2345132")
    }
}

#Preview("Bank", as: .dynamicIsland(.compact), using: BankWidgetAttributes.preview) {
    BankLiveActivity()
} contentStates: {
    BankWidgetAttributes.ContentState.bank
}
