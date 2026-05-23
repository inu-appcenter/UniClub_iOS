//
//  NotificationModels.swift
//  UniClub

import Foundation

// MARK: - UI 모델

enum NotificationType: Equatable {
    case recruitStart
    case recruitEnd
    case answer
    case question
    case reply
    case system

    var iconSystemName: String {
        switch self {
        case .recruitStart, .recruitEnd: return "megaphone.fill"
        case .answer, .question, .reply: return "questionmark.circle.fill"
        case .system:                    return "checkmark.circle.fill"
        }
    }

    static func from(serverType: String) -> NotificationType {
        switch serverType.uppercased() {
        case "RECRUIT_START": return .recruitStart
        case "RECRUIT_END":   return .recruitEnd
        case "ANSWER":        return .answer
        case "QUESTION":      return .question
        case "REPLY":         return .reply
        default:              return .system
        }
    }
}

// MARK: - API Response DTOs

// 실제 응답: pagination 필드가 최상위에 flat하게 위치
struct NotificationListResponse: Decodable {
    let notifications: [NotificationDTO]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let hasNext: Bool
}

struct NotificationDTO: Decodable {
    let notificationId: Int
    let title: String
    let message: String
    let read: Bool
    let notificationType: String  // 서버 필드명
    let targetId: Int?
    let createdAt: String

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func toNotificationItem() -> NotificationItem {
        let date = Self.isoFormatter.date(from: createdAt) ?? Date()
        return NotificationItem(
            id: notificationId,
            type: NotificationType.from(serverType: notificationType),
            title: title,
            body: message,
            receivedAt: date,
            isRead: read
        )
    }
}

struct NotificationSettingResponse: Decodable {
    let notificationEnabled: Bool
}

struct NotificationItem: Identifiable {
    let id: Int
    let type: NotificationType
    let title: String
    let body: String
    let receivedAt: Date
    var isRead: Bool

    var actionLabel: String? {
        switch type {
        case .recruitStart, .recruitEnd: return "지원하기"
        case .answer, .question, .reply: return "이동하기"
        case .system: return nil
        }
    }

    // 이모지를 body 앞에 붙여서 표시 (Figma 구조)
    var bodyWithEmoji: String {
        switch type {
        case .recruitStart: return "📢 \(body)"
        case .recruitEnd:   return "🚨 \(body)"
        default:            return body
        }
    }
}

// MARK: - Preview fixtures

extension NotificationItem {
    static let previews: [NotificationItem] = [
        NotificationItem(id: 1, type: .recruitStart,
                         title: "앱센터 모집 마감 예정",
                         body: "앱센터 동아리 모집이 시작되었습니다!",
                         receivedAt: .now.addingTimeInterval(-1800), isRead: false),
        NotificationItem(id: 2, type: .recruitEnd,
                         title: "앱센터 모집 시작",
                         body: "앱센터 동아리 모집이 7일 후 마감됩니다.",
                         receivedAt: .now.addingTimeInterval(-1800), isRead: false),
        NotificationItem(id: 3, type: .answer,
                         title: "언제까지 모집하나요?(질문글 제목예시)",
                         body: "질문에 새로운 답변이 등록되었습니다.",
                         receivedAt: .now.addingTimeInterval(-180), isRead: false),
        NotificationItem(id: 4, type: .question,
                         title: "답변을 기다리고 있는 질문이 있어요!",
                         body: "앱센터 동아리에 새로운 질문이 등록되었습니다.",
                         receivedAt: .now.addingTimeInterval(-180), isRead: false),
        NotificationItem(id: 5, type: .reply,
                         title: "동아리 모집 언제 시작함?(질문글 제목 예시)",
                         body: "새로운 대댓글이 등록되었습니다.",
                         receivedAt: .now.addingTimeInterval(-180), isRead: true),
        NotificationItem(id: 6, type: .system,
                         title: "시스템 알림",
                         body: "시스템 알림 내용.",
                         receivedAt: .now.addingTimeInterval(-540), isRead: true),
    ]
}
