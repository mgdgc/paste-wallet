//
//  CardDetailView+CardDetailSection.swift
//  paste-wallet
//
//  Created by 최명근 on 8/18/24.
//

import Foundation
import SwiftUI

extension CardDetailView {
    struct CardDetailSection<Content>: View where Content: View {
        var sectionTitle: LocalizedStringKey? = nil
        @ViewBuilder var content: () -> Content
        
        var body: some View {
            VStack {
                if let sectionTitle = sectionTitle {
                    HStack {
                        Text(sectionTitle)
                            .padding(.top, 8)
                            .padding(.horizontal, 4)
                        Spacer()
                    }
                }
                VStack {
                    content()
                }
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.backgroundPrimary.color)
                }
            }
        }
    }
}
