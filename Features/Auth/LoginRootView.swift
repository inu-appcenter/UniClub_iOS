//
//  LoginRootView.swift
//  UniClub

import SwiftUI

struct LoginRootView: View {
    let onNavigateSignup: () -> Void
    @StateObject private var vm = LoginViewModel()

    var body: some View {
        LoginView(
            onLogin: { studentId, password in
                Task { await vm.login(studentId: studentId, password: password) }
            },
            onTapSignup: onNavigateSignup,
            apiError: $vm.errorMessage
        )
    }
}
