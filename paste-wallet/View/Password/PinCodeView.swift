//
//  NewPasswordView.swift
//  paste-wallet
//
//  Created by 최명근 on 10/16/23.
//

import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

struct PinCodeView: View {
    
    enum AfterAction {
        case none
        case dismiss
        case retype(_ message: String)
    }
    
    private var dismissable: Bool
    private var biometric: Bool
    private var authenticateOnLaunch: Bool
    private var onPasswordEntered: @MainActor (String) -> AfterAction
    
    @State private var showHelpMessage: Bool = false
    @State private var typed: [Int] = []
    @State private var temp: [Int] = []
    
    @State private var message: String
    
    @Environment(\.dismiss) var dismiss
    
    private let columns: [GridItem] = [GridItem(alignment: .center), GridItem(alignment: .center), GridItem(alignment: .center)]
    private let numberPad: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "biometric", "0", "del"]
    private let laContext: LAContext = LAContext()
    
    let password: String? = {
        let freshInstall = !UserDefaults.standard.bool(forKey: UserDefaultsKey.AppEnvironment.alreadyInstalled)
        if freshInstall {
            KeychainWrapper.standard.removeAllKeys()
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.AppEnvironment.alreadyInstalled)
        }
        return KeychainWrapper.standard[.password]
    }()
    
    init(initialMessage: String = "password_type".localized, dismissable: Bool = false, enableBiometric: Bool = true, authenticateOnLaunch: Bool = true, onPasswordEntered: @escaping (String) -> AfterAction) {
        self._message = State(initialValue: initialMessage)
        self.dismissable = dismissable
        self.biometric = enableBiometric
        self.authenticateOnLaunch = authenticateOnLaunch
        self.onPasswordEntered = onPasswordEntered
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("password_help", systemImage: "questionmark.circle") {
                    showHelpMessage = true
                }
                .labelStyle(.iconOnly)
            }
            .padding()
            .alert("password_help", isPresented: $showHelpMessage) {
                Button("password_help_remove", role: .destructive) {
                    do {
                        try PasteWalletApp.sharedModelContext.delete(model: Card.self)
                        try PasteWalletApp.sharedModelContext.delete(model: Bank.self)
                        try PasteWalletApp.sharedModelContext.delete(model: Memo.self)
                        try PasteWalletApp.sharedModelContext.delete(model: MemoField.self)
                        ICloudHelper.shared.deleteICloudKey()
                        KeychainWrapper.standard.removeAllKeys()
                        
                        exit(0)
                    } catch {
                        print(error)
                    }
                }
                
                Button("cancel", role: .cancel) {
                    showHelpMessage = false
                }
                
            } message: {
                Text("password_help_message")
            }

            
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
                            
                        } else if pad == "biometric" && laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && biometric && UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric) {
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
            .frame(maxWidth: 360)
        }
        .background(Colors.backgroundSecondary.color.ignoresSafeArea())
        .onAppear {
            if biometric && authenticateOnLaunch && UserDefaults.standard.bool(forKey: UserDefaultsKey.Settings.useBiometric) {
                checkBiometric()
            }
        }
    }
    
    @ViewBuilder
    private func numberPadButton(number: Int) -> some View {
        Button {
            typed.append(number)
            
            Task { @MainActor in
                checkValidation()
            }
            
        } label: {
            Text("\(number)")
                .font(.title)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 1))
                        .fill(Colors.backgroundTertiary.color)
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
                .resizable()
                .padding(16)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 1))
                        .fill(Colors.backgroundTertiary.color)
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
                .frame(width: 24, height: 24)
        }
        .foregroundStyle(typed.isEmpty ? Colors.textTertiary.color : Colors.textPrimary.color)
        .disabled(typed.isEmpty)
    }
    
    @ViewBuilder
    var emptyButton: some View {
        Text(" ")
    }
    
    @MainActor 
    private func checkValidation() {
        if typed.count < 6 {
            return
        }
        
        valid(password: convert(array: typed))
    }
    
    @MainActor
    private func valid(password: String) {
        switch onPasswordEntered(password) {
        case .none:
            break
        case .dismiss:
            dismiss()
            break
        case .retype(let message):
            self.message = message
            typed = []
            break
        }
    }
    
    private func convert(array: [Int]) -> String {
        var string = ""
        for i in array {
            string.append(String(i))
        }
        return string
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
                    if let password = password {
                        valid(password: password)
                    }
                    
                } else {
                    // 인증 실패
                    self.message = "password_biometric_fail".localized
                }
            }
        }
    }
}

#Preview {
    PinCodeView(initialMessage: "password_type".localized, dismissable: false, enableBiometric: true, authenticateOnLaunch: true) { typed in
        return .dismiss
    }
}
