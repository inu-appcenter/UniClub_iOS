//
//  UniClubApp.swift
//  UniClub
//
//  Created by 제욱 on 2/1/26.
//

import SwiftUI

@main
struct UniClubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var auth = MyAuthStore.shared
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geo in
                let metrics = AppMetrics.make(for: geo.size, baseWidth: 360)
                Group {
                    if auth.accessToken != nil {
                        MainShellView()
                    } else {
                        AuthRootView()
                    }
                }
                .environment(\.appMetrics, metrics)
            }
            // 전역 ignoresSafeArea(.top)은 두지 않는다.
            // 상태바 뒤로 콘텐츠를 확장해야 하는 화면은 자체적으로 `.ignoresSafeArea(.container, edges: .top)`을 호출한다.
            // (예: LoginView의 ScrollView — 피그마 좌표가 상태바 포함 기준)
            // 그 외 화면(ScreenContainer 사용)은 safe area를 자연스럽게 존중한다.
            .preferredColorScheme(.light)
        }
    }
}
