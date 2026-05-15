//
//  NotificationService.swift
//  UniClub

import Foundation

enum NotificationService {

    static func fetchAll() async throws -> [NotificationItem] {
        let response = try await HTTPClient.shared.get(
            AppConfig.API.Notifications.list,
            query: [
                URLQueryItem(name: "page", value: "0"),
                URLQueryItem(name: "size", value: "100"),
                URLQueryItem(name: "sort", value: "createdAt,DESC")
            ],
            as: NotificationListResponse.self
        )
        return response.notifications.map { $0.toNotificationItem() }
    }

    static func markRead(id: Int) async throws {
        _ = try await HTTPClient.shared.patchRaw(AppConfig.API.Notifications.read(id))
    }

    static func markAllRead() async throws {
        _ = try await HTTPClient.shared.patchRaw(AppConfig.API.Notifications.readAll)
    }

    static func delete(id: Int) async throws {
        _ = try await HTTPClient.shared.deleteRaw(AppConfig.API.Notifications.delete(id))
    }

    static func deleteAll() async throws {
        _ = try await HTTPClient.shared.deleteRaw(AppConfig.API.Notifications.list)
    }

    static func fetchSetting() async throws -> Bool {
        let response = try await HTTPClient.shared.get(
            AppConfig.API.User.notificationSetting,
            as: NotificationSettingResponse.self
        )
        return response.notificationEnabled
    }

    static func toggleSetting() async throws {
        _ = try await HTTPClient.shared.patchRaw(AppConfig.API.User.notificationSetting)
    }
}
