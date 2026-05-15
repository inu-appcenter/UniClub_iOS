//
//  Chip.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public struct Chip: View {
    @Environment(\.appMetrics) private var m
    private let text: String
    private let isSelected: Bool
    private let action: (() -> Void)?

    public init(_ text: String, selected: Bool = false, action: (() -> Void)? = nil) {
        self.text = text
        self.isSelected = selected
        self.action = action
    }

    public var body: some View {
        let view = Text(text)
            .font(AppTypography.caption())
            .foregroundStyle(isSelected ? AppColors.background : AppColors.brand)
            .padding(.horizontal, m.space12)
            .padding(.vertical, m.space8)
            .background(isSelected ? AppColors.brand : AppColors.brand.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: m.radiusPill))

        if let action {
            Button(action: action) { view }
                .buttonStyle(.plain)
        } else {
            view
        }
    }
}
