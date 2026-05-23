//
//  QnARoute.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import SwiftUI

struct QnASearchBar: View {
    @Environment(\.appMetrics) private var m

    let placeholder: String
    @Binding var text: String
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: m.space8) {
            Image(systemName: "magnifyingglass")
                .font(AppTypography.notoSans(m.space16, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)

            TextField(placeholder, text: $text)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                    onSubmit?()
                } label: {
                    Image(systemName: "xmark")
                        .font(AppTypography.notoSans(m.space14, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, m.space12)
        .frame(height: m.controlHeight44)
        .background(Color(hex: 0xD9D9D9))
        .clipShape(RoundedRectangle(cornerRadius: m.radius16, style: .continuous))
    }
}
