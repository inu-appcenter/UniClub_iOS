//
//  DeleteAccountViewModel.swift
//  UniClub
//
//  Created by 제욱 on 2/11/26.
//

import Foundation
import Combine

@MainActor
final class DeleteAccountViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func deleteAccount(password: String) async -> Bool {
        let pw = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if pw.isEmpty {
            errorMessage = "비밀번호를 입력해주세요."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            try await UserService.deleteAccount(password: pw)

            // ✅ 성공: 토큰 삭제 + 루트 전환 트리거
            MyAuthStore.shared.signOut() // 너 MyPageViewModel에서 쓰던 signOut이랑 동일한 방식으로 맞춰
            isLoading = false
            return true

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isLoading = false
            return false
        }
    }
}
