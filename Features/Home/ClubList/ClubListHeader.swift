//
//  ClubListHeader.swift
//  UniClub
//
//  Created by 제욱 on 2/9/26.
//

import SwiftUI

/// ClubList 화면 상단 헤더(뒤로가기 / 타이틀 / 검색)
/// - View에서 헤더 레이아웃을 직접 만들지 않도록 컴포넌트화
struct ClubListHeader: View {
    @Environment(\.appMetrics) private var m
    
    let title: String
    let onTapBack: () -> Void
    let onTapSearch: () -> Void
    
    var body: some View {
        HStack(spacing: m.space8) {
            IconButton(systemName: "chevron.left", variant: .plain) {
                onTapBack()
            }
            
            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
            
            Spacer(minLength: 0)
            
            IconButton(systemName: "magnifyingglass", variant: .plain) {
                onTapSearch()
            }
        }
        .frame(minHeight: 44)
        .padding(.horizontal, m.horizontalPadding)
        .padding(.vertical, m.space8)
    }
}
