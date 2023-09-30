//
//  paste_wallet_widgetLiveActivity.swift
//  paste-wallet-widget
//
//  Created by 최명근 on 9/13/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CardWidgetAttributes: ActivityAttributes {
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
    var id: UUID
}

struct CardLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CardWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                mediumCard(context)
                
                Spacer()
                
                HStack {
                    ForEach(context.state.number, id: \.self) { n in
                        Text("\(n)")
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.backgroundSecondary.color)
                }
                
                Spacer()
            }
            .padding()
//            .activityBackgroundTint(Colors.backgroundSecondary.color)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image("paste_wallet_di")
                            .renderingMode(.template)
                            .resizable()
                            .tint(Color.white)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36)
                        Text("di_card_leading")
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        HStack {
                            smallCard(context)
                            
                            VStack {
                                HStack {
                                    ForEach(context.state.number.indices, id: \.self) { i in
                                        let n = context.state.number[i]
                                        Text(String("\(n)"))
                                            .padding(4)
                                            .background {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Colors.backgroundTertiary.color)
                                            }
                                        
                                        if i < context.state.number.count - 1 {
                                            Spacer()
                                        }
                                    }
                                }
                                
                                HStack {
                                    Text(String(format: "%02d / %02d", context.state.month, context.state.year))
                                        .underline()
                                    
                                    Spacer()
                                    
                                    if let cvc = context.state.cvc {
                                        Text(String("CVC"))
                                        Text(String("\(cvc)"))
                                            .padding(4)
                                            .background {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Colors.backgroundTertiary.color)
                                            }
                                    }
                                }
                            }
                            .padding(.leading)
                        }
                        
                    }
                    .padding(6)
                }
            } compactLeading: {
                Image("paste_wallet_di")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tint(Color.white)
            } compactTrailing: {
                Text("\(context.state.number.last ?? "")")
            } minimal: {
                Image("paste_wallet_di")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tint(Color.white)
            }
            .keylineTint(Color.red)
        }
    }
    
    @ViewBuilder
    private func mediumCard(_ context: ActivityViewContext<CardWidgetAttributes>) -> some View {
        VStack {
            HStack {
                Text("\(context.state.name)")
                    .font(.system(size: 8))
                Spacer()
                if let issuer = context.state.issuer {
                    Text("\(issuer)")
                        .font(.system(size: 8))
                }
            }
            
            Spacer()
            
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hexCode: context.state.color).isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                //                .stroke(Color(hexCode: context.state.color)
                    .frame(width: 16, height: 12)
                Spacer()
            }
            
            Spacer()
            
            HStack(spacing: 2) {
                ForEach(context.state.number, id: \.self) { n in
                    Text("\(n)")
                        .font(.system(size: 6))
                }
                Spacer()
                Text("brand_\(context.state.brand.rawValue)".localized)
                    .font(.system(size: 6))
            }
        }
        .padding(8)
        .aspectRatio(1.58, contentMode: .fit)
        .foregroundStyle(Color(hexCode: context.state.color).isDark ? Color.white : Color.black)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hexCode: context.state.color))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
        }
        .frame(maxHeight: 78)
    }
    
    @ViewBuilder
    private func smallCard(_ context: ActivityViewContext<CardWidgetAttributes>) -> some View {
        VStack {
            HStack {
                Text("\(context.state.name)")
                    .font(.system(size: 4))
                Spacer()
                if let issuer = context.state.issuer {
                    Text("\(issuer)")
                        .font(.system(size: 4))
                }
            }
            
            Spacer()
            
            HStack {
                RoundedRectangle(cornerRadius: 1)
//                    .fill(Color(red: 255, green: 255, blue: 20))
                    .fill(Color(hexCode: context.state.color).isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                    .stroke(Color(hexCode: context.state.color).isDark ? Color.white : Color.black, lineWidth: 0.4)
                    .frame(width: 6, height: 4)
                Spacer()
            }
            
            Spacer()
            
            HStack(spacing: 2) {
                ForEach(context.state.number, id: \.self) { n in
                    Text("\(n)")
                        .font(.system(size: 2))
                }
                Spacer()
                Text("brand_\(context.state.brand.rawValue)".localized)
                    .font(.system(size: 2))
            }
        }
        .padding(6)
        .aspectRatio(1.58, contentMode: .fit)
        .foregroundStyle(Color(hexCode: context.state.color).isDark ? Color.white : Color.black)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hexCode: context.state.color))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
        }
        .frame(maxHeight: 48)
    }
}

extension CardWidgetAttributes {
    fileprivate static var preview: CardWidgetAttributes {
        CardWidgetAttributes(id: UUID())
    }
}

extension CardWidgetAttributes.ContentState {
    fileprivate static var card: CardWidgetAttributes.ContentState {
        CardWidgetAttributes.ContentState(id: UUID(), name: "Zero Edition 1", issuer: "현대카드", brand: .visa, color: "#ffffff", number: ["1234", "5678", "9012", "3456"], year: 25, month: 02, cvc: "555")
     }
}

#Preview("Notification", as: .dynamicIsland(.compact), using: CardWidgetAttributes.preview) {
   CardLiveActivity()
} contentStates: {
    CardWidgetAttributes.ContentState.card
}
