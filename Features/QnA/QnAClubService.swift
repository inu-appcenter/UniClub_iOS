//
//  QnARoute.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import Foundation

enum QnAClubService {
    static func searchClubs(keyword: String) async throws -> [QnAClubSummary] {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        let query = trimmedKeyword.isEmpty ? nil : [URLQueryItem(name: "keyword", value: trimmedKeyword)]

        return try await HTTPClient.shared.getFlexibleArray(
            "/api/v1/qna/search-clubs",
            query: query,
            as: QnAClubSummary.self
        )
    }
}
