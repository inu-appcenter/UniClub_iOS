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
            MyAuthStore.shared.setAccessToken(res.accessToken)
            errorMessage = nil
        } catch let apiError as APIError {
            errorMessage = loginErrorMessage(from: apiError)
        } catch {
            errorMessage = "알 수 없는 오류가 발생했습니다."
        }
    }

    private func loginErrorMessage(from error: APIError) -> String {
        switch error {
        case .badResponse(_, let body):
            if let data = body.data(using: .utf8),
               let parsed = try? JSONDecoder().decode(ServerErrorBody.self, from: data),
               !parsed.message.isEmpty {
                return parsed.message
            }
            return "로그인에 실패했습니다."
        case .transport:
            return "네트워크 연결을 확인해주세요."
        case .decoding:
            return "서버 응답을 처리할 수 없습니다."
        case .badURL, .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

private struct ServerErrorBody: Decodable {
    let message: String
}
