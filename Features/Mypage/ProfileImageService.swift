//
//  ProfileImageService.swift
//  UniClub
//
//  Created by 제욱 on 2/11/26.
//

import Foundation

enum ProfileImageService {

    struct PresignedRequest: Encodable {
        let filename: String
    }

    struct PresignedResponse: Decodable {
        let filename: String          // ✅ "uploads/....png"
        let presignedUrl: String      // ✅ S3 PUT URL
    }

    static func presigned(filename: String) async throws -> PresignedResponse {
        try await HTTPClient.shared.postJSON(
            AppConfig.API.User.profilePresigned,
            body: PresignedRequest(filename: filename),
            requiresAuth: true,
            as: PresignedResponse.self
        )
    }
}
