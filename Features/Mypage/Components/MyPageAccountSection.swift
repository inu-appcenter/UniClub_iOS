//
//  MyPageAccountSection.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

struct MyPageAccountSection: View {
    @Environment(\.appMetrics) private var m

    let onNotification: () -> Void
    let onProfileEdit: () -> Void
    let onLogout: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MyPageSectionTitle(title: "계정")
                .padding(.bottom, m.space14)

            MyPageMenuRow(title: "알림 설정", action: onNotification)
            MyPageMenuRow(title: "프로필 수정", action: onProfileEdit)
            MyPageMenuRow(title: "로그아웃", action: onLogout)
        }
    }
}
