//
//  FCMService.swift
//  UniClub

import Foundation
import Combine
import UserNotifications
import UIKit
import FirebaseMessaging

@MainActor
final class FCMService: NSObject, ObservableObject {
    static let shared = FCMService()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private override init() { super.init() }

    // MARK: - 알림 권한 요청

    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            print("FCM permission request error: \(error)")
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - 로그인 시 현재 토큰 등록

    func registerCurrentToken() async {
        guard let token = Messaging.messaging().fcmToken else { return }
        await registerTokenWithServer(token)
    }

    // MARK: - 서버 토큰 등록

    func registerTokenWithServer(_ token: String) async {
        guard MyAuthStore.shared.accessToken != nil else { return }
        do {
            _ = try await HTTPClient.shared.postJSONRaw(
                AppConfig.API.FCM.register,
                body: FCMRegisterBody(fcmToken: token)
            )
        } catch {
            print("FCM register failed: \(error)")
        }
    }

    // MARK: - 서버 토큰 삭제 (로그아웃 시)

    func unregisterTokenFromServer() async {
        guard MyAuthStore.shared.accessToken != nil else { return }
        do {
            _ = try await HTTPClient.shared.deleteRaw(AppConfig.API.FCM.unregister)
        } catch {
            print("FCM unregister failed: \(error)")
        }
    }
}

private struct FCMRegisterBody: Encodable {
    let fcmToken: String
}
