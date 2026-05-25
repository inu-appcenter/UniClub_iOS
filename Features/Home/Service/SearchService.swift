import Foundation

enum SearchService {
    /// GET /api/v1/search?keyword=
    static func search(keyword: String) async throws -> [ClubsService.ClubDTO] {
        let query = [URLQueryItem(name: "keyword", value: keyword)]
        return try await HTTPClient.shared.get(
            AppConfig.API.Search.clubs,
            query: query,
            as: [ClubsService.ClubDTO].self
        )
    }
}
