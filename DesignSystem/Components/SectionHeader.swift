//
//  SectionHeader.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public struct SectionHeader: View {
    @Environment(\.appMetrics) private var m

    private let title: String
    private let actionTitle: String?
    private let onTapAction: (() -> Void)?

    public init(_ title: String, actionTitle: String? = nil, onTapAction: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.onTapAction = onTapAction
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: m.space12)

            if let actionTitle, let onTapAction {
                Button(actionTitle, action: onTapAction)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
                    .buttonStyle(.plain)
            }
        }
        // 화면별로 x=26~27 느낌을 내고 싶으면 ScreenContainer 기본 패딩과 별개로
        // 이 헤더만 "미세 조정" 가능:
        .padding(.top, m.space8)
        .padding(.bottom, m.space8)
    }
}
