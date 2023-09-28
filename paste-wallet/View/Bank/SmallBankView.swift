//
//  SmallBankView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/28/23.
//

import SwiftUI

struct SmallBankView: View {
    let bank: Bank
    let key: String
    
    var body: some View {
        VStack {
            HStack {
                Text(bank.bank)
                    .font(.subheadline)
                Spacer()
            }
            Spacer()
            HStack {
                Text(bank.name)
                    .font(.headline.bold())
                Spacer()
            }
        }
        .padding()
        .aspectRatio(1.58, contentMode: .fill)
        .foregroundStyle(UIColor(hexCode: bank.color).isDark ? Color.white : Color.black)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(hexCode: bank.color)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }
}
