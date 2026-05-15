//
//  SortSheet.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

struct SortSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: SortOption

    var body: some View {
        // ✅ 시트 내부에서 커스텀 헤더를 사용하므로 topPadding 제거
        ScreenContainer(scroll: false, topPadding: .none) { m in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("정렬")
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    IconButton(systemName: "xmark", variant: .plain) { dismiss() }
                }
                .padding(.bottom, m.space12)

                VStack(spacing: m.space10) {
                    ForEach(SortOption.allCases) { option in
                        Button {
                            selected = option
                            dismiss()
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                    .font(AppTypography.body())
                                    .foregroundStyle(AppColors.textPrimary)

                                Spacer()

                                if selected == option {
                                    Image(systemName: "checkmark")
                                        .font(AppTypography.notoSans(14, weight: .bold))
                                        .foregroundStyle(AppColors.brand)
                                }
                            }
                            .padding(.horizontal, m.space12)
                            .padding(.vertical, m.space12)
                            .background(AppColors.cardFill)
                            .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                            .overlay(
                                RoundedRectangle(cornerRadius: m.radius18)
                                    .stroke(AppColors.border, lineWidth: m.hairline)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }
}
