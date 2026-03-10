import Foundation


enum HomeRoute: Hashable {
    case clubListAll
    case clubListCategory(String)
    case search
}

enum ClubListMode: Hashable {
    case all
    case category(String)

    var title: String {
        switch self {
        case .all: return "전체보기"
        case .category(let name): return name
        }
    }

    /// ✅ API query로 넘길 category 값 (서버 enum rawValue)
    /// - 주의: 현재 route는 "문화분과" 같은 한글 문자열을 들고 있음.
    /// - 여기서 서버 enum 값으로 변환해서 ViewModel로 전달한다.
    var categoryQuery: String? {
        switch self {
        case .all:
            return nil
        case .category(let name):
            return CategoryType.fromDisplayTitle(name)?.rawValue
        }
    }
}
