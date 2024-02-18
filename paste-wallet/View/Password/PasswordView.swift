//
//  PasswordView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/10/23.
//

import SwiftUI
import ComposableArchitecture
import LocalAuthentication
import SwiftKeychainWrapper

struct PasswordView: View {
    let store: StoreOf<PasswordFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let localKey = viewStore.localKey {
                if ICloudHelper.shared.iCloudKeyExist {
                    if ICloudHelper.shared.getICloudKey(predictKey: localKey) == localKey {
                        // 비밀번호 확인 모드
                        PinCodeView(initialMessage: "password_type".localized, dismissable: false, enableBiometric: true, authenticateOnLaunch: true) { typed in
                            if typed == localKey {
                                viewStore.send(.setKey(localKey))
                                return .dismiss
                            } else {
                                return .retype("password_wrong".localized)
                            }
                        }
                    } else {
                        // 다른 기기에서 비밀번호 변경함
                        PinCodeView(initialMessage: "password_icloud_wrong".localized, dismissable: false, enableBiometric: false, authenticateOnLaunch: false) { typed in
                            if ICloudHelper.shared.getICloudKey(predictKey: typed) == typed {
                                KeychainWrapper.standard[.password] = typed
                                viewStore.send(.setKey(typed))
                                return .dismiss
                            } else {
                                return .retype("password_wrong".localized)
                            }
                        }
                    }
                }
                
            } else {
                if ICloudHelper.shared.iCloudKeyExist {
                    // 다른 기기에서 사용중일 때
                    PinCodeView(initialMessage: "password_icloud".localized, dismissable: false, enableBiometric: false, authenticateOnLaunch: false) { typed in
                        if ICloudHelper.shared.getICloudKey(predictKey: typed) == typed {
                            KeychainWrapper.standard[.password] = typed
                            viewStore.send(.setKey(typed))
                            return .dismiss
                        } else {
                            return .retype("password_wrong".localized)
                        }
                    }
                    
                } else {
                    // 비밀번호 설정 모드
                    PinCodeView(initialMessage: "password_init".localized, dismissable: false, enableBiometric: false, authenticateOnLaunch: false) { typed in
                        if let temp = viewStore.tempPassword {
                            if temp == typed {
                                KeychainWrapper.standard[.password] = typed
                                ICloudHelper.shared.initICloudKey(keyToSet: typed)
                                viewStore.send(.setKey(typed))
                                return .dismiss
                            } else {
                                viewStore.send(.setTempPassword(nil))
                                return .retype("password_check_fail".localized)
                            }
                            
                        } else {
                            viewStore.send(.setTempPassword(typed))
                            return .retype("password_check".localized)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PasswordView(store: Store(initialState: PasswordFeature.State(), reducer: {
        PasswordFeature()
    }))
}
