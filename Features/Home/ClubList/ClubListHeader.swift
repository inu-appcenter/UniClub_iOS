//
//  ClubListHeader.swift
//  UniClub
//
//  Created by 제욱 on 2/9/26.
//

import SwiftUI

/// ClubList 화면 상단 헤더(뒤로가기 / 타이틀 / 검색)
/// - 정책상 4계층(`AppPageHeader`)에 위임하고, 검색 액션 trailing 슬롯만 자체 제공한다.
struct ClubListHeader: View {
    let title: String
    let onTapBack: () -> Void
    let onTapSearch: () -> Void

    var body: some View {
        AppPageHeader(onBack: { onTapBack() }) {
            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
        } trailing: {
            IconButton(systemName: "magnifyingglass", variant: .plain) {
                onTapSearch()
            }
        }
    }
}
