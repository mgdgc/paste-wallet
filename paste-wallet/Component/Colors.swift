//
//  Colors.swift
//  paste-wallet
//
//  Created by 최명근 on 9/7/23.
//

import Foundation
import SwiftUI

enum Colors : String {
    case backgroundPrimary = "BackgroundPrimary"
    case backgroundSecondary = "BackgroundSecondary"
    case backgroundTertiary = "BackgroundTertiary"
    case textPrimary = "TextPrimary"
    case textSecondary = "TextSecondary"
    case textTertiary = "TextTertiary"
    
    var color: Color {
        return Color(self.rawValue)
    }
}
