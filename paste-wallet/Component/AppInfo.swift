//
//  AppGroup.swift
//  paste-wallet
//
//  Created by 최명근 on 9/10/23.
//

import Foundation

class AppInfo {
    static let serviceName = "paste-wallet"
    static let appGroup = "group.com.mgchoi.paste-wallet"
    static let keychainSharing = "\(AppInfo.appIdentifierPrefix)com.mgchoi.paste-wallet"
    static let appIdentifierPrefix = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String
}
