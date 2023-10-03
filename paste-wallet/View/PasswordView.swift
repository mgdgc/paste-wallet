//
//  PasswordView.swift
//  paste-wallet
//
//  Created by 최명근 on 9/10/23.
//

import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

struct PasswordView: View {
    
    @Binding var key: String?
    
    @State private var typed: [Int] = []
    @State private var temp: [Int] = []
    
    @State private var message: String = ""
    
    let columns: [GridItem] = [GridItem(alignment: .trailing), GridItem(alignment: .center), GridItem(alignment: .leading)]
    let numberPad: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "biometric", "0", "del"]
    let laContext: LAContext = LAContext()
    
    let password: String? = {
        let freshInstall = !UserDefaults.standard.bool(forKey: UserDefaultsKey.AppEnvironment.alreadyInstalled)
        if freshInstall {
            KeychainWrapper.standard.removeAllKeys()
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.AppEnvironment.alreadyInstalled)
        }
        return KeychainWrapper.standard[.password]
    }()
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .multilineTextAlignment(.center)
            Spacer()
            HStack {
                ForEach(0..<6) { i in
                    if i < typed.count {
                        Image(systemName: "circle.fill")
                    } else {
                        Image(systemName: "circle")
                    }
                }
            }
            Spacer()
            
            LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                ForEach(numberPad, id: \.self) { pad in
                    ZStack {
                        if let n = Int(pad) {
                            numberPadButton(number: n)
                            
                        } else if pad == "biometric" && laContext.biometryType != .none && password != nil {
                            biometricButton
                            
                        } else if pad == "del" {
                            deleteButton
                            
                        } else {
                            emptyButton
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(Colors.backgroundSecondary.color.ignoresSafeArea())
        .onAppear {
            if password == nil {
                message = "password_init".localized
            } else {
                message = "password_type".localized
                
                checkBiometric()
            }
        }
    }
    
    @ViewBuilder
    private func numberPadButton(number: Int) -> some View {
        Button {
            typed.append(number)
            
            checkValidation()
            
        } label: {
            Text("\(number)")
                .font(.title)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 1))
                }
        }
        .foregroundStyle(Colors.textPrimary.color)
    }
    
    @ViewBuilder
    var biometricButton: some View {
        let icon: [LABiometryType : String] = [.faceID: "faceid", .touchID: "touchid", .opticID: "opticid"]
        
        Button {
            checkBiometric()
            
        } label: {
            Image(systemName: icon[laContext.biometryType]!)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 1))
                }
        }
        .foregroundStyle(Colors.textPrimary.color)
    }
    
    @ViewBuilder
    var deleteButton: some View {
        Button {
            if !typed.isEmpty {
                typed.removeLast()
            }
            
        } label: {
            Image(systemName: "delete.left")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
                .frame(width: 64, height: 64)
        }
        .foregroundStyle(typed.isEmpty ? Colors.textTertiary.color : Colors.textPrimary.color)
        .disabled(typed.isEmpty)
    }
    
    @ViewBuilder
    var emptyButton: some View {
        Text(" ")
    }
    
    private func checkValidation() {
        if typed.count < 6 {
            return
        }
        // 입력 모드 판별 (새 비밀번호 or 비밀번호 입력)
        if let password = password {
            // 비밀번호 입력 모드
            // 비밀번호 확인
            if password == convert(array: typed) {
                // 비밀번호 일치
                valid()
            } else {
                // 비밀번호 불일치
                typed = []
                message = "password_wrong".localized
            }
        } else {
            // 새 비밀번호 모드
            if temp.isEmpty {
                // 첫 비밀번호 입력
                temp = typed
                typed = []
                
                message = "password_check".localized
                
            } else {
                // 비밀번호 확인
                if temp == typed {
                    // 비밀번호 일치
                    save()
                    valid()
                } else {
                    typed = []
                    temp = []
                    
                    message = "password_check_fail".localized
                }
            }
        }
    }
    
    private func convert(array: [Int]) -> String {
        var string = ""
        for i in array {
            string.append(String(i))
        }
        return string
    }
    
    private func valid() {
        let key = convert(array: typed)
        self.key = key
    }
    
    private func save() {
        let keychain = KeychainWrapper.standard
        keychain[.password] = convert(array: typed)
    }
    
    private func checkBiometric() {
        var error: NSError?
        // 생체인증 가능여부 확인
        if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "biometric_reason".localized
            // 생체인증 요청
            laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { authenticated, error in
                // 생체인증 결과
                if authenticated {
                    // 인증 성공
                    self.key = password
                    
                } else {
                    // 인증 실패
                    self.message = "password_biometric_fail".localized
                }
            }
        }
    }
}

#Preview {
    PasswordView(key: .constant(nil))
}
