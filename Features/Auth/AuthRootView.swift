//
//  AuthRootView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//
// UniClub/Features/Auth/AuthRootView.swift

import SwiftUI

struct AuthRootView: View {
    private enum Route { case login, signupStep1, signupNickname, signupTerms }
    @State private var route: Route = .login

    // ✅ 추가: 회원가입 플로우 VM을 루트에서 “한 번” 생성
    @StateObject private var signupVM = SignupFlowViewModel()

    var body: some View {
        switch route {
        case .login:
            LoginRootView(onNavigateSignup: { route = .signupStep1 })

        case .signupStep1:
            SignupStep1View(
                onBack: { route = .login },
                onVerified: { route = .signupNickname }
            )
            .environmentObject(signupVM)   // ✅ 주입

        case .signupNickname:
            SignupStep2NicknameView(
                onBack: { route = .signupStep1 },
                onComplete: { route = .signupTerms }            )
            .environmentObject(signupVM)      // ✅ 주입 (2단계도 vm 쓰면 필요)

        case .signupTerms:
            SignupStep3TermsView(
                onBack: { route = .signupNickname },
                onNext: { route = .login }
            )
            .environmentObject(signupVM)      // ✅ 주입
        }
    }
}

#Preview("AuthRootView") {
    AuthRootView()
}
