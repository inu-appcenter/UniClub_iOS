//
//  MyPageEtcSection.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

struct MyPageEtcSection: View {
    @Environment(\.appMetrics) private var m

    let onDeleteAccount: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MyPageSectionTitle(title: "기타")
                .padding(.bottom, m.space14)

            MyPageMenuRow(title: "계정 삭제", action: onDeleteAccount)
        }
    }
}
