//
//  ICloudHelper.swift
//  paste-wallet
//
//  Created by 최명근 on 10/2/23.
//

import CryptoSwift
import Foundation
import SwiftData

@MainActor
final class ICloudHelper {
  private static let KEY = "KEY"
  private static let LAST_UPDATE = "last_update"

  static let shared = ICloudHelper()
  private let keyStore = NSUbiquitousKeyValueStore()

  private init() {}

  var iCloudKeyExist: Bool {
    keyStore.string(forKey: ICloudHelper.KEY) != nil
  }

  func initICloudKey(keyToSet: String) {
    if keyStore.string(forKey: ICloudHelper.KEY) == nil {
      setICloudKey(keyToSet)
    }
  }

  func getICloudKey(predictKey: String) -> String? {
    if keyStore.string(forKey: ICloudHelper.KEY) == nil {
      setICloudKey(predictKey)
    }
    if keyStore.string(forKey: ICloudHelper.KEY) == predictKey.sha256() {
      return predictKey
    } else {
      return nil
    }
  }

  func setICloudKey(_ rawKey: String) {
    let key = rawKey.sha256()
    keyStore.set(key, forKey: ICloudHelper.KEY)
    keyStore.synchronize()
  }

  func deleteICloudKey() {
    keyStore.removeObject(forKey: ICloudHelper.KEY)
  }

}
