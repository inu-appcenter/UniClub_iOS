//
//  QnABlockConfirmDialog.swift
//  UniClub
//
//  Created by 제욱 on 3/22/26.
//

import SwiftUI

struct QnABlockConfirmDialog: View {
    @Environment(\.appMetrics) private var m

    let title: String
    let isSubmitting: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, m.space20)
                .padding(.top, m.space24)

            Text("차단한 사용자의 게시물과 답변은 서로의 피드에서 숨겨집니다.")
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, m.space20)
                .padding(.top, m.space16)

            HStack(spacing: 0) {
                Button("취소") {
                    onCancel()
                }
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)

                Button("차단") {
                    onConfirm()
                }
                .font(AppTypography.body())
                .foregroundStyle(isSubmitting ? AppColors.grey400 : AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .disabled(isSubmitting)
            }
            .padding(.top, m.space18)
        }
        .frame(width: 300)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
