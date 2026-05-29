//
//  NotificationModels.swift
//  UniClub

import Foundation

// MARK: - UI 모델

enum NotificationType: Equatable {
    case system
    case federation
    case club
    case personal
    case qna

    var iconAssetName: String {
        switch self {
        case .system:     return "icon_notification_warrning"
        case .federation: return "icon_notification_checkbox"
        case .club:       return "icon_notification_heart"
        case .qna:        return "icon_notification_questionmark"
        case .personal:   return ""
        }
    }

    static func from(serverType: String) -> NotificationType {
        switch serverType.uppercased() {
        case "SYSTEM":     return .system
        case "FEDERATION": return .federation
        case "CLUB":       return .club
        case "PERSONAL":   return .personal
        case "QNA":        return .qna
        default:           return .system
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

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    func toNotificationItem() -> NotificationItem {
        let date = Self.dateFormatter.date(from: createdAt) ?? Date()
        return NotificationItem(
            id: notificationId,
            type: NotificationType.from(serverType: notificationType),
            title: title,
            body: message,
            receivedAt: date,
            isRead: read,
            targetId: targetId
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
    let targetId: Int?
}
