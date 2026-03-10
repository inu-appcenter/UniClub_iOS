import Foundation

// ✅ 실제 응답 스키마에 맞춘 모델
struct HomeBannerItem: Identifiable, Decodable {
    let mediaLink: URL
    let mediaType: String

    // ✅ mediaLink는 유니크하므로 ID로 사용 (중복 경고 해결)
    var id: String { mediaLink.absoluteString }

    enum CodingKeys: String, CodingKey {
        case mediaLink
        case mediaType
    }
}

enum HomeBannerService {
    /// GET /api/v1/main/banner (✅ 인증 필요)
    static func fetchBanners() async throws -> [HomeBannerItem] {
        let url = AppConfig.baseURL.appendingPathComponent(
            AppConfig.API.Main.banner.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        )

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        // ✅ 배너는 인증 필요하므로 처음부터 true
        let (data, resp) = try await HTTPClient.shared.sendRaw(req, requiresAuth: true)

        guard let http = resp as? HTTPURLResponse else {
            throw APIError.badResponse(-1, "Invalid HTTPURLResponse")
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.badResponse(http.statusCode, body)
        }

        return try decodeBanners(data)
    }

    private static func decodeBanners(_ data: Data) throws -> [HomeBannerItem] {
        let dec = JSONDecoder()
        return try dec.decode([HomeBannerItem].self, from: data)
    }
}
