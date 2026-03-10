//
//  LoginService.swift
//  UniClub
//
//  Created by 제욱 on 2/7/26.
//

import Foundation

enum LoginService {

    struct Request: Encodable {
        let studentId: String
        let password: String
    }

    struct Response: Decodable {
        let userId: Int?
        let accessToken: String
        let expiresIn: Int?
        let tokenType: String?

        enum CodingKeys: String, CodingKey {
            case userId
            case accessToken
            case expiresIn
            case tokenType
            case expires_in
            case token_type
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)

            userId = try c.decodeIfPresent(Int.self, forKey: .userId)
            accessToken = try c.decode(String.self, forKey: .accessToken)

            // ✅ try + ?? 충돌 회피: 한 번씩 꺼내서 합치기
            let expiresCamel = try c.decodeIfPresent(Int.self, forKey: .expiresIn)
            let expiresSnake = try c.decodeIfPresent(Int.self, forKey: .expires_in)
            expiresIn = expiresCamel ?? expiresSnake

            let tokenCamel = try c.decodeIfPresent(String.self, forKey: .tokenType)
            let tokenSnake = try c.decodeIfPresent(String.self, forKey: .token_type)
            tokenType = tokenCamel ?? tokenSnake
        }
    }

    static func login(studentId: String, password: String) async throws -> Response {
        let res: Response = try await HTTPClient.shared.postJSON(
            AppConfig.API.Auth.login,
            body: Request(studentId: studentId, password: password),
            requiresAuth: false,
            as: Response.self
        )
        return res
    }
}
