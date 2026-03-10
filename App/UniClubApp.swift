//
//  UniClubApp.swift
//  UniClub
//
//  Created by 제욱 on 2/1/26.
//

import SwiftUI

@main
struct UniClubApp: App {
    @StateObject private var auth = MyAuthStore.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.accessToken != nil {
                    MainShellView()
                } else {
                    AuthRootView()
                }
            }
        }
    }
}
