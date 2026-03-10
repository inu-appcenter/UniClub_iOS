//
//  ClubListEnum.swift
//  UniClub
//
//  Created by 제욱 on 2/9/26.
//
import Foundation

// 서버 enum: ClubStatus
enum ClubStatus: String {
    case scheduled = "SCHEDULED"
    case active = "ACTIVE"
    case closed = "CLOSED"

    var displayText: String {
        switch self {
        case .scheduled: return "모집예정"
        case .active: return "모집중"
        case .closed: return "모집마감"
        }
    }
}

// 서버 enum: CategoryType
enum CategoryType: String, CaseIterable {
    case liberalAcademic = "LIBERAL_ACADEMIC"   // 교양학술
    case hobbyExhibition = "HOBBY_EXHIBITION"   // 취미전시
    case sports = "SPORTS"                      // 체육
    case religion = "RELIGION"                  // 종교
    case volunteer = "VOLUNTEER"                // 봉사
    case culture = "CULTURE"                    // 문화

    var displayText: String {
        switch self {
        case .liberalAcademic: return "교양학술"
        case .hobbyExhibition: return "취미전시"
        case .sports: return "체육"
        case .religion: return "종교"
        case .volunteer: return "봉사"
        case .culture: return "문화"
        }
    }

    /// "문화" 혹은 "문화분과" 같은 표시 문자열 → 서버 enum으로 변환
    /// - 추측 금지 원칙: 완전 일치 또는 포함 기반의 명시적 매칭만 허용
    static func fromDisplayTitle(_ title: String) -> CategoryType? {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) 완전 일치 우선
        if let exact = CategoryType.allCases.first(where: { $0.displayText == t }) {
            return exact
        }

        // 2) 포함 매칭(예: "문화분과"에 "문화" 포함)
        //    애매함이 없도록 "displayText가 title에 포함"만 허용
        if let contains = CategoryType.allCases.first(where: { t.contains($0.displayText) }) {
            return contains
        }

        return nil
    }
}
