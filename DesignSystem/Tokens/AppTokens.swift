//
//  AppTypography.swift
//  UniClub
//

import SwiftUI

public enum AppTypography {
    // MARK: - Flexible factory
    public static func notoSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .medium:   return .custom("NotoSansKR-Medium",   size: size)
        case .semibold: return .custom("NotoSansKR-SemiBold", size: size)
        case .bold:     return .custom("NotoSansKR-Bold",     size: size)
        default:        return .custom("NotoSansKR-Regular",  size: size)
        }
    }

    // MARK: - Semantic aliases
    public static func display() -> Font      { notoSans(32, weight: .bold) }
    public static func title() -> Font        { notoSans(20, weight: .bold) }
    public static func body() -> Font         { notoSans(14) }
    public static func bodyStrong() -> Font   { notoSans(14, weight: .semibold) }
    public static func caption() -> Font      { notoSans(12) }
    public static func captionStrong() -> Font{ notoSans(12, weight: .semibold) }

    // MARK: - Krona One
    public static func kronaDisplay() -> Font { .custom("KronaOne-Regular", size: 36) }
    public static func kronaTitle() -> Font   { .custom("KronaOne-Regular", size: 20) }
}
