//
//  MainClubsService.swift
//  UniClub
//
//  Created by 제욱 on 2/8/26.
//

import Foundation

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

    func toggledFavorite() -> MainClubItem {
        MainClubItem(
            clubId: clubId,
            name: name,
            imageUrl: imageUrl,
            favorite: !favorite
        )
    }
}

struct ToggleFavoriteResponse: Decodable {
    let message: String
}

enum MainClubsService {
    /// GET /api/v1/main/clubs
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

    /// POST /api/v1/clubs/{clubId}/favorite
    ///
    /// 주의:
    /// - 현재 제공된 Swagger 조각에는 HTTP Method가 보이지 않아 POST로 가정함
    /// - 실제 Swagger가 PUT/PATCH라면 req.httpMethod만 변경하면 됨
    static func toggleFavorite(clubId: Int) async throws -> ToggleFavoriteResponse {
        let path = "/api/v1/clubs/\(clubId)/favorite"
        let url = AppConfig.baseURL.appendingPathComponent(
            path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        )

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
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
        return try dec.decode(ToggleFavoriteResponse.self, from: data)
    }
}
