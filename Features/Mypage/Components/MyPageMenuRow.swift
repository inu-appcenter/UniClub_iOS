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
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer(minLength: 0)
            }
            .padding(.vertical, m.space10)
            .frame(minHeight: m.controlHeight44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
