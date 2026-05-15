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
            .ignoresSafeArea()
            .preferredColorScheme(.light)
        }
    }
}
