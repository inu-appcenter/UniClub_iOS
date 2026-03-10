//
//  LoginViewModel.swift
//  UniClub
//
//  Created by 제욱 on 2/7/26.
//
import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    func login(studentId: String, password: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let res = try await LoginService.login(studentId: studentId, password: password)

            // ✅ 토큰 저장 (현재 프로젝트의 단일 진실)
            MyAuthStore.shared.setAccessToken(res.accessToken)

            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
