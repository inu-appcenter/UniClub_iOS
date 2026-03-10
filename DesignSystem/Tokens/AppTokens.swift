//
//  AppTokens.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public enum AppTypography {
    // 폰트는 “무리한 스케일링” 대신 단계 고정 + Dynamic Type 친화로 가는 게 안정적
    public static func display() -> Font { .system(size: 36, weight: .regular) }
    public static func title() -> Font { .system(size: 20, weight: .semibold) }
    public static func body() -> Font { .system(size: 14, weight: .regular) }
    public static func bodyStrong() -> Font { .system(size: 14, weight: .semibold) }
    public static func caption() -> Font { .system(size: 12, weight: .regular) }
    public static func captionStrong() -> Font {
        .system(size: 12, weight: .semibold)
    }
}

public enum AppColors {
    public static let background = Color.white
    public static let textPrimary = Color.black
    public static let textSecondary = Color.black.opacity(0.65)

    public static let brand = Color.orange // 너희 디자인 느낌에 맞춰 바꿔
    public static let onBrand = primaryButtonText
    
    public static let border = Color.black.opacity(0.12)
    public static let fieldFill = Color.black.opacity(0.04)
    public static let cardFill = Color.black.opacity(0.03)
    
    public static let surface = cardFill

    public static let primaryButtonFill = Color.black
    public static let primaryButtonText = Color.white
}
