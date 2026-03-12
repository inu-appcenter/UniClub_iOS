//
//  QnARoute.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import SwiftUI

struct QnAFilterBar: View {
    @Environment(\.appMetrics) private var m

    let selectedClubName: String?
    let onTapSelectClub: () -> Void

    let answeredOnly: Bool
    let onToggleAnsweredOnly: () -> Void

    let onlyMyQuestions: Bool
    let onToggleOnlyMyQuestions: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: m.space12) {
            Button(action: onTapSelectClub) {
                HStack(spacing: m.space8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: m.space14, weight: .semibold))
                    Text(selectedClubName ?? "동아리 선택")
                        .font(AppTypography.captionStrong())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, m.space12)
                .frame(height: m.controlHeight44 - m.space8)
                .background(Color(hex: 0xFF5900))
                .clipShape(Capsule())
            }

            Spacer(minLength: 0)

            filterToggle(
                title: "답변 완료만",
                isOn: answeredOnly,
                action: onToggleAnsweredOnly
            )

            filterToggle(
                title: "내 질문만",
                isOn: onlyMyQuestions,
                action: onToggleOnlyMyQuestions
            )
        }
    }

    private func filterToggle(
        title: String,
        isOn: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: m.space6) {
                Text(title)
                    .font(AppTypography.caption())
                    .foregroundStyle(isOn ? Color(hex: 0xFF5900) : AppColors.textSecondary)

                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isOn ? Color(hex: 0xFF5900) : Color.gray.opacity(0.35))
                        .frame(width: m.space18 + m.space2, height: m.space18 + m.space2)

                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: m.space10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
