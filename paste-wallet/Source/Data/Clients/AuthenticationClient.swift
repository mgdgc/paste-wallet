//
//  AuthenticationClient.swift
//  paste-wallet
//
//  Created by 최명근 on 10/9/25.
//

import Foundation
import ComposableArchitecture
import LocalAuthentication

@DependencyClient
struct AuthenticationClient: Sendable {
  var authenticateWithBiometric: @MainActor @Sendable () async throws -> Bool
}

extension AuthenticationClient: DependencyKey {
  static let liveValue: AuthenticationClient = {
    let laContext = LAContext()
    return AuthenticationClient(
      authenticateWithBiometric: {
        var error: NSError?
        if laContext.canEvaluatePolicy(
          .deviceOwnerAuthenticationWithBiometrics,
          error: &error
        ) {
          do {
            let result = try await laContext.evaluatePolicy(
              .deviceOwnerAuthenticationWithBiometrics,
              localizedReason: "biometric_reason".localized
            )
            return result
          } catch {
            debugPrint(error)
            return false
          }
        }
        return true
      }
    )
  }()
}

extension DependencyValues {
  var authenticationClient: AuthenticationClient {
    get { self[AuthenticationClient.self] }
    set { self[AuthenticationClient.self] = newValue }
  }
}
