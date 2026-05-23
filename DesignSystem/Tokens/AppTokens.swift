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
    public static func display() -> Font            { notoSans(32, weight: .bold) }
    public static func title() -> Font              { notoSans(20, weight: .bold) }
    public static func subtitleStrong() -> Font     { notoSans(16, weight: .medium) }
    public static func body() -> Font               { notoSans(14) }
    public static func bodyMedium() -> Font         { notoSans(14, weight: .medium) }
    public static func bodyStrong() -> Font         { notoSans(14, weight: .semibold) }
    public static func caption() -> Font            { notoSans(12) }
    public static func captionStrongMedium() -> Font{ notoSans(12, weight: .medium) }
    public static func captionStrong() -> Font      { notoSans(12, weight: .semibold) }

    // MARK: - Krona One
    public static func kronaDisplay() -> Font { .custom("KronaOne-Regular", size: 36) }
    public static func kronaTitle() -> Font   { .custom("KronaOne-Regular", size: 20) }
}

// MARK: - Button Shadow Modifier

public struct ButtonShadowModifier: ViewModifier {
    let style: Style

    public enum Style {
        case small   // radius=2.5 offset=(0,1)
        case medium  // radius=4   offset=(0,4)
    }

    public func body(content: Content) -> some View {
        switch style {
        case .small:
            content.shadow(color: .black.opacity(0.25), radius: 2.5, x: 0, y: 1)
        case .medium:
            content.shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
        }
    }
}

public extension View {
    func buttonShadow(_ style: ButtonShadowModifier.Style = .small) -> some View {
        modifier(ButtonShadowModifier(style: style))
    }
}
