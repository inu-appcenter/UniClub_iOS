//
//  PrimaryButton.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public struct PrimaryButton: View {
    @Environment(\.appMetrics) private var m

    private let title: String
    private let isDisabled: Bool
    private let action: () -> Void

    public init(_ title: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isDisabled = disabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.primaryButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: m.controlHeight48)
                .background(AppColors.primaryButtonFill.opacity(isDisabled ? 0.35 : 1))
                .clipShape(RoundedRectangle(cornerRadius: m.radiusPill))
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
