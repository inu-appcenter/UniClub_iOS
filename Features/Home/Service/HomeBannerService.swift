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
        try await HTTPClient.shared.get(
            AppConfig.API.Main.banner,
            as: [HomeBannerItem].self
        )
    }
}
