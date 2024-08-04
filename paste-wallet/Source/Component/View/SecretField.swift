//
//  SecretField.swift
//  paste-wallet
//
//  Created by 최명근 on 8/4/24.
//

import Foundation
import SwiftUI

struct SecretField: View {
    var title: LocalizedStringKey
    var content: String
    
    @Binding var locked: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Colors.textPrimary.color)
            Spacer()
            if locked {
                Text(String(content))
                    .textSelection(.enabled)
                    .foregroundStyle(Colors.textSecondary.color)
                    .overlay {
                        if locked {
                            Rectangle()
                                .fill(.thinMaterial)
                        }
                    }
            } else {
                Text(String(content))
                    .textSelection(.enabled)
                    .foregroundStyle(Colors.textSecondary.color)
                    .textSelection(.enabled)
            }
        }
    }
}
