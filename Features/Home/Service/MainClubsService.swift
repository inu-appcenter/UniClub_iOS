//  MainClubsService.swift
//  UniClub
//
//  Created by 제욱 on 2/8/26.
//

import Foundation

// GET /api/v1/main/clubs 응답 스키마에 맞춘 모델
struct MainClubItem: Identifiable, Decodable {
    let clubId: Int
    let name: String
    let imageUrl: URL?
    let favorite: Bool

    var id: Int { clubId }

    private enum CodingKeys: String, CodingKey {
        case clubId
        case name
        case imageUrl
        case favorite
    }

    init(clubId: Int, name: String, imageUrl: URL?, favorite: Bool) {
        self.clubId = clubId
        self.name = name
        self.imageUrl = imageUrl
        self.favorite = favorite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.clubId = try container.decode(Int.self, forKey: .clubId)
        self.name = try container.decode(String.self, forKey: .name)
        self.favorite = try container.decode(Bool.self, forKey: .favorite)

        let rawImageURL = try container.decodeIfPresent(String.self, forKey: .imageUrl)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let rawImageURL, !rawImageURL.isEmpty, let url = URL(string: rawImageURL) {
            self.imageUrl = url
        } else {
            self.imageUrl = nil
        }
    }
}

enum MainClubsService {
    /// GET /api/v1/main/clubs
    /// - Note: favorite가 사용자별이라 Authorization이 필요할 가능성이 높음
    static func fetchMainClubs() async throws -> [MainClubItem] {
        let url = AppConfig.baseURL.appendingPathComponent(
            AppConfig.API.Main.clubs.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        )

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await HTTPClient.shared.sendRaw(req, requiresAuth: true)

        guard let http = resp as? HTTPURLResponse else {
            throw APIError.badResponse(-1, "Invalid HTTPURLResponse")
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.badResponse(http.statusCode, body)
        }

        let dec = JSONDecoder()
        return try dec.decode([MainClubItem].self, from: data)
    }
}
