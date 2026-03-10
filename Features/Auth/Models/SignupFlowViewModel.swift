//
//  SignupViewModel.swift
//  UniClub
//
//  Created by 제욱 on 2/7/26.
//

import Foundation
import Combine

@MainActor
final class SignupFlowViewModel: ObservableObject {

    // Step1
    @Published var studentId: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    
    // UI 표시용 (예: "컴퓨터공학과")
    @Published var majorDisplay: String = ""

    // 서버 전송용 (예: "COMPUTER_ENGINEERING")
    @Published var majorCode: String = ""
    
    @Published var isPortalVerified: Bool = false

    // Step2
    @Published var nickname: String = ""

    // Step3
    @Published var agreePrivacy: Bool = false
    @Published var agreeMarketing: Bool = false

    // ✅ Step1 재학생 확인 결과를 끝까지 들고갈 값
    @Published var studentVerification: Bool = false

    // 공용 UI 상태
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Actions

    func verifyStudent() async -> Bool {
        errorMessage = nil

        let sid = studentId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sid.isEmpty, !password.isEmpty else {
            errorMessage = "학번과 비밀번호를 입력해주세요."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let res = try await SignupService.verifyStudent(studentId: sid, password: password)

            isPortalVerified = res.verified ?? false
            studentVerification = isPortalVerified   // ✅ 여기서 저장

            return isPortalVerified
        } catch {
            isPortalVerified = false
            studentVerification = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // ✅ 이제 클래스 메서드로 분리됨 (밖에서 vm.register() 가능)
    func register() async -> Bool {
        errorMessage = nil

        guard isPortalVerified else {
            errorMessage = "재학생 확인을 먼저 진행해주세요."
            return false
        }

        let sid = studentId.trimmingCharacters(in: .whitespacesAndNewlines)
        let nm = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let nn = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !sid.isEmpty, !password.isEmpty else {
            errorMessage = "학번/비밀번호가 비어있습니다."
            return false
        }
        guard !nm.isEmpty else {
            errorMessage = "이름을 입력해주세요."
            return false
        }
        guard !majorCode.isEmpty else {
            errorMessage = "학과를 선택해주세요."
            return false
        }
        guard !nn.isEmpty else {
            errorMessage = "닉네임을 입력해주세요."
            return false
        }
        guard agreePrivacy else {
            errorMessage = "개인정보 처리방침(필수)에 동의해주세요."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let req = SignupService.RegisterRequest(
                studentId: sid,
                password: password,
                name: nm,
                major: majorCode,          // ✅ 여기만 바꾸면 끝
                nickname: nn,
                agreePrivacy: agreePrivacy,
                agreeMarketing: agreeMarketing,
                studentVerification: studentVerification
            )

            let res = try await SignupService.register(req)

            // 서버가 토큰을 주면 즉시 로그인 처리 → UniClubApp 분기로 메인 진입
            if let token = res.accessToken, !token.isEmpty {
                MyAuthStore.shared.setAccessToken(token)
            }

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
