//
//  UserService.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import Foundation

// MARK: - DTO

struct UserMeResponse: Codable {
    let nickname: String
    let name: String
    let studentId: String
    let major: String
    let profileImageLink: String?
}

struct UpdateUserMeRequest: Encodable {
    let name: String?
    let major: String?
    let nickname: String?
    let profileImageLink: String?

    // nil은 아예 안 보내도록 (서버 스키마가 optional일 가능성 높음)
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        if let name { try c.encode(name, forKey: .name) }
        if let major { try c.encode(major, forKey: .major) }
        if let nickname { try c.encode(nickname, forKey: .nickname) }
        if let profileImageLink { try c.encode(profileImageLink, forKey: .profileImageLink) }
    }

    enum CodingKeys: String, CodingKey {
        case name, major, nickname, profileImageLink
    }
}

struct DeleteAccountRequest: Encodable {
    let password: String
}

// MARK: - Service

enum UserService {
    static func me() async throws -> UserMeResponse {
        try await HTTPClient.shared.get(AppConfig.API.User.me, as: UserMeResponse.self)
    }

    static func updateMe(_ req: UpdateUserMeRequest) async throws {
        _ = try await HTTPClient.shared.patchJSONRaw(AppConfig.API.User.edit, body: req)
        // 204 expected (body 없음)
    }

    static func deleteAccount(password: String) async throws {
        let req = DeleteAccountRequest(password: password)
        _ = try await HTTPClient.shared.deleteJSONRaw(AppConfig.API.User.delete, body: req)
        // 204 expected
    }
}
