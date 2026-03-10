import Foundation

// /api/v1/clubs 전용 Service
enum ClubsService {

    struct Response: Decodable {
        let content: [ClubDTO]
        let hasNext: Bool
    }

    struct ClubDTO: Decodable {
        let id: Int
        let name: String
        let info: String?          // ✅ optional
        let status: String?        // ✅ optional
        let favorite: Bool
        let category: String
        let clubProfileUrl: String?

        var imageURL: URL? {
            guard let clubProfileUrl, !clubProfileUrl.isEmpty, let url = URL(string: clubProfileUrl) else { return nil }
            return url
        }
    }

    /// 전체/카테고리/이름커서 기반 조회
    /// - Parameters:
    ///   - category: CategoryType rawValue (예: "CULTURE") 또는 nil(전체)
    ///   - sortBy: 서버 허용값은 "name" 고정
    ///   - cursorName: 마지막 아이템 name을 전달
    ///   - size: 기본 10
    static func fetchClubs(
        category: String?,
        sortBy: String = "name",
        cursorName: String?,
        size: Int = 10
    ) async throws -> Response {

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "sortBy", value: sortBy),
            URLQueryItem(name: "size", value: String(size))
        ]

        if let category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        if let cursorName {
            queryItems.append(URLQueryItem(name: "cursorName", value: cursorName))
        }

        // ✅ 프로젝트의 기존 HTTPClient/AppConfig 라우팅을 그대로 사용한다고 가정
        return try await HTTPClient.shared.get(
            AppConfig.API.Clubs.list,
            query: queryItems,
            as: Response.self
        )
    }
}
