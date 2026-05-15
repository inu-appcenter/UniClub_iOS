//
//  SignupService.swift
//  UniClub
//
//  Created by 제욱 on 2/7/26.
//

import Foundation

enum SignupService {

    // MARK: - 1) 재학생 확인
    struct VerifyRequest: Encodable {
        let studentId: String
        let password: String
    }

    struct VerifyResponse: Decodable {
        let message: String?
        let verified: Bool?

        enum CodingKeys: String, CodingKey {
            case message
            case verified = "verification"
        }
    }
    static func verifyStudent(studentId: String, password: String) async throws -> VerifyResponse {
        let (data, _) = try await HTTPClient.shared.postJSONRaw(
            AppConfig.API.Auth.verifyStudent,
            body: VerifyRequest(studentId: studentId, password: password),
            requiresAuth: false
        )

        return try HTTPClient.shared.decode(VerifyResponse.self, from: data)
    }

    // MARK: - 2) 회원가입
    struct RegisterRequest: Encodable {
        let studentId: String
        let password: String
        let name: String
        let major: String
        let nickname: String

        // ✅ 서버 스키마에 맞는 값들만 유지
        let agreePrivacy: Bool          // -> personalInfoCollectionAgreement
        let agreeMarketing: Bool        // -> marketingAdvertisement

        enum CodingKeys: String, CodingKey {
            case studentId
            case password
            case name
            case major
            case nickname
            case agreePrivacy = "personalInfoCollectionAgreement"
            case agreeMarketing = "marketingAdvertisement"
        }
    }

    static func register(_ req: RegisterRequest) async throws -> RegisterResponse {
        // ⚠️ 이 API는 201 + 빈 바디(Content-Length: 0)로 내려오는 케이스가 있음.
        let (data, _) = try await HTTPClient.shared.postJSONRaw(
            AppConfig.API.Auth.register,
            body: req,
            requiresAuth: false
        )

        if data.isEmpty {
            return RegisterResponse() // accessToken nil
        }

        return try HTTPClient.shared.decode(RegisterResponse.self, from: data)
    }

    struct RegisterResponse: Decodable {
        let userId: Int?
        let accessToken: String?
        let tokenType: String?
        let message: String?

        init(
            userId: Int? = nil,
            accessToken: String? = nil,
            tokenType: String? = nil,
            message: String? = nil
        ) {
            self.userId = userId
            self.accessToken = accessToken
            self.tokenType = tokenType
            self.message = message
        }
    }
}
