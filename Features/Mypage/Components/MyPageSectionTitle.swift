//
//  MyPageSectionTitle.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

struct MyPageSectionTitle: View {
    @Environment(\.appMetrics) private var m
    let title: String

    var body: some View {
        Text(title)
            .font(AppTypography.bodyStrong())
            .foregroundStyle(AppColors.textPrimary)
            .padding(.bottom, m.space14)
    }
}
