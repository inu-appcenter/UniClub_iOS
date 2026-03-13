//
//  QnAReportDialog.swift
//  UniClub
//
//  Created by ChatGPT on 3/12/26.
//

import SwiftUI

struct QnAReportDialog: View {
    @Environment(\.appMetrics) private var m

    let title: String
    @Binding var reason: String
    let isSubmitting: Bool
    let onCancel: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, m.space24)

            Text("신고 사유를 입력해주세요.")
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, m.space16)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: 0xF5F5F5))

                if reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("이유를 입력해주세요.")
                        .font(AppTypography.body())
                        .foregroundStyle(Color(hex: 0x9A9A9A))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $reason)
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.clear)
            }
            .frame(width: 260, height: 110)
            .padding(.top, m.space14)

            HStack(spacing: 0) {
                Button("취소") {
                    onCancel()
                }
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)

                Button("전달") {
                    onSubmit()
                }
                .font(AppTypography.body())
                .foregroundStyle(
                    reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting
                    ? Color(hex: 0xBFBFBF)
                    : AppColors.textPrimary
                )
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .disabled(reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
            }
            .padding(.top, m.space18)
        }
        .frame(width: 300)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
