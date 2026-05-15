//
//  IconButton.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public enum IconButtonVariant: Equatable {
    /// 아이콘만(배경 없음) — 기본값
    case plain
    /// 배경이 있는 아이콘 버튼(원형/둥근 사각형)
    case filled(background: Color = AppColors.cardFill, cornerRadius: CGFloat = 999)
}

public struct IconButton: View {
    @Environment(\.appMetrics) private var m

    private let systemName: String
    private let size: CGFloat?
    private let hitSize: CGFloat?
    private let weight: Font.Weight
    private let tint: Color
    private let variant: IconButtonVariant
    private let action: () -> Void

    /// ✅ 기존 API(호환 유지). background/cornerRadius 기반.
    public init(
        systemName: String,
        size: CGFloat? = nil,
        hitSize: CGFloat? = nil,
        weight: Font.Weight = .semibold,
        tint: Color = AppColors.textPrimary,
        background: Color? = nil,
        cornerRadius: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.size = size
        self.hitSize = hitSize
        self.weight = weight
        self.tint = tint
        if let bg = background {
            self.variant = .filled(background: bg, cornerRadius: cornerRadius ?? 999)
        } else {
            self.variant = .plain
        }
        self.action = action
    }

    /// ✅ 권장 API: variant로 스타일을 통일해서 사용
    public init(
        systemName: String,
        variant: IconButtonVariant,
        size: CGFloat? = nil,
        hitSize: CGFloat? = nil,
        weight: Font.Weight = .semibold,
        tint: Color = AppColors.textPrimary,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.variant = variant
        self.size = size
        self.hitSize = hitSize
        self.weight = weight
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: resolvedSize, weight: weight))
                .foregroundStyle(tint)
                .frame(width: resolvedHitSize, height: resolvedHitSize)
                .background(backgroundView)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(systemName)
    }

    private var resolvedSize: CGFloat { size ?? m.space18 }
    private var resolvedHitSize: CGFloat { hitSize ?? m.controlHeight44 }

    private var backgroundView: some View {
        switch variant {
        case .plain:
            return Color.clear
        case .filled(let bg, _):
            return bg
        }
    }

    private var cornerRadius: CGFloat {
        switch variant {
        case .plain:
            return 999
        case .filled(_, let r):
            return r
        }
    }
}

// MARK: - Back Button Factory

extension IconButton {
    /// Figma 스펙: chevron.left, size=18, weight=.medium (strokeWeight 2.0 근사)
    /// tint 기본값: textPrimary(#000000) / 밝은 배경용 .white 전달
    public static func back(
        tint: Color = AppColors.textPrimary,
        action: @escaping () -> Void
    ) -> IconButton {
        IconButton(
            systemName: "chevron.left",
            variant: .plain,
            weight: .medium,
            tint: tint,
            action: action
        )
    }
}
