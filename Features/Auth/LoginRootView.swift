//
//  LoginRootView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

struct LoginRootView: View {
    let onNavigateSignup: () -> Void
    @StateObject private var vm = LoginViewModel()

    @State private var showAlert: Bool = false

    var body: some View {
        LoginView(
            onLogin: { studentId, password in
                Task { await vm.login(studentId: studentId, password: password) }
            },
            onTapSignup: onNavigateSignup
        )
        // ✅ errorMessage가 생기면 alert 띄우기
        .onChange(of: vm.errorMessage) { _, newValue in
            showAlert = (newValue != nil)
            if let msg = newValue {
                print("❌ LOGIN ERROR MESSAGE:", msg)
            }
        }
        .alert("로그인 실패", isPresented: $showAlert) {
            Button("확인") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
