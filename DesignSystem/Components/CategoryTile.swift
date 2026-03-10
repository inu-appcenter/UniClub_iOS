//
//  CategoryTile.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//
//
import SwiftUI

public struct CategoryTile: View {
    @Environment(\.appMetrics) private var m

    private let title: String
    private let systemIcon: String?
    private let action: () -> Void

    public init(title: String, systemIcon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemIcon = systemIcon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: m.space10) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.brand)
                }

                Text(title)
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, m.space14)
            .padding(.vertical, m.space12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: m.radius18))
            .overlay(
                RoundedRectangle(cornerRadius: m.radius18)
                    .stroke(AppColors.border, lineWidth: m.hairline)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
