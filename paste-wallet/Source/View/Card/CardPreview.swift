//
//  CardPreview.swift
//  paste-wallet
//
//  Created by 최명근 on 9/12/23.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct CardPreview: View {
    let card: Card
    let key: String
    let size: CGSize
    
    var body: some View {
        VStack {
            HStack {
                Text(card.name)
                    .font(.title2)
                Spacer()
                Text(card.issuer ?? "")
                    .font(.title3)
            }
            
            Spacer()
            
            HStack {
                if let number = card.decryptNumber(key: key).last {
                    Text(number)
                        .font(.title2)
                        .underline()
                }
                Spacer()
                Text("brand_\(card.brand)".localized)
                    .font(.body.bold())
            }
        }
        .padding(20)
        .foregroundStyle(UIColor(hexCode: card.color).isDark ? Color.white : Color.black)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: card.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
        .frame(idealWidth: size.width, idealHeight: size.width * 100 / 158)
    }
}
