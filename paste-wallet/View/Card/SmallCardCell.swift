//
//  SmallCardCell.swift
//  paste-wallet
//
//  Created by 최명근 on 9/12/23.
//

import Foundation
import SwiftUI

struct SmallCardCell: View {
    let card: Card
    let key: String
    
    var body: some View {
        VStack {
            HStack {
                Text(card.name)
                Spacer()
            }
            Spacer()
            HStack {
                if let number = card.decryptNumber(key: key).last {
                    Text(number)
                        .font(.title2)
                        .underline()
                }
                Spacer()
                Text(card.issuer ?? "")
                    .font(.caption2)
            }
        }
        .padding()
        .aspectRatio(1.58, contentMode: .fill)
        .foregroundStyle(UIColor(hexCode: card.color).isDark ? Color.white : Color.black)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: card.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }
}
