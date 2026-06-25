//
//  AppDelegate.swift
//  UniClub

import UIKit
import FirebaseCore
import FirebaseMessaging

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // APNs 디바이스 토큰 → Firebase로 전달
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APNs registration failed: \(error)")
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        // 로그인 후에만 서버에 토큰 등록 (로그인 상태는 FCMService.registerCurrentToken()으로 처리)
        // 여기서는 토큰 갱신만 감지하고, 실제 서버 등록은 로그인 플로우에서 처리
        Task {
            // accessToken이 있을 때만 등록 시도 (로그인된 상태에서 토큰 갱신 시)
            if MyAuthStore.shared.accessToken != nil {
                await FCMService.shared.registerTokenWithServer(token)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Foreground에서도 배너/뱃지/사운드 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    // 알림 탭 → 딥링크 처리 진입점
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // TODO: 알림 페이로드에서 딥링크 정보 추출
        // 예: 동아리 ID, 질의응답 ID 등
        // if let clubId = userInfo["clubId"] as? Int {
        //     NotificationCenter.default.post(name: .navigateToClub, object: clubId)
        // }
        
        print("📱 Notification tapped: \(userInfo)")
        completionHandler()
    }
}
