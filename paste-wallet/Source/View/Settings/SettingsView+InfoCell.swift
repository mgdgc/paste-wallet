//
//  SettingsView+InfoCell.swift
//  paste-wallet
//
//  Created by 최명근 on 8/17/24.
//

import Foundation
import SwiftUI

extension SettingsView {
    struct InfoCell: View {
        var title: LocalizedStringKey
        var message: String
        
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Text(message)
                    .foregroundStyle(Colors.textTertiary.color)
            }
        }
    }
}
