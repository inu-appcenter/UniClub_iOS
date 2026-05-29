//
//  AppColors.swift
//  UniClub
//

import SwiftUI

public enum AppColors {

    // MARK: - Grey Palette (Figma 디자인 시스템 기준)
    public static let grey800 = Color(hex: 0x000000)
    public static let grey700 = Color(hex: 0x2B2B2B)
    public static let grey600 = Color(hex: 0x767676)
    public static let grey550 = Color(hex: 0x818181)
    public static let grey500 = Color(hex: 0x9F9F9F)
    public static let grey450 = Color(hex: 0xA7A7A7)   // 일부 구분선
    public static let grey400 = Color(hex: 0xBFBFBF)
    public static let grey350 = Color(hex: 0xACACAC)   // Mypage 토글 OFF
    public static let grey300 = Color(hex: 0xD2D2D2)
    public static let grey000 = Color(hex: 0xFFFFFF)

    // MARK: - Brand
    public static let brand          = Color(hex: 0xFF5900)
    public static let brandLight     = Color(hex: 0xFF7600)
    public static let brandCardFill  = Color(hex: 0xFF9230)
    public static let error      = Color(hex: 0xF30000)
    public static let pink       = Color(hex: 0xFFBFC8)

    // MARK: - Semantic: Background
    public static let background          = grey000
    public static let backgroundSecondary = Color(hex: 0xF8F8F8)
    public static let backgroundTertiary  = Color(hex: 0xF7F7F7)
    public static let cardFill            = Color(hex: 0xF8F8F8)
    public static let surface             = cardFill
    public static let fieldFill           = Color(hex: 0xF4F4F4)
    public static let separator           = Color(hex: 0xE8E8E8)

    // MARK: - Semantic: Text
    public static let textPrimary      = grey800
    public static let textSecondary    = grey600           // #767676 기본
    public static let textSecondaryAlt = Color(hex: 0x919191) // 화면별 보조 텍스트
    public static let textTertiary     = grey500
    public static let textTertiaryAlt  = Color(hex: 0xA0A0A0)  // 화면별 3차 텍스트
    public static let textDisabled     = grey400

    // MARK: - Semantic: Border
    public static let border         = grey300
    public static let inactiveTab    = Color(hex: 0xE7E7E7)  // Signup 탭 indicator
    public static let iconNeutral    = Color(hex: 0x757575)  // chevron 등 중립 아이콘
    public static let separatorLight = Color(hex: 0xEBEBEB)  // 카드 구분선

    // MARK: - Semantic: Button
    public static let primaryButtonFill = grey700
    public static let primaryButtonText = grey000
    public static let onBrand           = grey000
}
