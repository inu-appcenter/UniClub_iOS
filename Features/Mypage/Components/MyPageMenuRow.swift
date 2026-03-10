//
//  MyPageMenuRow.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

struct MyPageMenuRow: View {
    @Environment(\.appMetrics) private var m

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textPrimary)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.vertical, m.space10)
            .frame(minHeight: m.controlHeight44)
        }
        .buttonStyle(.plain)
    }
}
