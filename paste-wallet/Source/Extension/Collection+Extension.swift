//
//  Collection+Extension.swift
//  paste-wallet
//
//  Created by 최명근 on 8/16/24.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
