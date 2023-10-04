//
//  UserDefaultsKey.swift
//  paste-wallet
//
//  Created by 최명근 on 9/12/23.
//

import Foundation

class UserDefaultsKey {
    class AppEnvironment { }
    class Settings { }
}

extension UserDefaultsKey.AppEnvironment {
    static let alreadyInstalled = "alreadyInstalled"
}

extension UserDefaultsKey.Settings {
    static let useBiometric = "useBiometric"
    static let firstTab = "firstTab"
    static let tabHaptic = "tabHaptic"
    static let itemHaptic = "itemHaptic"
}
